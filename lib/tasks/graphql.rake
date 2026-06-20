namespace :graphql do
  namespace :schema do
    desc 'Dump the GraphQL schema as SDL to app/graphql/schema.graphql'
    task dump: :environment do
      path = Rails.root.join('app/graphql/schema.graphql')
      File.write(path, MediaBackendSchema.to_definition)
      puts "Schema IDL dumped into #{path}"
    end
  end
end
