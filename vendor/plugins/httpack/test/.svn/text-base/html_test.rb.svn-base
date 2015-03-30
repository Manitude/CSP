$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
RAILS_ENV = "test"
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'

class HtmlTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include PlanetArgon::HttPack::Html

  def test_html_doctype
    assert_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
                 xhtml_doctype(:transitional)
    assert_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
                 xhtml_doctype(:strict)
    assert_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
                 xhtml_doctype(:frameset)
  end

  def test_html_tag
    assert_equal '<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">', html_tag
    assert_equal '<html lang="de-DE" xml:lang="de-DE" xmlns="http://www.w3.org/1999/xhtml">', html_tag( :lang => 'de-DE' )
  end
  
  def test_end_html_tag
    assert_equal "</html>", end_html_tag
  end
  
  def test_body_tag
    assert_equal "<body>", body_tag
    assert_equal '<body style="background: red;">', body_tag(:style => 'background: red;')
  end
  
  def test_end_body_tag
    assert_equal "</body>", end_body_tag
  end
end
