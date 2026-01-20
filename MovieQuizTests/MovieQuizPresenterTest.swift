import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    // MARK: - Свойства для отслеживания вызовов
    
    var showStepCalled = false
    var lastStepModel: QuizStepViewModel?
    
    var showQuizResultCalled = false
    
    var highlightBorderCalled = false
    var highlightedIsCorrectAnswer: Bool?
    
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    
    var showNetworkErrorCalled = false
    var lastNetworkErrorMessage: String?
    var resetBorderCalled = false
    
    
    // MARK: - Реализация протокола
    
    func show(quiz step: QuizStepViewModel) {
        showStepCalled = true
        lastStepModel = step
    }
    
    func showQuizResult() {
        showQuizResultCalled = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightBorderCalled = true
        highlightedIsCorrectAnswer = isCorrectAnswer
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func showNetworkError(message: String) {
        showNetworkErrorCalled = true
        lastNetworkErrorMessage = message
    }
    
    func resetImageBorder() {
        resetBorderCalled = true
    }
    
    final class MovieQuizPresenterTests: XCTestCase {
        func testPresenterConvertModel() throws {
            let viewControllerMock = MovieQuizViewControllerMock()
            let sut = MovieQuizPresenter(viewController: viewControllerMock)
            
            let emptyData = Data()
            let question = QuizQuestion(imageData: emptyData, text: "Question Text", correctAnswer: true)
            let viewModel = sut.convert(model: question)
            
            XCTAssertEqual(viewControllerMock.lastStepModel?.imageData, emptyData)
            XCTAssertEqual(viewModel.question, "Question Text")
            XCTAssertEqual(viewModel.questionNumber, "1/10")
        }
    }
}
