Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'admin/dashboard#index'

  # VOC JSON API
  namespace :api do
    resources :conferences, :defaults => { :format => 'json' }
    resources :events, :defaults => { :format => 'json' } do
      collection do
        post 'update_promoted'
        post 'update_view_counts'
        post 'update_feeds'
      end
    end
    resources :recordings, :defaults => { :format => 'json' }
    resources :news, :defaults => { :format => 'json' }
  end

  # PUBLIC JSON API
  namespace :public do
    get :index, path: '/', defaults: { format: 'json' }
    get :oembed
    resources :conferences, only: [:index, :show], defaults: { format: 'json' }
    constraints(id: %r'[^/]+') do
      resources :events, only: %i(index show), defaults: { format: 'json' } do
        get :recent, defaults: { format: 'json' }, on: :collection
        get :search, defaults: { format: 'json' }, on: :collection
        get :popular, defaults: { format: 'json' }, on: :collection
        get :unpopular, defaults: { format: 'json' }, on: :collection
      end
    end
    resources :recordings, only: %i(index show), defaults: { format: 'json' } do
      collection do
        post 'count'
      end
    end
  end

  # GRAPHQL
  #if Rails.env.development?
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  #end
  post "/graphql", to: "graphql#execute"
  get "/graphql", to: "graphql#execute"


  # FRONTEND
  scope module: 'frontend' do
    root to: 'home#index'
    if Rails.env.production?
      get '404', to: 'home#page_not_found'
    end
    get '/about', to: 'home#about'
    get '/search', to: 'search#index'
    get '/sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }

    get '/v/:slug', to: 'events#show', as: :event, :constraints => { slug: %r'[^/]+' }
    get '/postroll/:slug', to: 'events#postroll', as: :postroll, :constraints => { slug: %r'[^/]+' }
    get '/v/:slug/oembed', to: 'events#oembed', as: :oembed_event, :constraints => { slug: %r'[^/]+' }
    get '/v/:slug/playlist', to: 'events#playlist_conference', as: :playlist_conference, :constraints => { slug: %r'[^/]+' }
    get '/v/:slug/audio', to: 'events#audio_playlist_conference', as: :audio_playlist_conference, :constraints => { slug: %r'[^/]+' }
    get '/v/:slug/related', to: 'events#playlist_related', as: :playlist_related, :constraints => { slug: %r'[^/]+' }

    get '/c/:acronym', to: 'conferences#show', as: :conference
    get '/c/:acronym/:tag', to: 'conferences#show', as: :conference_tag, :constraints => { tag: %r'[^/]+' }

    get '/a', to: 'conferences#all', as: :all_conferences
    get '/b', to: 'conferences#browse', as: :browse_start
    get '/b/*slug', to: 'conferences#browse', as: :browse

    get '/recent', to: 'recent#index'
    get '/popular', to: 'popular#index'
    get '/popular/:year', to: 'popular#index'
    get '/unpopular', to: 'unpopular#index'
    get '/unpopular/:year', to: 'unpopular#index'

    get '/tags/:tag', to: 'tags#show', as: :tag

    get '/news.atom', to: 'news#index', defaults: { format: 'xml' }, as: :news
    get '/updates.rdf', to: 'feeds#updates', defaults: { format: 'xml' }
    get '/podcast-audio-only.xml', to: 'feeds#podcast_audio', defaults: { format: 'xml' }

    get '/podcast-(:quality).xml', to: 'feeds#podcast',
        defaults: { format: 'xml' }, :constraints => { quality: %r'\w\w' }
    get '/podcast-archive-(:quality).xml', to: 'feeds#podcast_archive',
        defaults: { format: 'xml' }, :constraints => { quality: %r'\w\w' }

    # For video files with quality option
    get '/c/:acronym/podcast/:mime_type-(:quality).xml', to: 'feeds#podcast_folder',
        defaults: { format: 'xml' }, :constraints => { quality: %r'\w\w' }, as: :podcast_folder_video_feed
    # For master video files
    get '/c/:acronym/podcast/:mime_type-master.xml', to: 'feeds#podcast_folder',
        defaults: { format: 'xml', quality: 'master' }, as: :podcast_folder_video_master_feed
    # For audio and subtitle files
    get '/c/:acronym/podcast/:mime_type.xml', to: 'feeds#podcast_folder',
        defaults: { format: 'xml' }, :constraints => { quality: %r'\w\w' }, as: :podcast_folder_feed

    # Preserve for existing users but do not advertise, remove when it seem appropriate
    # deprecated 2015-10
    get '/podcast/:slug/:mime_type', to: 'feeds#podcast_folder', defaults: { format: 'xml' }, as: :old_podcast_folder_feed
    # deprecated 2017-04
    get '/podcast.xml', to: 'feeds#podcast_legacy', defaults: { format: 'xml' }
    # deprecated 2017-04
    get '/podcast-archive.xml', to: 'feeds#podcast_archive_legacy', defaults: { format: 'xml' }
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
