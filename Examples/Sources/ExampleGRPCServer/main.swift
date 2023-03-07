import ServerKit
import Vapor

let environment = try Environment.detect()
let application = Application(environment)

application.servers.use(.grpc)
application.grpc.server.configuration.target = .hostAndPort("0.0.0.0", 9001)
application.grpc.server.configuration.logger = application.logger
application.grpc.server.configuration.serviceProviders = [
    GreeterProvider()
]

defer { application.shutdown() }
try application.run()
