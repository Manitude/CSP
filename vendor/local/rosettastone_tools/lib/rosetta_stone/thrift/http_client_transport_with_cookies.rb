require 'thrift'

$session_cookie = nil

module Thrift
  class HTTPClientTransportWithCookies < Thrift::HTTPClientTransport
    def flush
      http = Net::HTTP.new @url.host, @url.port
      http.use_ssl = @url.scheme == 'https'
      if $session_cookie
        add_headers("Cookie" => $session_cookie)
      end
      resp = http.post(@url.request_uri, @outbuf, @headers)
      data = resp.body
      if resp['Set-Cookie']
        cookies = CGI::Cookie.parse(resp['Set-Cookie'])
        if cookies['rack.session']
          $session_cookie = cookies['rack.session'].value.to_s
        end
      end
      @inbuf = StringIO.new data
      @outbuf = ""
    end
  end
end
