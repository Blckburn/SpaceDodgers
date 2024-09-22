
import UIKit
import SpriteKit
// import GameKit  // Пока закомментируем

class GameViewController: UIViewController /*, GKGameCenterControllerDelegate */ {

    override func viewDidLoad() {
        super.viewDidLoad()

        // authenticateLocalPlayer()  // Пока закомментируем

        if let view = self.view as! SKView? {
            // Создаем экземпляр GameScene программно
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill  // Устанавливаем масштабирование

            // Present the scene
            view.presentScene(scene)

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    // Закомментируем методы, связанные с Game Center
    /*
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] (viewController, error) in
            if let viewController = viewController {
                self?.present(viewController, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                print("Игрок аутентифицирован в Game Center")
            } else {
                print("Игрок не аутентифицирован в Game Center")
                if let error = error {
                    print("Ошибка аутентификации: \(error.localizedDescription)")
                }
            }
        }
    }

    func presentLeaderboard() {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .leaderboards
        gcViewController.leaderboardIdentifier = "your_leaderboard_id"  // Замените на свой идентификатор
        present(gcViewController, animated: true, completion: nil)
    }

    // Реализация делегата GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    */

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
