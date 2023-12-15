import Foundation
import Graphiti
import ServerKit

final class GreeterSchema: GraphQLPartialSchema {
    @TypeDefinitions
    public override var types: Types {
        Scalar(Date.self, as: "DateTime")
    }

    @FieldDefinitions
    public override var query: Fields {
        Field("greet", at: GraphQLResolver.greet) {
            Argument("name", at: \.name)
        }
        Field("now", at: GraphQLResolver.now)
    }
}

extension GraphQLResolver {
    struct GreetArguments: Codable {
        let name: String
    }

    func greet(context: GraphQLContext, args: GreetArguments) -> String {
        return "Hello \(args.name)"
    }

    func now(context: GraphQLContext, args: NoArguments) -> Date {
        return Date.now
    }
}
