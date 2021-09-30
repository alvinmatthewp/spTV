//
//  AppReducer.swift
//  spTV
//
//  Created by alvin.pratama on 30/09/21.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable { }

enum AppAction: Equatable { }

struct AppEnvironment { }

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
    switch action {
    default:
        return .none
    }
}
