require 'test_helper'

class HoptoadExtTest < ActiveSupport::TestCase

  def test_notify_passing_string_as_params
    result = HoptoadNotifier.notify('My new Exception !')
    assert_equal result , "Hoptoad notification suppressed for this configuration\n"
  end

  def test_notify_passing_exception_as_params
    exception = Exception.new('User Defined Exception !')
    result = HoptoadNotifier.notify(exception)
    assert_equal result , "Hoptoad notification suppressed for this configuration\n"
  end

end