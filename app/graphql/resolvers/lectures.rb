require 'search_object/plugin/graphql'

# Filterable list of lectures, backed by Postgres (the `events.tags` array column)
# rather than Elasticsearch. See Resolvers::SearchLectures for full-text search.

class Resolvers::Lectures < GraphQL::Schema::Resolver
  include SearchObject.module(:graphql)

  scope { Event.released }

  type [Types::LectureType], null: false

  class LectureFilter < ::Types::BaseInputObject
    argument :OR, [self], required: false
    argument :tags_contains, [String], required: false
  end

  class LectureOrderBy < ::Types::BaseEnum
    value 'date_ASC'
    value 'date_DESC'
  end

  option :filter, type: LectureFilter, with: :apply_filter
  option :first, type: Integer, with: :apply_first
  option :offset, type: Integer, with: :apply_offset
  option :orderBy, type: LectureOrderBy, default: 'date_DESC'

  def apply_filter(scope, value)
    branches = normalize_filters(value).reduce { |a, b| a.or(b) }
    scope.merge branches
  end

  def normalize_filters(value, branches = [])
    scope = Event.released
    scope = scope.where('tags && ARRAY[?]::varchar[]', value[:tags_contains]) if value[:tags_contains].present?

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

  def apply_order_by_with_date_asc(scope)
    scope.reorder('date ASC')
  end

  def apply_order_by_with_date_desc(scope)
    scope.reorder('date DESC')
  end
end
