import Graphiti
import ServerKit

final class GreeterSchema: GraphQLPartialSchema {
    @FieldDefinitions
    override var query: Fields {
        Field("greet", at: GraphQLResolver.greet) {
            Argument("name", at: \.name)
        }
    }
}

extension GraphQLResolver {
    struct GreetArguments: Codable {
        let name: String
    }

    struct GreetError: Error, CustomStringConvertible {
        let description: String
    }

    func greet(context: GraphQLContext, args: GreetArguments) async throws -> String {
        guard !args.name.isEmpty else {
            throw GreetError(description: "name cannot be empty")
        }

        return "Hello \(args.name)"
    }
}
