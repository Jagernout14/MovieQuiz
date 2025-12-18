import Foundation
final class StatisticService {
    
//MARK: StatisticStorage
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }

//MARK: Properties
    var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
}

extension StatisticService: StatisticServiceProtocol {
    func updateStatistic(correctAnswers: Int, totalQuestions: Int) {
        gamesCount += 1
        totalCorrectAnswers += correctAnswers
        totalQuestionsAsked += totalQuestions
    }
    
    var gamesCount: Int {
        get {
            let gamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            return gamesCount
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            if let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                return GameResult(correct: correct, total: total, date: date)
            } else {
                return GameResult(correct: correct, total: total, date: Date())
            }
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if totalQuestionsAsked == 0 {
            return 0.0
        } else {
            return Double(totalCorrectAnswers) / Double(totalQuestionsAsked)
        }
    } 
    
    func saveBestGame(result: GameResult) -> Bool {
        let currentGame = bestGame
        if result.isBetter(another: currentGame) {
            bestGame = result
            return true
        }
        return false
    }
}
