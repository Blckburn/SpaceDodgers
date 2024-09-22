import SpriteKit
import Foundation

class CollisionHandler {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let scene = scene else { return }
        // Логика обработки столкновений
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == PhysicsCategory.ship && secondBody.categoryBitMask == PhysicsCategory.meteor {
            scene.handleShipMeteorCollision(meteorBody: secondBody)
        }

        if firstBody.categoryBitMask == PhysicsCategory.ship && secondBody.categoryBitMask == PhysicsCategory.fuel {
            scene.handleShipFuelCollision(fuelBody: secondBody)
        }

        if firstBody.categoryBitMask == PhysicsCategory.ship && secondBody.categoryBitMask == PhysicsCategory.blackHole {
            scene.handleShipBlackHoleCollision()
        }
    }
}
