Gem::Specification.new do |s|
  s.name        = "keepalive"
  s.version     = "1.0.0"
  s.authors     = ["Core Platform"]
  s.email       = ["RSPlatforms@rosettastone.com"]
  s.homepage    = "https://trac.lan.flt/webdev/browser/plugins/keepalive/trunk"
  s.summary     = %q{Add keepalive tasks and handlers.}
  s.description = %q{Basically, provides a keepalive controller for the CSS to hit. Just drop this plugin into your app, and run rake keepalive:setup.}

  s.add_dependency('mocha')
  s.add_dependency('rosettastone_tools')

  s.files = Dir['Rakefile', '{lib,test,doc,config}/**/*', 'README']
  s.require_paths = ["lib"]
end
