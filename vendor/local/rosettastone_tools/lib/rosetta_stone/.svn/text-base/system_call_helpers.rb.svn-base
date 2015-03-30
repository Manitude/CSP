# -*- encoding : utf-8 -*-
#
# When bundler is loaded, it shoves a bunch of bundler commands to RUBYOPT,
# which causes forked ruby to run some bundler logic.
#
# At time of writing it does this:
#
# ENV['RUBYOPT'] # => "-I/Users/sxu/.rvm/gems/ruby-1.8.7-p352@opx/gems/bundler-1.1.rc.5/lib -rbundler/setup"
#
# This causes ruby to run a bunch of code that is not necessary in all cases.
# This code temporarily unsets and resets RUBYOPT.
#
# We used it when running the syntax checker rake task in a bundler
# environment. The syntax checker calls `ruby -c` hundreds of times,
# which is super slow when you load bundler each time. So we wrapped
# the calls in this block.
#
module RosettaStone
  class SystemCallHelpers
    def self.with_empty_rubyopt &block
      old_rubyopt = ENV['RUBYOPT']
      begin
        ENV['RUBYOPT'] = ''
        yield
      ensure
        ENV['RUBYOPT'] = old_rubyopt
      end
    end
  end
end
