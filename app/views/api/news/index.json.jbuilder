json.array!(@news) do |news|
  json.partial! 'fields', news: news
  json.url api_news_url(news, format: :json)
end
