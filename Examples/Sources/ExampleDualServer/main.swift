import ServerKit
import Vapor

let environment = try Environment.detect()
let application = Application(environment)

application.servers.use(.dual)

// Configure GRPC
application.grpc.server.configuration.target = .hostAndPort("0.0.0.0", 9080)
application.grpc.server.configuration.logger = application.logger
application.grpc.server.configuration.serviceProviders = [
    GreeterProvider()
]

// Configure GraphQL
application.graphql.server.configuration.address = .hostname("0.0.0.0", port: 8080)
application.graphql.configuration.use(partials: [
    GreeterSchema()
])
try application.graphql.configureApplication()

defer { application.shutdown() }
try application.run()
