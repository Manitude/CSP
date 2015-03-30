#!/usr/bin/env ruby
lib_ext = `uname`.chomp == 'Darwin' ? 'bundle' : 'so'
Dir.chdir('ext/date_ext')
system('ruby extconf.rb')
system('make')
lib_dir = "../../lib/rosettastone/date_ext/#{RUBY_PLATFORM}/#{RUBY_VERSION}"
system("svn mkdir --parents #{lib_dir}")
system("mv date_ext.#{lib_ext} #{lib_dir}/")
system("svn add #{lib_dir}/date_ext.#{lib_ext}")
system("svn revert Makefile")
system("svn revert extconf.h")
