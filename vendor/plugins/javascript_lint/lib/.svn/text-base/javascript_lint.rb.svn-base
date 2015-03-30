# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  class JavascriptLint
    # see init.rb for default configuration
    cattr_accessor :files_to_exclude
    cattr_accessor :javascript_directories

    class << self

      def validate_javascript_file(file_path, extra_jsl_options = '')
        return nil, nil unless has_jsl?
        output = jsl_command(file_path, extra_jsl_options)
        if output.match(Regexp.escape('0 error(s), 0 warning(s)'))
          return true, '' 
        else
          return false, output
        end
      end

      def files_to_validate
        raw_file_list.reject do |file|
          files_to_exclude.any? { |exclusion_matcher| file.match(exclusion_matcher) }
        end
      end

    private
      def has_jsl?
        !!jsl_to_use
      end

      def system_jsl
        which = `which jsl`.strip
        which.blank? ? nil : which
      end

      # we only have embedded versions for Intel Mac and x86 Linux, and even those might not work 
      # under some circumstances
      def embedded_jsl
        Rails.logger.debug("RosettaStone::JavascriptLint: trying to find an embedded version to use")
        case `uname -s -m`
          when %r{Linux i.86} then File.join(File.dirname(__FILE__), 'bin', 'linux-x86', 'jsl')
          when %r{Darwin i.86} then File.join(File.dirname(__FILE__), 'bin', 'darwin-x86', 'jsl')
        else
          nil
        end
      end

      def jsl_to_use
        return @jsl_to_use unless @jsl_to_use.nil?
        @jsl_to_use = system_jsl || embedded_jsl || false      
        puts "RosettaStone::JavascriptLint: Failed to locate command jsl.  Download it at http://javascriptlint.com." unless @jsl_to_use
        return @jsl_to_use
      end

      def jsl_command(file, extra_options = '')
        command = %Q["#{jsl_to_use}" -nologo -conf "#{config_file_path}" #{extra_options} -process "#{file}" 2>&1]
        Rails.logger.debug("RosettaStone::JavascriptLint: running command: #{command}")
        `#{command}`
      end

      def config_file_path
        File.exist?(custom_config_file_path) ? custom_config_file_path : fallback_config_file_path
      end

      def custom_config_file_path
        File.join(Rails.root, 'config', 'jsl.conf')
      end

      def fallback_config_file_path
        File.join(File.dirname(__FILE__), '..', 'jsl.conf')
      end

      def raw_file_list
        raise "You must configure the javascript directories to search." if javascript_directories.blank?
        javascript_directories.map do |dir|
          # this globbing hack will traverse a symlink once, it seems (?)...
          Dir.glob(File.join(dir, '**{,/*/**}', '*.{js,html}'))
        end.flatten.sort
      end
    end

    module TestAssertions
      def assert_lintless_javascript(javascript_string)
        with_js_contents_in_temp_file(javascript_string) do |tmp_file|
          assert_lintless_javascript_file(tmp_file)
        end
      end

      def assert_lintless_javascript_file(javascript_file)
        assert_true(File.exist?(javascript_file), "I can't validate a file I can't find! (#{javascript_file})")
        success, error_message = RosettaStone::JavascriptLint.validate_javascript_file(javascript_file)
        if success.nil?
          puts "RosettaStone::JavascriptLint: jsl command not found; skipping test"
        else
          assert_true(success, error_message)
        end
      end

      def assert_lintless_inline_javascript(html_string = @response.body)
        assert_select_on!(html_string)
        assert_select('script[type=text/javascript]') do |script_tags|
          script_tags.each do |script_tag|
            # note: this even snags src="" script tags, but they're empty so who cares
            contents = script_tag.children.map(&:to_s).join.strip
            assert_lintless_javascript(contents) unless contents.blank?
          end
        end
      end

    private
      def with_js_contents_in_temp_file(data, &block)
        begin
          tempfile = Tempfile.new(['javascript_lint_', '.js'])
          tempfile << data
          tempfile.close
          block.call(tempfile.path)
        ensure
          tempfile.unlink
        end
      end

    end
  end
end
