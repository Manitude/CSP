# -*- encoding : utf-8 -*-
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../../../config/environment.rb', File.dirname(__FILE__)) unless defined?(RAILS_ROOT)
require 'test/unit'
require 'mocha'
$: << File.dirname(__FILE__) + '/../lib/'
require 'pp'
