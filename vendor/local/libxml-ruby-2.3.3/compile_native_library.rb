#!/usr/bin/env ruby
lib_ext = `uname`.chomp == 'Darwin' ? 'bundle' : 'so'
Dir.chdir('ext/libxml')
system('ruby extconf.rb')
system('make')
lib_dir = "../../lib/rosettastone/libxml/#{RUBY_PLATFORM}/#{RUBY_VERSION}"
system("svn mkdir --parents #{lib_dir}")
system("mv libxml_ruby.#{lib_ext} #{lib_dir}/")
system("svn add #{lib_dir}/libxml_ruby.#{lib_ext}")
system("svn revert Makefile")
system("svn revert extconf.h")
