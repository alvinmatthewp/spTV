//
//  AppReducer.swift
//  spTV
//
//  Created by alvin.pratama on 30/09/21.
//

import Foundation
import ComposableArchitecture
import SuperPlayer

struct AppState: Equatable {
    var superPlayerState: SuperPlayerState = .init()
}

enum AppAction: Equatable {
    case loadVideo
    case handlePausePlayVideo
    
    case superPlayerAction(SuperPlayerAction)
}

struct AppEnvironment {
    var getVideoURLString: () -> String
    
    static var mock = AppEnvironment(
        getVideoURLString: {
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        }
    )
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    superPlayerReducer
        .pullback(
            state: \.superPlayerState,
            action: /AppAction.superPlayerAction,
            environment: { _ in SuperPlayerEnvironment.live() }
        ),
    Reducer { state, action, env in
        switch action {
        case .loadVideo:
            return Effect(value: .superPlayerAction(.load(URL(string: env.getVideoURLString())!, autoPlay: true)))
            
        case .handlePausePlayVideo:
            let method = state.superPlayerState.player.method
            return method == .pause
                ? Effect(value: .superPlayerAction(.player(.callMethod(.play))))
                : Effect(value: .superPlayerAction(.player(.callMethod(.pause))))
            
        default:
            return .none
        }
    }
)
