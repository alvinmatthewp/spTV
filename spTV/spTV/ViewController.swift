//
//  ViewController.swift
//  spTV
//
//  Created by alvin.pratama on 30/09/21.
//

import UIKit
import ComposableArchitecture
import SuperPlayer
import Combine

class ViewController: UIViewController {
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        return spinner
    }()
    
    lazy var playerControl: PlayerControlView = {
        let control = PlayerControlView(store: store.scope(
            state: \.superPlayerState.control,
            action: AppAction.superPlayerAction
        ))
        return control
    }()
    
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment.mock
    )
    lazy var viewStore = ViewStore(self.store)

    var disposeBag = Array<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleVideo(store: store.scope(
            state: \.superPlayerState,
            action: AppAction.superPlayerAction
        ))
        
        setupView()
        
        viewStore.send(.loadVideo)
        
        playerControl.playButtonTapped
            .sink(receiveValue: { [weak self] _ in
                self?.viewStore.send(.handlePausePlayVideo)
            })
            .store(in: &disposeBag)
    }
    
    func handleVideo(store: Store<SuperPlayerState, SuperPlayerAction>) {
        let superPlayer = SuperPlayerViewController(store: store)
        superPlayer.view.frame = view.frame
        superPlayer.view.backgroundColor = .black
        
        addChild(superPlayer)
        view.addSubview(superPlayer.view)
        superPlayer.didMove(toParent: self)
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

