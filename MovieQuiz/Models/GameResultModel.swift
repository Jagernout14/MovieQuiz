import Foundation
struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    var accuracy: Double {
        guard total > 0 else {return 0}
        return Double(correct) / Double(total)
    }
    
    func isBetter(another: GameResult) -> Bool {
        return self.accuracy > another.accuracy
    }
}
