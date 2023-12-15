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
    enum ConfigurationError: Error {
        case couldNotLoadFederationSDL
    }

    public struct Configuration {
        public var path: PathComponent = "graphql"
        public var playgroundPath: PathComponent = "graphql"
        public var playgroundType: PlaygroundType? = .apollo
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

        public mutating func use(coders: Coders) {
            builder = builder.setCoders(to: coders)
        }

        public mutating func setFederationSDL(sdl: String) {
            builder = builder.setFederatedSDL(to: sdl)
        }

        /// Path to Federation Schema to load from bundle.
        public mutating func loadFederationSDL(bundle: Bundle, resource: String, withExtension: String = "graphqls", subdirectory: String? = nil) throws {
            guard let url = bundle.url(forResource: resource, withExtension: withExtension, subdirectory: subdirectory) else {
                throw ConfigurationError.couldNotLoadFederationSDL
            }
            setFederationSDL(sdl: try String(contentsOf: url))
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
        logServerInfo()
    }

    func executeGraphQLOperation(request: Request) async throws -> GraphQLResult {
        guard let api = configuration.api else {
            // This will happen if `configureApplication` is not called before trying to query the server.
            throw Abort(.internalServerError, reason: "GraphQL API not available.")
        }

        let graphqlRequest = try request.graphql
        return try await api.execute(
            request: graphqlRequest.query,
            context: GraphQLContext(request: request),
            on: application.eventLoopGroup,
            variables: graphqlRequest.variables,
            operationName: graphqlRequest.operationName)
    }

    func playground(request: Request) async throws -> Response {
        guard let playgroundType = configuration.playgroundType else { throw Abort(.notFound) }

        let path = "\(getAddress())/\(configuration.path.description)"
        let playground = switch playgroundType {
        case .apollo: apolloSandbox(path: path)
        case .graphiql: graphiql(path: path)
        }

        return Response(status: .ok,
                 headers: HTTPHeaders([(HTTPHeaders.Name.contentType.description, "text/html")]),
                 body: Response.Body(string: { playground }()))
    }

    func getAddress() -> String {
        let scheme = application.http.server.configuration.tlsConfiguration == nil ? "http" : "https"
        let httpConfig = application.http.server.configuration
        let address: String
        switch httpConfig.address {
        case .hostname(let hostname, port: let port):
            address = "\(scheme)://\(hostname ?? httpConfig.hostname):\(port ?? httpConfig.port)"
        case .unixDomainSocket(path: let path):
            address = "\(scheme)+unix: \(path)"
        }
        return address
    }

    func logServerInfo() {
        let address = getAddress()
        application.logger.notice("GraphQL Server configured on \(address)/\(configuration.path)")
        
        if configuration.playgroundType != nil {
            application.logger.notice("GraphQL Playground configured on \(address)/\(configuration.playgroundPath)")
        }
    }
}

extension Application.GraphQL.Server {
    public var configuration: HTTPServer.Configuration {
        get { application.http.server.configuration }
        nonmutating set { application.http.server.configuration = newValue }
    }
}
