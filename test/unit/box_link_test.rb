require File.dirname(__FILE__) + '/../test_helper'

class BoxLinkTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_validations
    assert_true create_a_box_link.valid?
    assert_false build_a_box_link('aa', 'aaa').valid?
    assert_false build_a_box_link('cc','www.google.com').valid?
    assert_false build_a_box_link('cc','www.google.com').valid?
    assert_true create_a_box_link('cc1','https://app.box.com/embed_widget/e1').valid?
    assert_true create_a_box_link('cc2','http://app.box.com/embed_widget/e2').valid?
    assert_true create_a_box_link('cc3','https://rosettastone.app.box.com/embed_widget/e3').valid?
    assert_true create_a_box_link('cc4','http://rosettastone.app.box.com/embed_widget/e4').valid?
    assert_false build_a_box_link('cc4','http://rosettastone.app.box.com/embed_widget/e5').valid?
    assert_false build_a_box_link('cc5','http://rosettastone.app.box.com/embed_widget/e4').valid?
  end

  private
  def build_a_box_link(title = "Folder_#{Time.now}", url = "https://app.box.com/embed_widget/eafbff29c305/s/oi3tq6j#{Time.now}f0mcl8j8ai?view=list&sort=name&direction=ASC&theme=blue")
  	FactoryGirl.build(:box_link, :title => title, :url => url)
  end
  def create_a_box_link(title = "Folder_#{Time.now}", url = "https://app.box.com/embed_widget/eafbff29c305/s/oi3tq6j#{Time.now}f0mcl8j8ai?view=list&sort=name&direction=ASC&theme=blue")
  	FactoryGirl.create(:box_link, :title => title, :url => url)
  end
end
