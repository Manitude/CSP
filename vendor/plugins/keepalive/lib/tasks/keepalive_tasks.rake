require File.dirname(__FILE__) + '/../route_modifier'

namespace :keepalive do

  desc "Adds the route to the keepalive controller."
  task :setup do
    modifier = RosettaStone::KeepAlive::RouteModifier.new(File.expand_path("#{RAILS_ROOT}/config/routes.rb"))
    potential_output = modifier.modified_route_file
    puts "The following is what your routes.rb file is going to look like post-modification by this rake task: "
    puts "\n#{potential_output}\n\n"

    puts "If you want to save these changes, hit 'y' to continue [y/n]:"
    while line = $stdin.readline
      if line =~ /^[Yy]\n$/
        modifier.save!
        puts "Saved."
        exit
      elsif line =~ /^[Nn]\n$/
        puts "Aborted."
        exit
      else
        puts "If you want to save these changes, hit 'y' to continue [y/n]:"
      end
    end

  end

end

