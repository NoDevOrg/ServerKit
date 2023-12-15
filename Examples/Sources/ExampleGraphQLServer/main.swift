import ServerKit
import Graphiti
import Vapor

let environment = try Environment.detect()
let application = Application(environment)

let coders = Coders()
coders.decoder.dateDecodingStrategy = .iso8601
coders.encoder.dateEncodingStrategy = .iso8601
application.graphql.configuration.use(coders: coders)
application.graphql.configuration.use(partial: GreeterSchema())

application.graphql.server.configuration.address = .hostname("0.0.0.0", port: 4001)
try application.graphql.configureApplication()

defer { application.shutdown() }
try application.run()
