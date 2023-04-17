import GRPC
import Vapor

public final class DualServer {
    private let application: Application
    private var didStart: Bool = false
    private var didShutdown: Bool = false

    init(application: Application) {
        self.application = application
    }

    deinit {
        assert(!didStart || didShutdown, "DualServer did not shutdown before deinitializing")
    }
}

extension DualServer: Vapor.Server {
    public func start(address: BindAddress?) throws {
        try application.grpc.server.shared.start(address: address)
        try application.http.server.shared.start(address: address)
    }

    public var onShutdown: EventLoopFuture<Void> {
        let servers: [Vapor.Server] = [
            application.grpc.server.shared,
            application.http.server.shared
        ]

        return servers.sequencedFlatMapEach(on: application.eventLoopGroup.next()) { server in
            server.onShutdown
        }
    }

    public func shutdown() {
        application.grpc.server.shared.shutdown()
        application.http.server.shared.shutdown()
    }
}
