//
//  UIApplication+Extensions.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 2. 02. 24.
//

import Foundation
import UIKit

// An old utility file that I reused. Ideally alerts and similar items
// would be presented via a centralized UI Controller which allows us a lot more
// flexible and error-free UI state management

public extension UIApplication {

    var activeWindowScene: UIWindowScene? {
        let activeScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive })
        return activeScene.compactMap({ $0 as? UIWindowScene }).first
    }

    var keyWin: UIWindow? {
        return self.activeWindowScene?.windows.first(where: { $0.isKeyWindow })
    }

    var baseWin: UIWindow? {
        return UIApplication.shared.delegate?.window ?? nil
    }

    func showAlert(title: String, message: String?) {
        self.showAlertController(title: title, message: message, completion: nil)
    }

    func showAlert(error: Error, completion: ((Bool) -> Void)? = nil) {
        if let completion = completion {
            self.showAlertController(title: "Error", message: error.localizedDescription, retryCta: "Try again") { action in
                completion(action == 2) // 2 is the retry CTA action handler
            }
        } else {
            self.showAlertController(title: "Error", message: error.localizedDescription)
        }
    }

    private func showAlertController(
        title: String,
        message: String?,
        defaultCta: String = "OK",
        retryCta: String? = nil,
        completion: ((Int) -> Void)? = nil
    ) {
        var topmostViewController: UIViewController? = self.keyWin?.frontmostViewController

        if topmostViewController == nil {
            topmostViewController = self.baseWin?.frontmostViewController
        }

        guard let viewController = topmostViewController, !(viewController is UIAlertController) else {
            print("Will not display alert (\(title)/\(String(describing: message)))) as there is an existing alert in place")
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: defaultCta, style: .default) { _ in
            completion?(1)
        })
        if let retryCta = retryCta {
            alert.addAction(UIAlertAction(title: retryCta, style: .cancel) { _ in
                completion?(2)
            })
        }
        viewController.present(alert, animated: true)
    }
}

private extension UIWindow {
    var frontmostViewController: UIViewController? {
        var frontViewController = self.rootViewController
        while frontViewController?.presentedViewController != nil {
            frontViewController = frontViewController?.presentedViewController
        }
        return frontViewController
    }
}
