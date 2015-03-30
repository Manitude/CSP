=begin
class ActiveResource::Connection
  # Creates new Net::HTTP instance for communication with
  # remote service and resources.

  def http
    # Change the proxy setting below to the appropriate proxy
    http = Net::HTTP.new(@site.host, @site.port, "giocondo.lan.flt", 3128, "eschoolplayer", "FNYN654HWF8RR7")
    http.use_ssl = @site.is_a?(URI::HTTPS)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
    http.read_timeout = @timeout if @timeout
    # Here's the addition that allows you to see the output
    http.set_debug_output $stderr
    http
  end
end
=end
