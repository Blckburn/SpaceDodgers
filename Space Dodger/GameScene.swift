import SpriteKit
import Foundation

class GameScene: SKScene, SKPhysicsContactDelegate {

    var ship: Ship!
    var hud: HUD!
    var isTouching = false

    // Массивы для хранения метеоритов и бонусов топлива
    var meteors: [SKSpriteNode] = []
    var fuelBonuses: [FuelBonus] = []

    // Переменные состояния
    var gameIsOver = false
    var isMenuActive = true
    var isShowingLadderBoard = false

    var mainMenu: MainMenu!
    var collisionHandler: CollisionHandler!
    var spawner: GameObjectSpawner!

    // Переменные для управления бонусами топлива
    var fuelBonusDisabledUntil: TimeInterval = 0
    var fuelBonusTimer: Timer?

    // Чёрная дыра
    var blackHole: SKSpriteNode!

    // Коллекция для отслеживания обработанных метеоритов
    var contactedMeteors: Set<SKNode> = []

    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsWorld.contactDelegate = self

        collisionHandler = CollisionHandler(scene: self)
        spawner = GameObjectSpawner(scene: self)

        showMainMenu()
    }

    func showMainMenu() {
        removeAllChildren()
        removeAllActions()
        isMenuActive = true
        gameIsOver = false
        mainMenu = MainMenu(scene: self)
    }

    func startGame() {
        isMenuActive = false
        gameIsOver = false
        setupGame()
    }

    func setupGame() {
        removeAllChildren()
        removeAllActions()

        // Устанавливаем фон
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1
        addChild(background)

        // Создаём чёрную дыру
        blackHole = SKSpriteNode(imageNamed: "blackhole")
        blackHole.name = "blackHole"
        blackHole.setScale(Constants.blackHoleScale)
        blackHole.position = CGPoint(x: 0, y: -size.height / 2 + blackHole.size.height / 2)
        blackHole.zPosition = 0
        addChild(blackHole)

        // Добавляем физическое тело к чёрной дыре
        blackHole.physicsBody = SKPhysicsBody(circleOfRadius: blackHole.size.width / 2)
        blackHole.physicsBody?.isDynamic = false
        blackHole.physicsBody?.affectedByGravity = false
        blackHole.physicsBody?.categoryBitMask = PhysicsCategory.blackHole
        blackHole.physicsBody?.contactTestBitMask = PhysicsCategory.ship
        blackHole.physicsBody?.collisionBitMask = 0

        // Создаем корабль
        ship = Ship()
        ship.setupShip(scene: self)

        // Создаем HUD
        hud = HUD(scene: self, ship: ship, onRestart: { [weak self] in
            self?.restartGame()
        })
        ship.hud = hud

        // Запускаем спавнер объектов
        spawner.startSpawning()

        // Запускаем обновление очков
        let scoreUpdateAction = SKAction.run { [weak self] in
            self?.ship.score += 1
            self?.hud.updateScore()
        }
        let scoreDelay = SKAction.wait(forDuration: Constants.scoreUpdateInterval)
        let scoreSequence = SKAction.sequence([scoreUpdateAction, scoreDelay])
        run(SKAction.repeatForever(scoreSequence), withKey: "updateScore")

        // Запускаем уменьшение топлива
        ship.startFuelConsumption()
    }

    func createMeteor() {
        // Получаем высоту HUD
        let hudHeight = hud?.hudHeight ?? 0
        let maxY = (size.height / 2) - hudHeight - 10
        let minY = blackHole.position.y + blackHole.size.height / 2 + 20

        let meteor = SKSpriteNode(imageNamed: "meteor")

        // Устанавливаем случайный масштаб от 50% до 100%
        let randomScale = CGFloat.random(in: 0.5...1.0)
        meteor.setScale(randomScale)

        // Устанавливаем случайный поворот
        let randomRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
        meteor.zRotation = randomRotation

        meteor.position = CGPoint(x: size.width / 2 + meteor.size.width, y: CGFloat.random(in: minY...maxY))
        meteor.zPosition = 0
        addChild(meteor)

        // Добавляем анимацию вращения с случайной скоростью и направлением
        let randomRotateDuration = TimeInterval(CGFloat.random(in: 1.0...3.0))
        let rotationDirection = Bool.random() ? 1.0 : -1.0
        let rotateAction = SKAction.rotate(byAngle: rotationDirection * CGFloat.pi * 2, duration: randomRotateDuration)
        let repeatRotate = SKAction.repeatForever(rotateAction)
        meteor.run(repeatRotate)

        // Добавляем физическое тело
        meteor.physicsBody = SKPhysicsBody(texture: meteor.texture!, size: meteor.size)
        meteor.physicsBody?.isDynamic = false
        meteor.physicsBody?.affectedByGravity = false
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor
        meteor.physicsBody?.contactTestBitMask = PhysicsCategory.ship
        meteor.physicsBody?.collisionBitMask = 0

        meteors.append(meteor)

        // Изменяем скорость метеорита в зависимости от его размера
        let baseDuration: TimeInterval = 3.0
        let moveDuration = baseDuration * Double(randomScale)

        let moveAction = SKAction.moveTo(x: -size.width / 2 - meteor.size.width, duration: moveDuration)
        let removeAction = SKAction.run { [weak self] in
            meteor.removeFromParent()
            self?.meteors.removeAll { $0 == meteor }
        }
        meteor.run(SKAction.sequence([moveAction, removeAction]))
    }

    func createFuelBonus() {
        let currentTime = CACurrentMediaTime()
        if currentTime < fuelBonusDisabledUntil {
            // Не создаем бонус топлива, так как они отключены
            return
        }

        let fuelBonus = FuelBonus()

        // Случайное количество топлива: 5, 10 или 15
        let possibleAmounts = [5, 10, 15]
        fuelBonus.amount = possibleAmounts.randomElement() ?? 10

        // Устанавливаем размер канистры в зависимости от количества топлива
        let scaleFactor: CGFloat
        switch fuelBonus.amount {
        case 5:
            scaleFactor = 0.5
        case 10:
            scaleFactor = 1.0
        case 15:
            scaleFactor = 1.5
        default:
            scaleFactor = 1.0
        }
        fuelBonus.node.setScale(scaleFactor)

        // Устанавливаем позицию бонуса топлива
        let hudHeight = hud?.hudHeight ?? 0
        let maxY = (size.height / 2) - hudHeight - 20
        let minY = blackHole.position.y + blackHole.size.height / 2 + 20
        let randomY = CGFloat.random(in: minY...maxY)

        fuelBonus.node.position = CGPoint(x: size.width / 2 + fuelBonus.node.size.width, y: randomY)
        fuelBonus.node.zPosition = 0
        addChild(fuelBonus.node)

        fuelBonuses.append(fuelBonus)

        // Движение бонуса топлива
        let moveDuration = TimeInterval(4.0)
        let moveAction = SKAction.moveTo(x: -size.width / 2 - fuelBonus.node.size.width, duration: moveDuration)
        let removeAction = SKAction.run { [weak self] in
            fuelBonus.node.removeFromParent()
            self?.fuelBonuses.removeAll { $0 === fuelBonus }
        }
        fuelBonus.node.run(SKAction.sequence([moveAction, removeAction]))
    }

    func scheduleFuelBonus() {
        // Запускаем планирование следующего бонуса топлива
        let randomDelay = TimeInterval.random(in: Constants.fuelBonusSpawnIntervalRange)
        let waitAction = SKAction.wait(forDuration: randomDelay)
        let spawnAction = SKAction.run { [weak self] in
            self?.createFuelBonus()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        run(sequence, withKey: "scheduleFuelBonus")
    }

    func showLadderBoard() {
        isShowingLadderBoard = true
        removeAllChildren()
        removeAllActions()

        // Устанавливаем фон
        let background = SKSpriteNode(color: .black, size: self.size)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1
        addChild(background)

        // Заголовок
        let titleLabel = SKLabelNode(fontNamed: "Helvetica")
        titleLabel.fontSize = 50
        titleLabel.fontColor = UIColor.white
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 100)
        titleLabel.text = "Leaderboard"
        titleLabel.zPosition = 1
        addChild(titleLabel)

        // Загрузка рекордов
        let leaderboard = LadderBoard.shared.loadScores()

        // Проверяем, есть ли записи в таблице рекордов
        if leaderboard.isEmpty {
            let noDataLabel = SKLabelNode(fontNamed: "Helvetica")
            noDataLabel.fontSize = 30
            noDataLabel.fontColor = UIColor.white
            noDataLabel.position = CGPoint(x: 0, y: 0)
            noDataLabel.text = "No scores yet."
            noDataLabel.zPosition = 1
            addChild(noDataLabel)
        } else {
            // Отображение рекордов
            let startY = titleLabel.position.y - 80
            let entryHeight: CGFloat = 40

            for (index, entry) in leaderboard.enumerated() {
                let entryLabel = SKLabelNode(fontNamed: "Helvetica")
                entryLabel.fontSize = 30
                entryLabel.fontColor = UIColor.white
                entryLabel.horizontalAlignmentMode = .center
                entryLabel.position = CGPoint(x: 0, y: startY - CGFloat(index) * entryHeight)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let dateString = dateFormatter.string(from: entry.date)
                entryLabel.text = "\(index + 1). Score: \(entry.score) - \(dateString)"
                entryLabel.zPosition = 1
                addChild(entryLabel)
            }
        }

        // Кнопка "Main Menu"
        let backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.name = "mainMenuButton"
        backButton.fontSize = 40
        backButton.fontColor = UIColor.green
        backButton.position = CGPoint(x: 0, y: -size.height / 2 + 150)
        backButton.text = "Main Menu"
        backButton.zPosition = 2
        addChild(backButton)
    }

    func hideLadderBoard() {
        isShowingLadderBoard = false
        showMainMenu()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isMenuActive {
            mainMenu.handleTouch(at: location)
        } else if isShowingLadderBoard {
            let touchedNodes = nodes(at: location)
            for node in touchedNodes {
                if node.name == "mainMenuButton" {
                    hideLadderBoard()
                    return
                }
            }
        } else if gameIsOver {
            hud.handleTouch(at: location)
        } else {
            isTouching = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }

    func didBegin(_ contact: SKPhysicsContact) {
        collisionHandler.didBegin(contact)
    }

    // Методы для обработки конкретных столкновений
    func handleShipMeteorCollision(meteorBody: SKPhysicsBody) {
        if let meteorNode = meteorBody.node as? SKSpriteNode {
            if !contactedMeteors.contains(meteorNode) {
                contactedMeteors.insert(meteorNode)
                meteorNode.removeFromParent()
                meteors.removeAll { $0 == meteorNode }
                ship.lives -= 1
                hud.updateLives()
                if ship.lives <= 0 {
                    gameOver()
                }
            }
        }
    }

    func handleShipFuelCollision(fuelBody: SKPhysicsBody) {
        if let fuelNode = fuelBody.node as? SKSpriteNode {
            fuelNode.removeFromParent()
            if let index = fuelBonuses.firstIndex(where: { $0.node == fuelNode }) {
                let fuelBonus = fuelBonuses[index]
                ship.addFuel(amount: fuelBonus.amount)
                fuelBonuses.remove(at: index)
            }
        }
    }

    func handleShipBlackHoleCollision() {
        if !gameIsOver {
            ship.lives = 0
            gameOver()
        }
    }

    func gameOver() {
        if gameIsOver { return }
        gameIsOver = true

        // Останавливаем действия
        removeAllActions()
        ship.stopFuelConsumption()

        // Останавливаем спавнер объектов
        spawner.stopSpawning()

        // Останавливаем таймер бонусов топлива
        fuelBonusTimer?.invalidate()
        fuelBonusTimer = nil

        // Очищаем коллекцию обработанных метеоритов
        contactedMeteors.removeAll()

        // Сохраняем текущий счёт в таблицу рекордов
        LadderBoard.shared.saveScore(ship.score)

        // Вызываем меню из HUD
        hud.menu(gameOverLabelPosition: CGPoint(x: 0, y: 100), restartLabelPosition: CGPoint(x: 0, y: 0))
    }

    func restartGame() {
        hud.removeMenu()
        hud.resetHUD()

        // Удаляем метеориты
        for meteor in meteors {
            meteor.removeFromParent()
        }
        meteors.removeAll()

        // Удаляем бонусы топлива
        for fuelBonus in fuelBonuses {
            fuelBonus.node.removeFromParent()
        }
        fuelBonuses.removeAll()

        // Останавливаем таймер бонусов топлива
        fuelBonusTimer?.invalidate()
        fuelBonusTimer = nil

        // Очищаем коллекцию обработанных метеоритов
        contactedMeteors.removeAll()

        // Сбрасываем переменные состояния
        gameIsOver = false
        isTouching = false

        // Удаляем корабль
        ship.node.removeFromParent()
        ship = nil

        // Перезапускаем игру
        setupGame()
    }

    override func update(_ currentTime: TimeInterval) {
        if !gameIsOver && !isMenuActive {
            ship.updateShip(isTouching: isTouching)

            // Проверка уровня топлива
            if ship.fuel <= 0 {
                gameOver()
            }

            // Проверка, достиг ли корабль максимального топлива
            if ship.fuel >= ship.maxFuel {
                if fuelBonusDisabledUntil < currentTime {
                    // Топливо только что достигло максимума
                    fuelBonusDisabledUntil = currentTime + TimeInterval(CGFloat.random(in: 10.0...20.0))
                    // Перепланируем генерацию бонусов топлива
                    scheduleFuelBonus()
                }
            }
        }
    }
}
