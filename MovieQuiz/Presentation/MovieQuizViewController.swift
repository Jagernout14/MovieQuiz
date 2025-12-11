import UIKit

final class MovieQuizViewController: UIViewController {
    
    //Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!

    //Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount: Int = 10
    private var questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    //ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    //Methods
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (image: UIImage(named: model.image) ?? UIImage (),
                                              question: model.text,
                                              questionNumber: "\(currentQuestionIndex + 1) / \(questionAmount)")
        return questionStep
    }
    
    private func show (quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
   
    private func showAnswerResult (isCorrect: Bool) {
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
       // if let nextQuestion = self.questionFactory.requestNextQuestion() {
          // self.currentQuestion = nextQuestion
       // }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionAmount - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questionAmount)"
                    let viewModel = QuizResultViewModel (
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
                    show (quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            guard let nextQuestion = questionFactory.requestNextQuestion() else { return }
            currentQuestion = nextQuestion
            let viewModel = convert (model: nextQuestion)
            show (quiz: viewModel)
        }
    }
    
    private func show (quiz result: QuizResultViewModel) {
        let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self]_ in
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                guard let firstQuestion = questionFactory.requestNextQuestion() else { return }
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    
    // Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answer(given: true)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answer(given: false)
    }
   
    private func answer (given: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let correct = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: given == correct)
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}
