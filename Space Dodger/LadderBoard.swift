import Foundation

struct ScoreEntry: Codable {
    let score: Int
    let date: Date
}

class LadderBoard {
    static let shared = LadderBoard()
    private let leaderboardKey = "ladderBoard"
    private let maxEntries = 10

    private init() {}

    func saveScore(_ score: Int) {
        var leaderboard = loadScores()
        let newEntry = ScoreEntry(score: score, date: Date())
        leaderboard.append(newEntry)
        leaderboard.sort { $0.score > $1.score }
        if leaderboard.count > maxEntries {
            leaderboard = Array(leaderboard.prefix(maxEntries))
        }
        if let data = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(data, forKey: leaderboardKey)
            print("Score \(score) saved to leaderboard.")
        } else {
            print("Failed to encode leaderboard.")
        }
    }

    func loadScores() -> [ScoreEntry] {
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let leaderboard = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            return leaderboard
        }
        return []
    }
}
