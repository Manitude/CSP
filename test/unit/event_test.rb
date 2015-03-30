require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  def test_validates_presence_of
    event = FactoryGirl.create(:event)
    assert_presence_required(event, :event_description)
    assert_presence_required(event, :event_start_date)
    assert_presence_required(event, :event_end_date)
    assert_presence_required(event, :language_id)
    assert_presence_required(event, :region_id)
  end

  def test_validate_on_create
    event = FactoryGirl.build(:event, {:event_start_date => "2000-09-14 04:00:00"})
    validity = event.valid?
    errors = event.errors
    assert_equal ["Event start date can't be in the past"], errors.full_messages
  end

  def test_with_end_date_earlier_than_start_date
    event = FactoryGirl.build(:event, {:event_start_date => "2035-09-14 04:00:00", :event_end_date => "2035-09-13 04:00:00"})
    validity = event.valid?
    errors = event.errors
    assert_equal ["Event start date must be earlier than end date"], errors.full_messages
  end



end
