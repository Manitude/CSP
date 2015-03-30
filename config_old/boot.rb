gemfile = File.expand_path('../../Gemfile', __FILE__)
if File.exist?(gemfile)
  begin
    ENV['BUNDLE_GEMFILE'] = gemfile
    require 'bundler'
    Bundler.setup
  rescue Bundler::GemNotFound => e
    STDERR.puts e.message
    STDERR.puts "Try running `bundle install`."
    exit!
  end
end