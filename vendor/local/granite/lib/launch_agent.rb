# Expects the following arguments:
# ARGV[0] = The relative path to the agent file
# ARGV[1] = The pkill identifier
# ARGV[2] = The agent classname to start

require 'rubygems'
require 'erlectricity'
require "#{Framework.root}/config/environment"
require "#{ARGV[0]}"

p Process.pid
$stdout.flush
eval("#{ARGV[2]}.start")

pkill_identifier = "#{ARGV[1]}"
receive do |f|
  f.send!([:pid, Process.pid])
  f.when([:start, String]) do
    eval("#{ARGV[2]}.start")
    #f.send!([:pid, Process.pid])
  end
end #receive


