# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.
#
# improvements on assert_tidy to check for overescaping
#
# usage (in test/test_helper.rb):
#
# class ActiveSupport::TestCase
# end
#
module RosettaStone
  module AssertTidyWithOverescapingChecks

    def add_overescaping_checks_to_assert_tidy
      class_eval do
        def assert_tidy_with_overescaping_check(*args)
          assert_tidy_without_overescaping_check(*args)
          assert_no_overescaping(*args)
        end

        def assert_tidy_with_enhanced_overescaping_check(*args)
          assert_tidy_without_overescaping_check(*args)
          assert_no_overescaping(args[0] || @response.body, (args[1] || {}).merge(:enhanced => true))
        end

        def assert_no_overescaping(response = @response.body, options = {})
          options[:enhanced] ? assert_no_escaped_html_outside_tags(response) : assert_no_escaped_html(response)
          assert_no_interpolations(response)
        end

        def assert_no_escaped_html(response = @response.body)
          assert_no_match_with_summary(/&(lt|gt|quot);/, response, "Found unescaped HTML entities in your response body. If these are legitimate, consider assert_tidy_without_overescaping_check.")
        end

        # the weird negative lookbehind is a heuristic to ignore html entities inside HTML tags
        # n.b., this is a very expensive lookup
        def assert_no_escaped_html_outside_tags(response = @response.body)
          assert_no_match_with_summary(/^([^<]|<[^>]*>)*&(lt|gt|quot);/, response, "Found unescaped HTML entities in your response body outside HTML tags. If these are legitimate, consider assert_tidy_without_overescaping_check.")
        end

        def assert_no_interpolations(response = @response.body)
          interpolationy_match_found = response.match(/#\{.*\}/)
          assert(!interpolationy_match_found, "Found something in your response body that resembles a Ruby interpolation:\n#{interpolationy_match_found}\n\nIf this is legitimate, consider assert_tidy_without_overescaping_check. Body checked against:\n#{response}\n\n")
        end

        def assert_no_match_with_summary(pattern, string, summary_prefix)
          match = string.match(pattern)

          # a little hack to get around the fact that Ruby requires you
          # to pass in the assertion failure message regardless of
          # whether the assertion passes, and this assertion failure
          # message calls methods on match, which is only available
          # upon failure.
          if match.nil?
            # no match ==> pass
            assert_block("You should not see me") { true }
          else
            # match ==> fail and print out context
            assert_block("#{summary_prefix}\nFound the following match for /#{pattern.source}/: #{match[0]}\nContext: #{match.pre_match.split("\n").last.gsub(/^\s*/, '')}#{match[0]}#{match.post_match.split("\n").first.gsub(/\s*$/, '')}") do
              match.nil?
            end
          end
        end
      end

      # def assert_tidy
      #   assert_tidy_with_overescaping_check
      # end
      #
      # def assert_tidy_without_overescaping_check
      #   ORIGINAL_assert_tidy
      # end
      alias_method_chain :assert_tidy, :overescaping_check
    end
  end
end

current_env = ::Rails.respond_to?(:env) ? ::Rails.env : RAILS_ENV

if current_env == 'test'
  require 'test/unit/testcase'
  Test::Unit::TestCase.send(:extend, RosettaStone::AssertTidyWithOverescapingChecks)
end
