if Rails::VERSION::MAJOR == 3
  if [0, 1].include?(Rails::VERSION::MINOR)
    require File.expand_path('remote_ip_resolution_fix/3.0', File.dirname(__FILE__))
  elsif Rails::VERSION::MINOR == 2
    require File.expand_path('remote_ip_resolution_fix/3.2', File.dirname(__FILE__))
  else
    puts "remote_ip_resolution_fix has yet to be made compatible with this Rails version.  please fix me."
  end
else
  puts "remote_ip_resolution_fix has yet to be made compatible with this Rails version.  please fix me."
end
