import ServerKit
import Graphiti
import Vapor

let environment = try Environment.detect()
let application = Application(environment)

application.graphql.configuration.use(partial: GreeterSchema())
try application.graphql.configuration.loadFederationSDL(bundle: .module, resource: "Greeter", subdirectory: "IDL/graphql")
application.graphql.server.configuration.address = .hostname("0.0.0.0", port: 4001)
try application.graphql.configureApplication()

defer { application.shutdown() }
try application.run()

