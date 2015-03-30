class ActionDispatch::RemoteIp::GetIp
  def calculate_ip
    # IGNORE THIS
    # client_ip     = @env['HTTP_CLIENT_IP']

    untrusted_forwarded_ips = ips_from('HTTP_X_FORWARDED_FOR')
    untrusted_remote_addrs = ips_from('REMOTE_ADDR') # one or none

    (untrusted_forwarded_ips + untrusted_remote_addrs).last ||
      ips_from('HTTP_X_FORWARDED_FOR', true).first ||
      ips_from('REMOTE_ADDR', true).first
  end
end
