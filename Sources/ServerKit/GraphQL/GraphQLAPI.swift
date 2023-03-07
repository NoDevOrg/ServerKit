import Graphiti

public struct GraphQLAPI: API {
    public let resolver: GraphQLResolver
    public let schema: Schema<GraphQLResolver, GraphQLContext>
}
