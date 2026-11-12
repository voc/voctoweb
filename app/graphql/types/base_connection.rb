module Types
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    # Skip the `edges` field entirely - this API only exposes `nodes` and `pageInfo`.
    def self.edge_type(edge_type_class, node_type: edge_type_class.node_type, node_nullable: self.node_nullable, **_field_options)
      @node_type = node_type
      define_nodes_field(node_nullable)
      description("The connection type for #{node_type.graphql_name}.")
    end
  end
end
