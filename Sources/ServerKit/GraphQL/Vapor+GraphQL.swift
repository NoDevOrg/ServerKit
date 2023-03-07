import Graphiti
import GraphQL
import Vapor

public typealias GraphQLPartialSchema = PartialSchema<GraphQLResolver, GraphQLContext>

extension Application {
    public struct GraphQL {
        let application: Application
    }

    public var graphql: GraphQL { GraphQL(application: self) }
}

extension Application.GraphQL {
    public struct Server {
        let application: Application
    }

    public var server: Server { Server(application: application) }
}

extension Application.GraphQL {
    public struct Configuration {
        public var path: PathComponent = ""
        public var playgroundPath: PathComponent = "graphql"
        public var playgroundType: PlaygroundType = .apollo
        var builder = SchemaBuilder(GraphQLResolver.self, GraphQLContext.self)
        var api: GraphQLAPI?

        public enum PlaygroundType {
            case apollo
            case graphiql
        }

        public mutating func use(partials: [GraphQLPartialSchema]) {
            builder = builder.use(partials: partials)
        }

        public mutating func use(partial: GraphQLPartialSchema) {
            builder = builder.use(partials: [partial])
        }
    }

    struct ConfigurationKey: StorageKey {
        typealias Value = Configuration
    }

    public var configuration: Configuration {
        get { application.storage[ConfigurationKey.self] ?? Configuration() }
        nonmutating set { application.storage[ConfigurationKey.self] = newValue }
    }

    public func configureApplication() throws {
        application.on(.POST, configuration.path, use: executeGraphQLOperation)
        application.on(.GET, configuration.playgroundPath, use: playground)
        configuration.api = GraphQLAPI(
            resolver: GraphQLResolver(application: application),
            schema: try configuration.builder.build())
    }

    func executeGraphQLOperation(request: Request) async throws -> GraphQLResult {
        guard let api = configuration.api else {
            // This will happen if `configureApplication` is not called before trying to query the server.
            throw Abort(.internalServerError, reason: "GraphQL API not available.")
        }

        return try await api.execute(
            request: request.graphql.query,
            context: GraphQLContext(request: request),
            on: application.eventLoopGroup)
    }

    func playground(request: Request) async throws -> Response {
        Response(status: .ok,
                 headers: HTTPHeaders([(HTTPHeaders.Name.contentType.description, "text/html")]),
                 body: Response.Body(string: {
            switch configuration.playgroundType {
            case .apollo:
                return apolloSandbox(path: configuration.path.description)
            case .graphiql:
                return graphiql(path: configuration.path.description)
            }
        }()))
    }
}

extension Application.GraphQL.Server {
    public var configuration: HTTPServer.Configuration {
        get { application.http.server.configuration }
        nonmutating set { application.http.server.configuration = newValue }
    }
}
