import SpriteKit
import Foundation

class GameObjectSpawner {
    weak var scene: GameScene?

    init(scene: GameScene) {
        self.scene = scene
    }

    func startSpawning() {
        spawnMeteors()
        scheduleFuelBonus()
    }

    func stopSpawning() {
        scene?.removeAction(forKey: "spawnMeteors")
        scene?.removeAction(forKey: "spawnFuelBonuses")
    }

    private func spawnMeteors() {
        let spawnMeteor = SKAction.run { [weak self] in
            self?.scene?.createMeteor()
        }
        let meteorDelay = SKAction.wait(forDuration: Constants.meteorSpawnInterval)
        let meteorSequence = SKAction.sequence([spawnMeteor, meteorDelay])
        scene?.run(SKAction.repeatForever(meteorSequence), withKey: "spawnMeteors")
    }

    private func scheduleFuelBonus() {
        let initialDelay = SKAction.wait(forDuration: Constants.fuelBonusInitialDelay)
        let spawnFuelBonus = SKAction.run { [weak self] in
            self?.scene?.createFuelBonus()
        }
        let randomDelay = SKAction.wait(forDuration: TimeInterval.random(in: Constants.fuelBonusSpawnIntervalRange))
        let fuelBonusSequence = SKAction.sequence([spawnFuelBonus, randomDelay])
        let repeatFuelBonus = SKAction.repeatForever(fuelBonusSequence)
        let fullSequence = SKAction.sequence([initialDelay, repeatFuelBonus])
        scene?.run(fullSequence, withKey: "spawnFuelBonuses")
    }
}
