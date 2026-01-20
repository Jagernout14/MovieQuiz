import UIKit

final class MovieQuizPresenter {
    
    
    let questionAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var noInternetConnection = false
    var questionFactory: QuestionFactoryProtocol?
    var correctAnswers = 0

    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage (),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    func showNextQuestionOrResult() {
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
    
    
        
    
    //private func answer (given: Bool) {
        // guard let currentQuestion = currentQuestion else { return }
       //  let correct = currentQuestion.correctAnswer
      //  viewController?.showAnswerResult(isCorrect: given == correct)
         //yesButton.isEnabled = false
         //noButton.isEnabled = false
     }

