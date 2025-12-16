import Foundation
final class StatisticService {
    
    private var totalCorrectAnswers: Int {
        get {
            UserDefaults.standard.integer(forKey: "totalCorrectAnswers")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "totalCorrectAnswers")
        }
    }
    private var totalQuestionsAsked: Int {
        get {
            UserDefaults.standard.integer(forKey: "totalQuestionsAsked")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "totalQuestionsAsked")
        }
    }
    
}

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            let gamesCount = UserDefaults.standard.integer(forKey: "gamesCount")
            return gamesCount
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gamesCount")
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = UserDefaults.standard.integer(forKey: "bestGameCorrect")
            let total = UserDefaults.standard.integer(forKey: "bestGameTotal")
            if let date = UserDefaults.standard.object(forKey: "bestGameDate") as? Date {
                return GameResult(correct: correct, total: total, date: date)
            } else {
                return GameResult(correct: correct, total: total, date: Date())
            }
        }
        set {
            UserDefaults.standard.set(newValue.correct, forKey: "bestGameCorrect")
            UserDefaults.standard.set(newValue.total, forKey: "bestGameTotal")
            UserDefaults.standard.set(newValue.date, forKey: "bestGameDate")
        }
    }
    
    var totalAccuracy: Double {
        if totalQuestionsAsked == 0 {
            return 0.0
        } else {
            return Double(totalQuestionsAsked) / Double(totalCorrectAnswers)
        }
    }
}
