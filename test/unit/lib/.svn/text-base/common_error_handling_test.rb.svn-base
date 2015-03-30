require 'test/test_helper.rb'

class CommonTest < ActiveSupport::TestCase
  def test_hoptoad_notifier_should_notify_email_when_error_rised_in_handle_exception
    HoptoadNotifier.expects(:notify).with(instance_of RuntimeError) 
    handle_exception do
      raise RuntimeError
    end
  end

  def test_hoptoad_notifier_should_not_notify_email_when_error_not_rised_in_handle_exception
    HoptoadNotifier.expects(:notify).never
    handle_exception do
      "Just a Happy scenario for handle_exception"
    end
  end  
end



 
