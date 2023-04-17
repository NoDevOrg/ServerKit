import GRPC
import Vapor
import ServerKit

final class GreeterProvider: Example_GreeterAsyncProvider {
    init() {}

    func greet(request: Example_GreeterRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> Example_GreeterReply {
        guard !request.name.isEmpty else {
            throw GRPCStatus(code: .invalidArgument, message: "name cannot be empty")
        }

        return Example_GreeterReply.with {
            $0.message = "Hello \(request.name)"
        }
    }
}

extension GreeterProvider: Example_GreeterServerInterceptorFactoryProtocol {
    var interceptors: Example_GreeterServerInterceptorFactoryProtocol? { self }

    func makeGreetInterceptors() -> [ServerInterceptor<Example_GreeterRequest, Example_GreeterReply>] {
        [LoggingInterceptor()]
    }
}
