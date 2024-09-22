import SpriteKit
import Foundation

class MainMenu {
    weak var scene: GameScene?
    var startLabel: SKLabelNode!
    var leaderboardLabel: SKLabelNode!

    init(scene: GameScene) {
        self.scene = scene
        setupMenu()
    }

    private func setupMenu() {
        guard let scene = scene else { return }

        // Устанавливаем фон
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1
        scene.addChild(background)

        // Кнопка "Start Game"
        startLabel = SKLabelNode(fontNamed: "Helvetica")
        startLabel.name = "startLabel"
        startLabel.fontSize = 50
        startLabel.fontColor = UIColor.white
        startLabel.position = CGPoint(x: 0, y: 50)
        startLabel.text = "Start Game"
        startLabel.zPosition = 1
        scene.addChild(startLabel)

        // Кнопка "Leaderboard"
        leaderboardLabel = SKLabelNode(fontNamed: "Helvetica")
        leaderboardLabel.name = "ladderBoardButton"
        leaderboardLabel.fontSize = 40
        leaderboardLabel.fontColor = UIColor.white
        leaderboardLabel.position = CGPoint(x: 0, y: -50)
        leaderboardLabel.text = "Leaderboard"
        leaderboardLabel.zPosition = 1
        scene.addChild(leaderboardLabel)
    }

    func handleTouch(at location: CGPoint) {
        guard let scene = scene else { return }
        let touchedNodes = scene.nodes(at: location)
        for node in touchedNodes {
            if node.name == "startLabel" {
                scene.startGame()
                return
            } else if node.name == "ladderBoardButton" {
                scene.showLadderBoard()
                return
            }
        }
    }

    func removeMenu() {
        startLabel.removeFromParent()
        leaderboardLabel.removeFromParent()
        // Удаляем фон, если нужно
    }
}
