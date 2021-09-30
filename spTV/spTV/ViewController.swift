//
//  ViewController.swift
//  spTV
//
//  Created by alvin.pratama on 30/09/21.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        return spinner
    }()
    
    let playerControl = PlayerControlView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        playerControl.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(spinner)
        view.addSubview(playerControl)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        playerControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playerControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerControl.heightAnchor.constraint(equalToConstant: PlayerControlView.height)
        ])
    }
}

