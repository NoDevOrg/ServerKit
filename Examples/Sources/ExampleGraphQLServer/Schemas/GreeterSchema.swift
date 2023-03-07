import Graphiti
import ServerKit

final class GreeterSchema: GraphQLPartialSchema {
    @FieldDefinitions
    public override var query: Fields {
        Field("greet", at: GraphQLResolver.greet) {
            Argument("name", at: \.name)
        }
    }
}

extension GraphQLResolver {
    struct GreetArguments: Codable {
        let name: String
    }

    func greet(context: GraphQLContext, args: GreetArguments) -> String {
        return "Hello \(args.name)"
    }
}
