require 'active_support/concern'

module ElasticsearchEvent
  extend ActiveSupport::Concern

  class_methods do
    def query(str)
      search_for query: {
        function_score:  {
          query:  {
            bool:  {
              disable_coord:  1,
              should:  [
                {
                  multi_match:  {
                    query:  str,
                    fields:  [
                      'event.title^4',
                      'event.subtitle^3',
                      'event.persons^3',
                      'conference.acronym^2',
                      'conference.title^2',
                      'event.description^1'
                    ],
                    type:  'best_fields',
                    operator:  'and',
                    fuzziness:  1
                  },
                },
                { prefix:  { 'event.title' => { value:  str, boost:  12 } } },
                { prefix:  { 'event.subtitle' => { value:  str, boost:  3 } } },
                { prefix:  { 'conference.acronym' => { value:  str, boost:  2 } } },
                { prefix:  { 'conference.persons' => { value:  str, boost:  1 } } }
              ]
            }
          },
          boost:  1.2,
          functions:  [
            { gauss:  { "event.date" =>  { scale:  "96w", decay:  0.5 } } }
          ]
        }
      }
    end

    # avoid conflict with active admins ransack #search method
    def search_for(*args, &block)
      __elasticsearch__.search(*args, &block)
    end
  end

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
      mappings dynamic: 'false' do
        indexes :title, analyzer: 'english', index_options: 'offsets'
      end
    end

    def as_indexed_json(_options = {})
      as_json(
        only: %i(frontend_link guid thumb_url release_date date description poster_url link title url length persons subtitle updated_at),
        id: :guid,
        include: { conference: { only: %i(title acronym frontend_link logo url) }
      })
    end
  end
end
