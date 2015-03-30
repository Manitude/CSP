#!/usr/bin/env ruby
lib_ext = `uname`.chomp == 'Darwin' ? 'bundle' : 'so'
Dir.chdir('ext/mysql2')
system('ruby extconf.rb')
system('make')
lib_dir = "../../lib/rosettastone/mysql2/#{RUBY_PLATFORM}/#{RUBY_VERSION}"
system("svn mkdir --parents #{lib_dir}")
system("mv mysql2.#{lib_ext} #{lib_dir}")
system("svn add #{lib_dir}/mysql2.#{lib_ext}")
system("svn revert Makefile")
system("svn revert extconf.h")
