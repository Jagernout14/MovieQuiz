protocol QuestionFactoryDelegate: AnyObject {
    func didReceivedNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
