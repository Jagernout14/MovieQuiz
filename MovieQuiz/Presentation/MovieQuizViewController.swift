import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount: Int = 10
    
    private var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var moviesLoader: MoviesLoading = MoviesLoader()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuestionFactory()
    }
    
    //MARK: Setup
    private func setupQuestionFactory() {
        let moviesLoader = MoviesLoader()
        let questionFactory = QuestionFactory(
            moviesLoader: moviesLoader, delegate: self
        )
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    //MARK: UI Updates
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage (),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
   
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
            if currentQuestionIndex == questionAmount - 1 {
                showQuizResult()
            } else {
                currentQuestionIndex += 1
                self.questionFactory.requestNextQuestion()
            }
        }
    
    private func showQuizResult() {
        let result = GameResult(
            correct: correctAnswers,
            total: questionAmount,
            date: Date()
        )
        
        statisticService.updateStatistic(correctAnswers: correctAnswers, totalQuestions: questionAmount)
        
        let bestGame = statisticService.bestGame
        let accuracy = statisticService.totalAccuracy * 100
        let formattedAccuracy = String(format: "%.2f", accuracy)
        
        var message = "Ваш результат: \(correctAnswers)/\(questionAmount)\n"
        message += "Сыграно квизов: \(statisticService.gamesCount)\n"
        
        if bestGame.total > 0 {
            message += "Рекорд: \(bestGame.correct)/\(bestGame.total)\n"
        }
        message += "Средняя точность: \(formattedAccuracy)%"
        
        let alertModel = AlertModel(
            title: "Раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.restartGame()
            }
        )
        alertPresenter.show(in: self, model: alertModel)
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        showNetworkError(message: "Ошибка сети")
    }

    //MARK: Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answer(given: true)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answer(given: false)
    }
    
    //MARK: Game Logic
   private func answer (given: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let correct = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: given == correct)
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    //MARK: QuestionFactoryDelegate
    func didReceivedNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

   
