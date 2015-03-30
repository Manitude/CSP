# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

# require 'amqp' # config.gem does this one for us
# require 'mq'  # but not this one

require 'granite'


# the rails 3 version of this autoloading is in lib/granite/railtie.rb
# We try the pattern /*/** so that if vendor is a symlink, this still works
# vendor is a symlink for totale_next. When we stop doing that, we can change it back
# to match **/app/agents
Dir.glob(Rails.root.join("{,*/**/}app/agents")).each do |dir|
  ActiveSupport::Dependencies.autoload_paths << dir
end
