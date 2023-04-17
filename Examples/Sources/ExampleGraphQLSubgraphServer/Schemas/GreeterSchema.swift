import Foundation
import Graphiti
import ServerKit

final class GreeterSchema: GraphQLPartialSchema {
    @TypeDefinitions
    override var types: PartialSchema<GraphQLResolver, GraphQLContext>.Types {
        Type(Person.self) {
            Field("id", at: \.id)
            Field("name", at: \.name)
        }
        .key(at: GraphQLResolver.personResolver) {
            Argument("id", at: \.id)
        }
    }

    @FieldDefinitions
    override var query: PartialSchema<GraphQLResolver, GraphQLContext>.Fields {
        Field("greetList", at: GraphQLResolver.greetList)
    }

    @FieldDefinitions
    override var mutation: PartialSchema<GraphQLResolver, GraphQLContext>.Fields {
        Field("greet", at: GraphQLResolver.greet) {
            Argument("name", at: \.name)
        }
    }
}

struct Person: Codable {
    let id: String
    let name: String

    struct Key: Codable {
        let id: String
    }
}

extension GraphQLResolver {
    func personResolver(context: GraphQLContext, arguments: Person.Key) async -> Person? {
        await application.greeter.manager.person(id: arguments.id)
    }

    func greetList(context: GraphQLContext, arguments: NoArguments) async -> [Person] {
        await application.greeter.manager.people
    }

    struct GreetArguments: Codable {
        let name: String
    }

    func greet(context: GraphQLContext, arguments: GreetArguments) async -> Person {
        await application.greeter.manager.greet(name: arguments.name)
    }
}
