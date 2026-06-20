# Force the net_http adapter instead of relying on elasticsearch-transport's
# `defined?(::HTTPClient)` auto-detection, which mistakenly picks the :httpclient
# adapter once the unrelated `httpclient` gem (pulled in by omniauth_openid_connect)
# is loaded, even though no faraday-httpclient adapter is installed for faraday 2.x.
Elasticsearch::Model.client = Elasticsearch::Client.new(adapter: :net_http)
