require "hoptoad_ext"
HoptoadNotifier.configure do |config|
  config.api_key = Hoptoad.api_key
  config.host = Hoptoad.host
  config.port = Hoptoad.port
  config.proxy_host = Hoptoad.proxy_host
  config.proxy_port = Hoptoad.proxy_port
end
