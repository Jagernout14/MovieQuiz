import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    //MARK: Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var moviesLoader: MoviesLoading = MoviesLoader()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        //presenter.restartGame()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.imageData) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    func resetImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func showQuizResult() {
        _ = GameResult(
            correct: presenter.correctAnswers,
            total: presenter.questionAmount,
            date: Date()
        )
        
        let message = presenter.makeResultMessage()
        
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
            
            self.presenter.restartGame()
            
            presenter.noInternetConnection = false
            self.showLoadingIndicator()
            
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    //MARK: Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}

   
