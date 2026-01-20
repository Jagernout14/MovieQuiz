import UIKit

final class MovieQuizPresenter {
    
    let questionAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

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
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
        
        func noButtonClicked() {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = false
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
        
    
    //private func answer (given: Bool) {
        // guard let currentQuestion = currentQuestion else { return }
       //  let correct = currentQuestion.correctAnswer
      //  viewController?.showAnswerResult(isCorrect: given == correct)
         //yesButton.isEnabled = false
         //noButton.isEnabled = false
     }

