require File.expand_path('../../../test_helper', __FILE__)
require 'active_resource/http_mock'

class EschoolCoachTest < ActionView::TestCase

  def setup
    xml = <<EOF
<teachers type="array">
  <teacher>
    <id>51993872</id>
    <user_name>aharbick</user_name>
    <email>aharbick@rosettastone.com</email>
    <external_coach_id></external_coach_id>
    <full_name>Aharbick</full_name>
    <time_zone>Eastern Time (US &amp; Canada)</time_zone>
    <active>true</active>
  </teacher>
  <teacher>
    <id>175672451</id>
    <user_name>nbrustein</user_name>
    <email>nbrustein@rosettastone.com</email>
    <external_coach_id></external_coach_id>
    <full_name>Nbrustein</full_name>
    <time_zone>Eastern Time (US &amp; Canada)</time_zone>
    <active>true</active>
  </teacher>
  <teacher>
    <id>372102848</id>
    <user_name>dcatt</user_name>
    <email>dcatt@rosettastone.com</email>
    <external_coach_id></external_coach_id>
    <full_name>Dcatt</full_name>
    <time_zone>Eastern Time (US &amp; Canada)</time_zone>
    <active>true</active>
  </teacher>
</teachers>
EOF

    #    ActiveResource::HttpMock.respond_to do |mock|
    #      mock.get "/api/cs/find_teachers_with_no_external_coach_id", {}, @teachers
    #    end
    teachers = parse_coaches_xml_to_array_of_objects(xml)
    Eschool::Coach.stubs(:find_teachers_with_no_external_coach_id).returns(teachers)
  end

end
