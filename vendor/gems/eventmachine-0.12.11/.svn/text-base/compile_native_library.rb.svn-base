#!/usr/bin/env ruby
lib_ext = `uname`.chomp == 'Darwin' ? 'bundle' : 'so'
Dir.chdir('ext')
system('ruby extconf.rb')
system('make')
lib_dir = "../precompiled/#{RUBY_PLATFORM}"
system("svn mkdir --parents #{lib_dir}")
system("mv rubyeventmachine.#{lib_ext} #{lib_dir}")
system("rm mkmf.log")
system("rm -r conftest.dSYM")
system("rm Makefile")
system("svn add #{lib_dir}/rubyeventmachine.#{lib_ext}")
