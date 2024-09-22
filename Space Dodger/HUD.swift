import Foundation
import SpriteKit

class HUD {
    var scene: SKScene
    var ship: Ship
    var scoreLabel: SKLabelNode
    var livesLabel: SKLabelNode
    var fuelLabel: SKLabelNode
    var gameOverLabel: SKLabelNode?
    var restartLabel: SKLabelNode?

    var onRestart: (() -> Void)?

    var hudHeight: CGFloat = 0  // Высота HUD

    init(scene: SKScene, ship: Ship, onRestart: @escaping () -> Void) {
        self.scene = scene
        self.ship = ship
        self.onRestart = onRestart

        // Получаем размеры сцены
        let screenWidth = scene.size.width
        let screenHeight = scene.size.height

        // Получаем отступы безопасной зоны из view
        var safeAreaTopInset: CGFloat = 0
        if let view = scene.view {
            if #available(iOS 11.0, *) {
                safeAreaTopInset = view.safeAreaInsets.top
            }
        }

        // Рассчитываем верхнюю позицию
        let topPositionY = (screenHeight / 2) - safeAreaTopInset - 40

        // Инициализируем метки
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = UIColor.white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: -screenWidth / 2 + 20, y: topPositionY)
        scoreLabel.zPosition = 1
        scene.addChild(scoreLabel)

        livesLabel = SKLabelNode(fontNamed: "Helvetica")
        livesLabel.fontSize = 24
        livesLabel.fontColor = UIColor.white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: screenWidth / 2 - 20, y: topPositionY)
        livesLabel.zPosition = 1
        scene.addChild(livesLabel)

        fuelLabel = SKLabelNode(fontNamed: "Helvetica")
        fuelLabel.fontSize = 24
        fuelLabel.fontColor = UIColor.white
        fuelLabel.horizontalAlignmentMode = .center
        fuelLabel.position = CGPoint(x: 0, y: topPositionY)
        fuelLabel.zPosition = 1
        scene.addChild(fuelLabel)

        updateHUD()

        // Рассчитываем высоту HUD
        let labelHeight = scoreLabel.frame.height  // Высота метки
        hudHeight = (screenHeight / 2) - topPositionY + labelHeight / 2 + 10  // От верхнего края до нижнего края метки плюс отступ
    }

    func updateHUD() {
        updateScore()
        updateLives()
        updateFuel()
    }

    func updateScore() {
        scoreLabel.text = "Score: \(ship.score)"
    }

    func updateLives() {
        livesLabel.text = "Lives: \(ship.lives)"
    }

    func updateFuel() {
        fuelLabel.text = "Fuel: \(Int(ship.fuel))"
    }

    func menu(gameOverLabelPosition: CGPoint, restartLabelPosition: CGPoint) {
        // Показать метку "Game Over"
        gameOverLabel = SKLabelNode(fontNamed: "Helvetica")
        gameOverLabel?.fontSize = 50
        gameOverLabel?.fontColor = UIColor.red
        gameOverLabel?.position = gameOverLabelPosition
        gameOverLabel?.text = "Game Over"
        gameOverLabel?.zPosition = 1
        scene.addChild(gameOverLabel!)

        // Показать кнопку "Restart"
        restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel?.fontSize = 40
        restartLabel?.fontColor = UIColor.green
        restartLabel?.position = restartLabelPosition
        restartLabel?.text = "Restart"
        restartLabel?.zPosition = 1
        scene.addChild(restartLabel!)

        // Кнопка "Main Menu"
        let mainMenuLabel = SKLabelNode(fontNamed: "Helvetica")
        mainMenuLabel.name = "mainMenuButton"
        mainMenuLabel.fontSize = 40
        mainMenuLabel.fontColor = UIColor.white
        mainMenuLabel.position = CGPoint(x: 0, y: restartLabelPosition.y - 60)
        mainMenuLabel.text = "Main Menu"
        mainMenuLabel.zPosition = 2  // Устанавливаем zPosition выше остальных
        scene.addChild(mainMenuLabel)
    }

    func removeMenu() {
        gameOverLabel?.removeFromParent()
        restartLabel?.removeFromParent()
        if let mainMenuButton = scene.childNode(withName: "mainMenuButton") {
            mainMenuButton.removeFromParent()
        }
    }

    func resetHUD() {
        ship.score = 0
        ship.lives = 3
        ship.fuel = 100
        updateHUD()
    }

    func handleTouch(at location: CGPoint) {
        let nodesAtPoint = scene.nodes(at: location)
        for node in nodesAtPoint {
            if let restartLabel = restartLabel, node == restartLabel {
                print("Restart button tapped")
                onRestart?()
                return
            } else if node.name == "mainMenuButton" {
                print("Main Menu button tapped")
                if let gameScene = scene as? GameScene {
                    gameScene.showMainMenu()
                }
                return
            }
        }
    }
}
