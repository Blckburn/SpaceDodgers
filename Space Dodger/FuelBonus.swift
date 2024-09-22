import SpriteKit

class FuelBonus {
    var node: SKSpriteNode!
    var amount: Int = 10

    init() {
        node = SKSpriteNode(imageNamed: "fuel")
        node.name = "fuelBonus"

        // Добавляем физическое тело
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.fuel
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ship
        node.physicsBody?.collisionBitMask = 0
        node.zPosition = 0
    }
}
