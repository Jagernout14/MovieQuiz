import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    
    let questionAmount: Int = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    
    var noInternetConnection = false
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            imageData: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = isYes == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
             guard let self = self else { return }
             self.viewController?.resetImageBorder()
             self.proceedToNextQuestionOrResults()
         }
     }
    
   private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showQuizResult()
        } else {
            if noInternetConnection {
                viewController?.showNetworkError(message: "Интернет соединение отсутствует")
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
        }
    }
    
    func didReceivedNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
    
    func makeResultMessage() -> String {
        statisticService.updateStatistic(correctAnswers: correctAnswers, totalQuestions: questionAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Сыграно квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers) / \(questionAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct) / \(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
}

