import GraphQL
import Vapor

extension GraphQLError {
    func response(using response: Response) throws -> Response {
        if response.status == .ok {
            response.status = .internalServerError
        }
        try response.content.encode(GraphQLResult(errors: [self]))
        return response
    }
}

extension GraphQLResult: Content {}
