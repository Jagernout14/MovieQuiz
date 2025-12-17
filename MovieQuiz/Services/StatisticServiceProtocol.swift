import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get set }
    var bestGame: GameResult { get set }
    var totalCorrectAnswers: Int { get set }
    var totalQuestionsAsked: Int { get set }
    var totalAccuracy: Double { get }
    
    func saveBestGame(result: GameResult) -> Bool
    func updateStatistic(correctAnswers: Int, totalQuestions: Int)
}
