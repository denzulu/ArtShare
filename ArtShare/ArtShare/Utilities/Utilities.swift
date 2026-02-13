//
//  Utilities.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 03.12.2024..
//

import Foundation
import SwiftUI

final class Utilities {
    static let shared = Utilities()
    private init() {}

    func currentViewController(completion: @escaping (UIViewController?) -> Void) {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
        
        if let rootViewController = keyWindow?.rootViewController {
            DispatchQueue.main.async {
                completion(self.findTopViewController(rootViewController))
            }
        } else {
            completion(nil)
        }
    }

    private func findTopViewController(_ viewController: UIViewController?) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return findTopViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController,
           let selected = tab.selectedViewController {
            return findTopViewController(selected)
        }
        if let presented = viewController?.presentedViewController {
            return findTopViewController(presented)
        }
        return viewController
    }
}
