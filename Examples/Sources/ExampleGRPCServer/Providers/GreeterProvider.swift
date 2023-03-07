import GRPC
import ServerKit

final class GreeterProvider: Example_GreeterAsyncProvider {
    func greet(request: Example_GreeterRequest, context: GRPCAsyncServerCallContext) async throws -> Example_GreeterReply {
        Example_GreeterReply.with {
            $0.message = "Hello \(request.name)"
        }
    }
}

extension GreeterProvider: Example_GreeterServerInterceptorFactoryProtocol {
    func makeGreetInterceptors() -> [GRPC.ServerInterceptor<Example_GreeterRequest, Example_GreeterReply>] {
        [LoggingInterceptor()]
    }
}
