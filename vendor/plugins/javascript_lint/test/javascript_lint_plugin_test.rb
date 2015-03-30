require File.join(File.dirname(__FILE__), 'test_helper')
require 'action_controller/assertions/selector_assertions' # for assert_select. for some reason one app needs this...

class RosettaStone::JavascriptLint::JavascriptLintPluginTest < Test::Unit::TestCase
  include ActionController::Assertions::SelectorAssertions # for assert_select

  def test_good_syntax_passes_validation
    success, message = RosettaStone::JavascriptLint.validate_javascript_file(sample_file('file_with_no_warnings'))
    assert_true(success)
    assert(message.blank?)
  end

  def test_validation_on_file_with_warning
    success, message = RosettaStone::JavascriptLint.validate_javascript_file(sample_file('file_with_warning'))
    assert_false(success)
    assert(!message.blank?)
  end

  def test_jsl_is_not_installed
    RosettaStone::JavascriptLint.expects(:has_jsl?).returns(false)
    success, message = RosettaStone::JavascriptLint.validate_javascript_file('')
    assert_nil(success)
    assert_nil(message)
  end

  def test_validation_of_empty_file
    success, message = RosettaStone::JavascriptLint.validate_javascript_file(sample_file('empty_file'))
    assert_true(success)
    assert(message.blank?)
  end

  def test_assert_lintless_javascript_file
    assert_lintless_javascript_file(sample_file('file_with_no_warnings'))
  end

  def test_assert_lintless_javascript
    assert_lintless_javascript(File.read(sample_file('file_with_no_warnings')))
  end

  def test_assert_lintless_inline_javascript
    js_wrapped_in_html = %Q[
      <html>
        <head>
          <script src="blah" type="text/javascript"></script>
        </head>
        <body>
          <script type="text/javascript">
            #{File.read(sample_file('file_with_no_warnings'))}
          </script>
          <script type="not javascript">
            not valid javascript
          </script>
        </body>
      </html>
    ]
    assert_lintless_inline_javascript(js_wrapped_in_html)
  end

private
  def sample_file(file_base)
    File.join(File.dirname(__FILE__), 'javascript', "#{file_base}.js")
  end
end
