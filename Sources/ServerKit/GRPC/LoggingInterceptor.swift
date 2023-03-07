import GRPC
import Vapor
import SwiftProtobuf

public final class LoggingInterceptor<Request: Message, Response: Message>: ServerInterceptor<Request, Response> {
    public override func receive(_ part: GRPCServerRequestPart<Request>, context: ServerInterceptorContext<Request, Response>) {
        switch part {
        case .metadata, .end:
            break
        case .message(let message):
            context.logger.info("--> \(context.path) \(message.logging)")
        }

        context.receive(part)
    }

    public override func send(_ part: GRPCServerResponsePart<Response>, promise: EventLoopPromise<Void>?, context: ServerInterceptorContext<Request, Response>) {
        switch part {
        case .metadata:
            break
        case .message(let message, _):
            context.logger.info("<-- \(context.path) \(message.logging)")
        case .end(let status, _):
            if !status.isOk {
                context.logger.warning("<-- \(context.path) \(status.description)")
            }
        }

        context.send(part, promise: promise)
    }
}

extension Message {
    var logging: String { textFormatString().replacingOccurrences(of: "\n", with: " ") }
}
