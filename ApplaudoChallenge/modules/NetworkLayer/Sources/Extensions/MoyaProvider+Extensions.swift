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
        // Configure the underlying URLSession; swap `.default` for a custom configuration if needed (e.g., background sessions).
        let networkingSession: Session = .init(configuration: .default)
        // Logs full request and response details to the console — reduce verbosity for non-debug builds.
        let loggerPlugin: PluginType = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let plugins: [PluginType] = [loggerPlugin]  // Add authentication, retry, or caching plugins here if needed.

        return MoyaProvider<MultiTarget>(session: networkingSession, plugins: plugins)
    }
}
