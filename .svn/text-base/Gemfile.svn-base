source 'http://www.rubygems.org'

gem 'rails', '3.0.20', :path => 'vendor/local/rails-3.0.20'
gem "rake", "0.9.5", :path => 'vendor/local/rake-0.9.5'

# [[---  Main components of Rails --------------------->>
gem 'actionmailer', '3.0.20', :path => 'vendor/local/actionmailer-3.0.20'
gem 'actionpack', '3.0.20', :path => 'vendor/local/actionpack-3.0.20'
gem 'activemodel', '3.0.20', :path => 'vendor/local/activemodel-3.0.20'
gem 'activerecord', '3.0.20', :path => 'vendor/local/activerecord-3.0.20'
gem 'activeresource', '3.0.20', :path => 'vendor/local/activeresource-3.0.20'
gem 'activesupport', '3.0.20', :path => 'vendor/local/activesupport-3.0.20'
gem 'railties', '3.0.20', :path => 'vendor/local/railties-3.0.20' #Railties is responsible to glue all frameworks together
# -----  Main components of Rails ---------------------]]

gem 'abstract', '1.0.0', :path => 'vendor/local/abstract-1.0.0' # Internally Needed for erubis to work
gem 'amq-client', '0.9.1', :path => 'vendor/gems/amq-client-0.9.1' #Internally used by granite
gem 'amq-protocol', '0.9.0', :path => 'vendor/gems/amq-protocol-0.9.0' #Internally used by granite
gem 'amqp', '0.9.1', :path => 'vendor/gems/amqp-0.9.1' #Internally used by granite
gem 'arel', '2.0.10', :path => 'vendor/local/arel-2.0.10' #Needed to make queries doe active record
gem 'builder', '2.1.2', :path => 'vendor/local/builder-2.1.2' #Internally used by many many rails gems like actionpack ,activerecord, etc
gem 'bundler', '1.2.0', :path => 'vendor/local/bundler-1.2.0' # Obvious. It is the one that bundles
gem 'bunny', '0.7.4', :path => 'vendor/gems/bunny-0.7.4'  #Internally used by granite
gem 'clickatell', '0.6.0',:path => 'vendor/gems/clickatell-0.6.0' # SMS service provider
gem 'daemons', '1.1.3', :path => 'vendor/gems/daemons-1.1.3' # To facilitate background processes. Used by delayed_job
gem 'dalli', '2.5.0', :path => 'vendor/local/dalli-2.5.0' # To facilitate memcached
gem 'delayed_job','4.0.0', :path => 'vendor/local/delayed_job-4.0.0' # To make a block/code to run in background
gem 'delayed_job_active_record', '4.0.0', :path => 'vendor/local/delayed_job_active_record-4.0.0' # Needed for delayed_job
gem 'dynamic_form', '1.1.4', :path => 'vendor/local/dynamic_form-1.1.4' #To have helpers like error_message_on, error_message_for in rails-3. 
gem 'erubis', '2.6.6', :path => 'vendor/local/erubis-2.6.6' # Erubis is a fast, secure, and very extensible implementation of eRuby. Alternate for the regular erb.
gem 'eventmachine', '0.12.11', :path => 'vendor/gems/eventmachine-0.12.11'#Used by granite and other RS plugins
gem "exception_notification", "~> 2.6.1", :path => 'vendor/local/exception_notification-2.6.1' # I guess we can remove it, since we use Hoptoad notifier
gem 'fastercsv', '1.5.5',:path => 'vendor/gems/fastercsv-1.5.5' # CSV generation in placese like staffing model
gem 'granite', '1.0.0', :path => 'vendor/local/granite' # Realtime reflex update
gem "home_run", "1.0.7", :require => 'date', :path => 'vendor/local/home_run-1.0.7' #home_run is an implementation of ruby's Date/DateTime classes in C. Not sure whether we use it
gem 'hoptoad_notifier', '2.4.9',:path => 'vendor/gems/hoptoad_notifier-2.4.9' # To notify on exceprions
gem 'icalendar', '1.1.1', :path => 'vendor/gems/icalendar-1.1.4' # I guess we use it nowhere ion our application. we can check once again and remove it
gem 'i18n', '0.5.0', :path => 'vendor/local/i18n-0.5.0' # This is the translation gem. Not sure whether it is being used.
gem 'json', '1.6.5', :path => 'vendor/gems/json-1.6.5'
gem 'jquery-rails', '2.1.4', :path => 'vendor/local/jquery-rails-2.1.4' # to achieve unabstrousive javascript
gem 'lagomorphic', '1.0.0', :path => 'vendor/local/lagomorphic' #Internally used by granite
gem "libxml-ruby", "~> 2.3.3", :path => 'vendor/local/libxml-ruby-2.3.3' #XML parser
gem 'mail', '2.2.19', :path => 'vendor/local/mail-2.2.19' # Email gem internally used by action mailer
gem 'metaclass', '0.0.1', :path => 'vendor/local/metaclass-0.0.1'
gem 'mime-types', '~>  1.19', :path => 'vendor/local/mime-types-1.19' # Used in Mailing
gem 'mysql2', '0.2.7', :path => 'vendor/gems/mysql2-0.2.7' # Database adapter
gem 'polyglot', '0.3.3', :path => 'vendor/local/polyglot-0.3.3' # Used in many gems internally
gem 'rack', '1.2.5', :path => 'vendor/local/rack-1.2.5' # The middleware between webserver and application
gem 'rack-mount', '0.6.14', :path => 'vendor/local/rack-mount-0.6.14' # Used by actionpack

gem 'rcov', '1.0.0', :path => 'vendor/local/rcov-1.0.0' # To find test coverage
gem 'rdoc', '3.12', :path => 'vendor/local/rdoc-3.12' # The documentation gem
gem 'rosettastone_tools', '1.0.0', :path => 'vendor/local/rosettastone_tools' # we have many usages across application
gem 'simple_form', '2.0.4', :path => 'vendor/local/simple_form-2.0.4' # To make the form design easier. we used in scheduling thresholds
gem 'soap4r', '1.5.8', :path => 'vendor/gems/soap4r-1.5.8', :require => 'soap/rpc/driver' # No idea
gem 'thor', '0.14.6', :path => 'vendor/local/thor-0.14.6' # Used by bundler
gem 'treetop', '1.4.12', :path => 'vendor/local/treetop-1.4.12'  # Used by bundler
gem 'tzinfo', '0.3.35', :path => 'vendor/local/tzinfo-0.3.35' #used in activesupport 
gem 'uniform_notifier', '1.0.2', :path => 'vendor/gems/uniform_notifier-1.0.2' # Used by bullet
gem 'uuidtools', '2.1.2', :path => 'vendor/gems/uuidtools-2.1.2' # Used to generate uuid
gem 'xml-simple', '1.0.12', :path => 'vendor/gems/xml-simple-1.0.12'  # Simple xml parser
gem 'will_paginate', '3.0.3', :path => 'vendor/local/will_paginate-3.0.3' # Pagination gem
gem 'jrails', '0.6.0', :path => 'vendor/local/jrails-0.6.0'  # For unabstrousive jquery
gem "paperclip", :path => 'vendor/local/paperclip' # Attachment handling
gem 'cocaine', "0.5.1", :path => 'vendor/local/cocaine-0.5.1/' # Used by paperclip
gem 'climate_control', "0.0.3", :path => 'vendor/local/climate_control-0.0.3/'# Used by cocaine
gem 'chronic', "0.10.2", :path => 'vendor/local/chronic-0.10.2/'  # Used by whenever gem
gem 'whenever', "0.8.4", :path => 'vendor/local/whenever-0.8.4/', :require => false # To manipulate the cron
gem 'addressable', "2.3.5", :path => 'vendor/local/addressable-2.3.5' #for Big Blue Button API
gem 'ancestry', :path => 'vendor/local/ancestry-1-3' #for tree structure relation in model
group :development do
  #gem 'ruby-prof', '0.9.2', :path => 'vendor/gems/ruby-prof-0.9.2' # Profiler
  #gem 'request-log-analyzer', '1.12.5', :path => 'vendor/local/request-log-analyzer-1.12.5' # a tool analyze log files
  #gem 'ruby-debug', '0.10.4' # the debugger
end

group :test do
  gem 'dupe', '0.5.3', :path => 'vendor/gems/dupe-0.5.3'  # A mock tool
  gem 'object-factory', '0.2.4', :path => 'vendor/gems/object-factory-0.2.4'  # I think, we dont use it at all
  gem 'factory_girl', '2.5.1', :path => 'vendor/gems/factory_girl-2.5.1' # Object factory in test cases
  gem 'rujitsu', '0.3.3', :path => 'vendor/gems/rujitsu-0.3.3' # used by object_factory. to be re=moved if object_factory is removed
  gem 'rack-test', '0.6.2', :path => 'vendor/local/rack-test-0.6.2' # Used by rack-bug. But, we dont even use rack bug. :(
  gem 'mocha', '~> 0.13.2', :path => 'vendor/local/mocha-0.13.2' # Anothetr mock tool
end