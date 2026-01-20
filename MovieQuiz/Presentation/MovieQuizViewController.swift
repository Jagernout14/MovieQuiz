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
    private let presenter = MovieQuizPresenter()
    //private var currentQuestionIndex = 0
    //private var correctAnswers = 0
    //private let questionAmount: Int = 10
    
    //private var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var moviesLoader: MoviesLoading = MoviesLoader()
    //private var noInternetConnection = false
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
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
    /*
     private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage (),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionAmount)")
        return questionStep
    }
     */
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func showAnswerResult(isCorrect: Bool) {
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResult()
        }
    }
    
    
     /*
      private func showNextQuestionOrResult() {
         if presenter.isLastQuestion() {
            showQuizResult()
        } else {
            presenter.switchToNextQuestion()
            if noInternetConnection {
                showNetworkError(message: "Интернет соединение отсутствует")
            } else {
                self.questionFactory.requestNextQuestion()
            }
        }
    }
      */
     
    
    func showQuizResult() {
        _ = GameResult(
            correct: presenter.correctAnswers,
            total: presenter.questionAmount,
            date: Date()
        )
        
        statisticService.updateStatistic(correctAnswers: presenter.correctAnswers, totalQuestions: presenter.questionAmount)
        
        let bestGame = statisticService.bestGame
        let accuracy = statisticService.totalAccuracy * 100
        let formattedAccuracy = String(format: "%.2f", accuracy)
        
        var message = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionAmount)\n"
        message += "Сыграно квизов: \(statisticService.gamesCount)\n"
        
        if bestGame.total > 0 {
            message += "Рекорд: \(bestGame.correct)/\(bestGame.total)\n"
        }
        message += "Средняя точность: \(formattedAccuracy)%"
        
        let alertModel = AlertModel(
            identifier: "GameResult",
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
        presenter.restartGame()
        //currentQuestionIndex = 0
        //correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        presenter.noInternetConnection = true
        hideLoadingIndicator()
        
        let model = AlertModel(identifier: "GameResultError", title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            //self.currentQuestionIndex = 0
            presenter.restartGame()
           // self.correctAnswers = 0
            
            presenter.noInternetConnection = false
            self.showLoadingIndicator()
            self.questionFactory.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func didLoadDataFromServer() {
        presenter.noInternetConnection = false
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        presenter.noInternetConnection = true
        hideLoadingIndicator()
        yesButton.isEnabled = false
        noButton.isEnabled = false
        showNetworkError(message: "Ошибка сети")
    }

    //MARK: Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    //MARK: Game Logic
   /*private func answer (given: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let correct = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: given == correct)
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    */
    
    //MARK: QuestionFactoryDelegate
    func didReceivedNextQuestion(question: QuizQuestion?) {
        presenter.didReceivedNextQuestion(question: question)    }
     
}

   
