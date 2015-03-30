# -*- encoding : utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper')

class HeaderTest < Test::Unit::TestCase

  def setup
    SimpleHttpTestServer.start(:before_filter => instance_variable_setting_filter)
  end

  def test_custom_headers_pass_through
    %w[get post put delete head].each do |verb|
      capture_from_webrick(:default_client) do |http|
        http.send(verb, append_path('/?x=y'), :headers => {'Baba' => 'booey', 'These' => 'headers'})
      end
      assert_equal 'booey', @request.header['baba'].first
      assert_equal 'headers', @request.header['these'].first
    end
  end

  def test_customer_headers_sent_when_instantiated_with_them
    %w[get post put delete head].each do |verb|
      capture_from_webrick(:default_client, :extra_options => {:headers => {'Plexi' => 'glass', 'Foo' => 'bar'}}) do |http|
        http.send(verb, append_path('/?x=y'), :headers => {'Baba' => 'booey', 'Foo' => 'overwritten'})
      end
      assert_equal 'booey', @request.header['baba'].first
      assert_equal 'glass', @request.header['plexi'].first
      assert_equal 'overwritten', @request.header['foo'].first
    end
  end

  def test_customer_headers_sent_when_using_singleton_methods
    %w[get post put delete head].each do |verb|
      capture_from_webrick do
        SimpleHTTP::Client.send(verb, append_path('/?a=b', :with_host => true), :headers => {'Baba' => 'booey'})
      end
      assert_equal 'booey', @request.header['baba'].first
    end
  end

end
