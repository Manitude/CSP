# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  class PlatformIndependentRake
    class << self
      # chooses between locally embedded rake and system rake; also puts windows into the right directory
      def rake_invocation
        "#{windows_path_cd_command}#{rake_program}"
      end

    private
      # for our purposes, we're on Windows if the FS uses backslash for a separator.
      def windows?
        #RUBY_PLATFORM =~ %r{mswin}
        File::ALT_SEPARATOR == '\\'
      end

      # returns empty string on non-windows OS, and a cd cmd into rails_root for windows
      def windows_path_cd_command
        windows? ? "cd #{quote_path(windows_safe_path(rails_root))} && " : ''
      end

      # there must be an existing method for this?!?
      def windows_safe_path(path)
        return path unless windows?
        pathname = Pathname.new(path)
        if pathname.absolute?
          pathname.realpath.to_s.split('/').join('\\')
        else
          pathname.to_s
        end
      end

      def rake_program
        windows_safe_path(which_rake)
      end

      def rails_root
        Rails::VERSION::MAJOR < 3 ? RAILS_ROOT : Rails.root
      end

      def quote_path(path)
        %Q["#{path}"]
      end

      # finds rake (embedded locally, installed with Viper, or in system path)
      def which_rake
        if !windows? && File.exist?("#{rails_root}/rake")
          "#{rails_root}/rake"
        # check to see if rake is where it's installed with the Viper Server app
        elsif File.exist?("#{rails_root}/../ruby/bin/rake")
          quote_path("#{rails_root}/../ruby/bin/rake")
        else
          'rake'
        end
      end
    end # class methods
  end   # PlatformIndependentRake
end     # RosettaStone
