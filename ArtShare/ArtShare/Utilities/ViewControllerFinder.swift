//
//  ViewControllerFinder.swift
//  ArtShare
//
//  Created by Huseyin D. Ulu (RIT Student) on 08.12.2024..
//


import SwiftUI

struct ViewControllerFinder: UIViewControllerRepresentable {
    var callback: (UIViewController?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            self.callback(viewController.presentingViewController)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
