import SpriteKit
import Foundation

struct PhysicsCategory {
    static let ship: UInt32 = 0x1 << 0
    static let meteor: UInt32 = 0x1 << 1
    static let fuel: UInt32 = 0x1 << 2
    static let blackHole: UInt32 = 0x1 << 3
}
