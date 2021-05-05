require 'search_object/plugin/graphql'
require 'graphql/query_resolver'

# based on https://github.com/howtographql/graphql-ruby/blob/master/app/graphql/resolvers/links_search.rb

class Resolvers::Conference < GraphQL::Schema::Resolver
  include SearchObject.module(:graphql)

  scope { Conference.all }

  type [Types::ConferenceType], null: false

  class ConferenceFilter < ::Types::BaseInputObject
    argument :OR, [self], required: false
    #argument :description_contains, String, required: false
    argument :url_contains, String, required: false
    argument :currently_streaming, Boolean, required: false
  end

  class ConferenceOrderBy < ::Types::BaseEnum
    value 'createdAt_ASC'
    value 'createdAt_DESC'
  end

  option :filter, type: ConferenceFilter, with: :apply_filter
  option :first, type: types.Int, with: :apply_first
  option :offset, type: types.Int, with: :apply_offset
  option :orderBy, type: ConferenceOrderBy, default: 'createdAt_DESC'

  def apply_filter(scope, value)
    branches = normalize_filters(value).reduce { |a, b| a.or(b) }
    scope.merge branches
  end

  def normalize_filters(value, branches = [])
    scope = Conference.all
    scope = scope.where('description LIKE ?', "%#{value[:description_contains]}%") if value[:description_contains]
    scope = scope.where('url LIKE ?', "%#{value[:url_contains]}%") if value[:url_contains]

    branches << scope

    value[:OR].reduce(branches) { |s, v| normalize_filters(v, s) } if value[:OR].present?

    branches
  end

  def apply_first(scope, value)
    scope.limit(value)
  end

  def apply_offset(scope, value)
    scope.offset(value)
  end

  def apply_order_by_with_created_at_asc(scope)
    scope.order('created_at ASC')
  end

  def apply_order_by_with_created_at_desc(scope)
    scope.order('created_at DESC')
  end

  def resolve(obj, args, ctx)
    # NOTE: Don't run QueryResolver during tests
    return super unless ctx.present?

    GraphQL::QueryResolver.run(Conference, ctx, Types::ConferenceType) do
      super
    end
  end
end