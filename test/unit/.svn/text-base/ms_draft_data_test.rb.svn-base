require 'test_helper'

class MsDraftDataTest < ActiveSupport::TestCase
  fixtures :accounts, :languages
  
  def test_update_data_attribute
    drafty = create_coach_with_qualifications('rajkumar', ['ARA'])
    Community::Village.stubs(:all).returns([])
    start_of_week = Time.now.beginning_of_hour + 1.week
    feed_data = {0=>{:create=>[{"max_unit"=>"8",
            "coach_id"=>"#{drafty.id}",
            "village"=>"",
            "level"=>"--",
            "external_village_id"=>nil,
            "coach_availability"=>"false",
            "coach_name"=>"#{drafty.full_name}",
            "duration_in_seconds"=>"3600",
            "unit"=>"--",
            "wildcard"=>"true",
            "changed_now" => "true",
            "from_server"=>false,
            "lang_identifier"=>"ARA",
            "number_of_seats"=>"4",
            "coach_username"=>"#{drafty.user_name}",
            "recurring"=>false,
            "start_time"=>"#{(start_of_week+1.day+1.hour).to_s(:db)}"}],
        :delete=>[], :cancel=>[], :edit=>[]},
      11=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      17=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      12=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      18=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      13=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      19=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
       8=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      14=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      20=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
       9=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      15=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]},
      10=>{:create=>[], :delete=>[], :cancel=>[], :edit=>[]}
    }
    draft = MsDraftData.find_or_create_by_lang_identifier_and_start_of_week("ARA", start_of_week.to_s(:db))
    assert_nil draft.data, "Old data should be nil."
    draft.update_data_attribute(feed_data)
    unmarshalled_data = Marshal.load draft.data
    assert_equal 1, unmarshalled_data[0][:create].size, "One session should be saved as draft in has no village (0) category."
  end

end
