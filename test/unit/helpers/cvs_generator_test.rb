require File.expand_path('../../../test_helper', __FILE__)
require 'action_view/test_case'

class CsvGeneratorHelperTest < ActionView::TestCase

  def test_title_alone
    csv_generator = CsvGenerator.new(["a", "b"])
    assert_equal "a,b\n", csv_generator.to_csv
  end

  def test_header_alone
    csv_generator = CsvGenerator.new([],[["a", "b"]])
    assert_equal "a,b\n", csv_generator.to_csv
  end

  def test_with_proper_data_set
    csv_generator = CsvGenerator.new(["a", "b"],[["c", "d"],["e", "f"]])
    assert_equal "a,b\nc,d\ne,f\n", csv_generator.to_csv
  end

  def test_with_improper_data_set
    csv_generator = CsvGenerator.new(["a", "b"],[["c", "d","e", "f"]])
    assert_equal "a,b\nc,d,e,f\n", csv_generator.to_csv
  end

  def test_with_special_charaters
    csv_generator = CsvGenerator.new(
      ["a", "b"],
      [
        ["a`b", "a-b"],
        ["a!b", "a_b"],
        ["a@b", "a=b"],
        ["a#b", "a+b"],
        ["a$b", "a[b"],
        ["a%b", "a]b"],
        ["a^b", "a{b"],
        ["a&b", "a}b"],
        ["a*b", "a'b"],
        ["a(b", "a\"b"],
        ["a)b", "a;b"],
        ["a<b", "a>b"],
        ["a,b", "a.b"],
        ["a/b", "a~b"],
        ["a?b", "a*b"]
      ]
    )
    assert_equal "a,b\na`b,a-b\na!b,a_b\na@b,a=b\na#b,a+b\na$b,a[b\na%b,a]b\na^b,a{b\na&b,a}b\na*b,a'b\na(b,\"a\"\"b\"\na)b,a;b\na<b,a>b\n\"a,b\",a.b\na/b,a~b\na?b,a*b\n", csv_generator.to_csv
  end

end
