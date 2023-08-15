//
//  tvOS-Example
//
//  Created by Max Sol on 10.08.2023.
//

import UIKit
import LeakChecker

class ViewModel {

    private var block: (() -> Void)?

    init() {
        block = {
            _ = self // make a retain cycle
        }
    }

}

class TestViewController: UIViewController {

    private var testObjectToLeak = NSObject()
    private var viewModel = ViewModel()

    deinit {
        checkLeak(of: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow

        checkLeak(of: testObjectToLeak, expectedDeallocationInterval: 0) // the object is being held at the time of check
    }

}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        let pushButton = UIButton()
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        pushButton.setTitle("🚰 Force memory leaks", for: .normal)
        pushButton.addTarget(self, action: #selector(onForceMemoryLeaks), for: .primaryActionTriggered)
        view.addSubview(pushButton)

        NSLayoutConstraint.activate([
            pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onForceMemoryLeaks()
    }

    @objc
    private func onForceMemoryLeaks() {
        let vc = TestViewController()
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }

}
