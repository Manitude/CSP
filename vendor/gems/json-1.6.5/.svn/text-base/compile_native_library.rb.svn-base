#!/usr/bin/env ruby
lib_ext = `uname`.chomp == 'Darwin' ? 'bundle' : 'so'
Dir.chdir('ext/json/ext/generator')
system('ruby extconf.rb')
system('make')
lib_dir = "../../../../lib/rosettastone/json/ext/#{RUBY_PLATFORM}/#{RUBY_VERSION}"
system("svn mkdir --parents #{lib_dir}")
system("mv generator.#{lib_ext} #{lib_dir}")
system("svn add #{lib_dir}/generator.#{lib_ext}")
system("make clean")
system("rm Makefile")
Dir.chdir('../parser')
system('ruby extconf.rb')
system('make')
system("mv parser.#{lib_ext} #{lib_dir}")
system("svn add #{lib_dir}/parser.#{lib_ext}")
system('make clean')
system('rm Makefile')
