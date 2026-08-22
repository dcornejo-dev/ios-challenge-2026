//
//  MoyaProvider+Extensions.swift
//  ApplaudoChallenge
//
//  Created by Christian Rivera on 26/3/26.
//

import Moya

extension MoyaProvider {
    // MARK: - Custom Networking Provider
    /// Factory method that returns the shared `MoyaProvider<MultiTarget>` used by `NetworkingRequester`.
    /// Modify the session configuration or add plugins here as your networking requirements grow.
    static func networkingProvider() -> MoyaProvider<MultiTarget> {
        let networkingSession: Session = .init(configuration: .default)
        var plugins: [PluginType] = []
        #if DEBUG
        plugins.append(NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)))
        #endif

        return MoyaProvider<MultiTarget>(session: networkingSession, plugins: plugins)
    }
}
