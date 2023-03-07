import GraphQL
import Vapor

extension Request {
    var graphql: GraphQLRequest {
        get throws {
            switch self.method {
            case .POST:
                return try content.decode(GraphQLRequest.self)
            default:
                throw Abort(.badRequest, reason: "Only POST requests are allowed for GraphQL")
            }
        }
    }
}
