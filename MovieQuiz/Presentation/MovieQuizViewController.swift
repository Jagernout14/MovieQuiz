import UIKit

final class MovieQuizViewController: UIViewController {
    
    //Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    // Models
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
        
    private struct QuizResultViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    //Mock and properties
    private let questions: [QuizQuestion] = [
            QuizQuestion(image: "The Godfather",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(image: "The Dark Knight",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(image: "Kill Bill",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(image: "The Avengers",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(image: "Deadpool",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(image: "The Green Knight",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: true),
            QuizQuestion(image: "Old",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false),
            QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false),
            QuizQuestion(image: "Tesla",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false),
            QuizQuestion(image: "Vivarium",
                         text: "Рейтинг этого фильма больше чем 6?",
                         correctAnswer: false)
        ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    //ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }
    
    //Methods
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (image: UIImage(named: model.image) ?? UIImage (),
                                              question: model.text,
                                              questionNumber: "\(currentQuestionIndex + 1) / \(questions.count)")
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
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
                    let viewModel = QuizResultViewModel (
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
                    show (quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
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
                
                let firstQuestion = self.questions[self.currentQuestionIndex]
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
        let correct = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: given == correct)
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}
