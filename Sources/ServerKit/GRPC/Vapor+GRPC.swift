import GRPC
import Vapor

extension Application {
    public struct GRPC {
        let application: Application
    }

    public var grpc: GRPC { GRPC(application: self) }
}

extension Application.GRPC {
    public struct Server {
        let application: Application
    }

    public var server: Server { Server(application: application) }
}

extension Application.GRPC.Server {
    struct ConfigurationKey: StorageKey {
        typealias Value = GRPC.Server.Configuration
    }

    struct ServerKey: StorageKey {
        typealias Value = GRPCServer
    }

    public var configuration: GRPC.Server.Configuration {
        get {
            application.storage[ConfigurationKey.self] ??
                .default(target: .hostAndPort("0.0.0.0", 80),
                         eventLoopGroup: application.eventLoopGroup,
                         serviceProviders: [])
        }

        nonmutating set {
            guard !application.storage.contains(ServerKey.self) else {
                application.logger.warning("GRPCServer: Cannot modify server configuration after server initializes")
                return
            }

            application.storage[ConfigurationKey.self] = newValue
        }
    }

    var shared: GRPCServer {
        if let existing = application.storage[ServerKey.self] {
            return existing
        } else {
            let new = GRPCServer(configuration: configuration, application: application)
            application.storage[ServerKey.self] = new
            return new
        }
    }
}

extension Application.Servers.Provider {
    public static var grpc: Self {
        Application.Servers.Provider { (application) in
            application.servers.use { (application) in
                application.grpc.server.shared
            }
        }
    }
}
