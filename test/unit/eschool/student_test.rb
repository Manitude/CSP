require File.expand_path('../../../test_helper', __FILE__)
require 'active_resource/http_mock'

class StudentTest < ActiveSupport::TestCase

  def  test_get_completed_reflex_sessions_count_for_learner
    student = mock("studen")
    student.stubs(:number_of_completed_sessions).returns(0)
    Eschool::Student.stubs(:find).returns(student)
    assert_equal(0, Eschool::Student.get_completed_reflex_sessions_count_for_learner("1111-2222-3333"))
  end

end