require File.expand_path('../../../test_helper', __FILE__)

class ApplicationHelperTest < ActionView::TestCase
  
  def test_escape_single_quotes
    assert_equal "tex\\'t", escape_single_quotes("tex't")
    assert_nil escape_single_quotes(nil)
    assert_equal "text",escape_single_quotes("text")
  end

  def test_get_license_family_type?
    assert_equal true,get_license_family_type?("family")
    assert_equal false,get_license_family_type?("Osub")
  end

  def test_show_na_if_error
    assert_equal "N/A", show_na_if_error("Error", "identifier")
    assert_equal "N/A", show_na_if_error(nil, "identifier")
    assert_equal "decimal@binary.com", show_na_if_error({"identifier" => "decimal@binary.com"}, "identifier")
  end

  def test_license_details_un_available?
    assert_true license_details_un_available?(nil, nil)
    assert_false license_details_un_available?({}, {})
    assert_true license_details_un_available?({}, nil)
    assert_true license_details_un_available?("Error", {})
  end

  def test_get_master_label_value
    assert "", get_master_label_value(nil, nil)
    assert "blaBla", get_master_label_value({"master_license_guid" => "blaBla"}, nil)
  end

  def test_convert_to_minutes_and_seconds
    assert_equal "0s"    , convert_to_minutes_and_seconds(nil)
    assert_equal "0s"    , convert_to_minutes_and_seconds(0)
    assert_equal "0s"    , convert_to_minutes_and_seconds(0.0)
    assert_equal "10s"   , convert_to_minutes_and_seconds(10.0)
    assert_equal "11s"   , convert_to_minutes_and_seconds(10.8)
    assert_equal "0s"    , convert_to_minutes_and_seconds(-5)
    assert_equal "0s"    , convert_to_minutes_and_seconds(-5.6)
    assert_equal "1m"    , convert_to_minutes_and_seconds(60.1)
    assert_equal "1m 6s" , convert_to_minutes_and_seconds(66)
    assert_equal "2m 5s" , convert_to_minutes_and_seconds(125.00)
    assert_equal "0s"    , convert_to_minutes_and_seconds(-125.56)
    assert_equal "94m 14s"      , convert_to_minutes_and_seconds(5654)
    assert_equal "0s"    , convert_to_minutes_and_seconds('asas')
    assert_equal "12s"    , convert_to_minutes_and_seconds('12.4')
  end

  def get_correct_end_time_to_add_extension
    t = Tiem.now
    assert_equal t + 1.hour, get_correct_end_time_to_add_extension(t + 1.hour)
    assert_equal t, get_correct_end_time_to_add_extension(t - 1.hour)
  end
end
