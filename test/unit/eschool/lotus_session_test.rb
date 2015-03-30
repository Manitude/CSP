require File.expand_path('../../../test_helper', __FILE__)

class LotusSessionTest < ActiveSupport::TestCase

	def test_should_not_throw_certain_exception
		begin
			Eschool::LotusSession.waiting_students
		rescue Exception => e
			assert_false e.message === "can't convert nil into Hash", "calls to eschool not going through properly"
		end
	end
end