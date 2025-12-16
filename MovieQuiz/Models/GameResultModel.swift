import Foundation
struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetter(another: GameResult) -> Bool {
        correct > another.correct
        }
    
    func saveResult(correct count: Int, total amount: Int) {
        
    }
}
