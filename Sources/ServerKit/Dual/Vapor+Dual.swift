import Vapor

extension Application {
    public struct Dual {
        let application: Application
    }

    public var dual: Dual { Dual(application: self) }
}

extension Application.Dual {
    public struct Server {
        let application: Application
    }

    public var server: Server { Server(application: application) }
}

extension Application.Dual.Server {
    struct ServerKey: StorageKey {
        typealias Value = DualServer
    }

    var shared: DualServer {
        if let existing = application.storage[ServerKey.self] {
            return existing
        } else {
            let new = DualServer(application: application)
            application.storage[ServerKey.self] = new
            return new
        }
    }
}

extension Application.Servers.Provider {
    public static var dual: Self {
        Application.Servers.Provider { application in
            application.servers.use { application in
                application.dual.server.shared
            }
        }
    }
}
