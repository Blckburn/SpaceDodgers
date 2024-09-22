import SpriteKit

class Ship {

    var node: SKSpriteNode!
    var fuel: Int = 100 {
        didSet {
            hud?.updateFuel()
        }
    }
    var maxFuel: Int = 100
    var lives: Int = 3 {
        didSet {
            hud?.updateLives()
        }
    }
    var score: Int = 0
    var hud: HUD?

    private var fuelConsumptionTimer: Timer?

    func setupShip(scene: SKScene) {
        node = SKSpriteNode(imageNamed: "ship")
        node.setScale(Constants.shipScale)
        let shipPositionX = -scene.size.width / 2 + node.size.width / 2 + 20
        let shipPositionY: CGFloat = 0
        node.position = CGPoint(x: shipPositionX, y: shipPositionY)
        scene.addChild(node)

        // Добавляем физическое тело
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.ship
        node.physicsBody?.contactTestBitMask = PhysicsCategory.meteor | PhysicsCategory.fuel | PhysicsCategory.blackHole
        node.physicsBody?.collisionBitMask = 0
    }

    func updateShip(isTouching: Bool) {
        node.physicsBody?.velocity.dx = 0

        if isTouching {
            node.position.y += 10
        } else {
            node.position.y -= 5
        }

        if let scene = node.scene {
            let hudHeight = hud?.hudHeight ?? 0
            let upperBound = (scene.size.height / 2) - hudHeight - node.size.height / 2 - 10
            let lowerBound = -scene.size.height / 2 + scene.size.height * 0.1 + node.size.height / 2

            if node.position.y <= lowerBound {
                node.position.y = lowerBound
                // Корабль достиг нижней границы
                if lives > 0 {
                    lives = 0
                    hud?.updateLives()
                    if let gameScene = scene as? GameScene {
                        gameScene.gameOver()
                    }
                }
            }

            if node.position.y > upperBound {
                node.position.y = upperBound
            }
        }
    }

    func startFuelConsumption() {
        stopFuelConsumption()

        fuelConsumptionTimer = Timer.scheduledTimer(withTimeInterval: Constants.fuelConsumptionInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.consumeFuel()
        }
    }

    func stopFuelConsumption() {
        fuelConsumptionTimer?.invalidate()
        fuelConsumptionTimer = nil
    }

    private func consumeFuel() {
        if fuel > 0 {
            fuel -= 1
        }

        if fuel < 0 {
            fuel = 0
        }

        print("Осталось топлива: \(fuel)")

        if fuel <= 0 {
            stopFuelConsumption()
        }
    }

    func addFuel(amount: Int) {
        fuel += amount
        if fuel > maxFuel {
            fuel = maxFuel
        }
        hud?.updateFuel()
    }
}
