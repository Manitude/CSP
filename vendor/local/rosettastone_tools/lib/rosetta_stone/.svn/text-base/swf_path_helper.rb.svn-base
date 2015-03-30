# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

if defined?(ActionView::Helpers::AssetTagHelper::AssetTag) # Rails < 2.3
  module ActionView
    module Helpers
      module AssetTagHelper
        def swf_path(source)
          SwfTag.new(self, @controller, source).public_path
        end

        private
        module SwfAsset
          DIRECTORY = 'swfs'.freeze

          def directory
            DIRECTORY
          end

          def extension
            nil
          end
        end

        class SwfTag < AssetTag
          include SwfAsset
        end
      end
    end
  end
elsif defined?(ActionView::Helpers::AssetTagHelper) # Rails >= 2.3
  module ActionView
    module Helpers
      module AssetTagHelper
        # Computes the path to a Flash asset in the public swfss directory.
        # If the +source+ filename has no extension, <tt>.swf</tt> will be appended.
        #
        # ==== Examples
        #   swf_path "SystemChecker" # => /swfs/SystemChecker.swf
        #   swf_path "dir/blah.swf"  # => /swfs/dir/blah.swf
        #   swf_path "/dir/blah.swf" # => /dir/blah.swf
        def swf_path(source, include_host = true)
          # Rails 3.1 moves compute_public_path from AssetTagHelper to AssetPaths
          # http://apidock.com/rails/ActionView/Helpers/AssetTagHelper/compute_public_path
          #
          # Since rosettastone_tools is unversioned, we need to support both approaches.
          #
          # Compare implementations of image_path in 3.0 and 3.1.
          #
          # >> 3.0.9:
          # def image_path(source)
          #   compute_public_path(source, 'images')
          # end
          #
          # >> 3.1.0
          # def image_path(source)
          #   asset_paths.compute_public_path(source, 'images')
          # end
          #
          if(respond_to?(:asset_paths))
            asset_paths.compute_public_path(source, 'swfs', :ext => 'swf')
          else
            compute_public_path(source, 'swfs', 'swf', include_host)
          end
        end
        alias_method :path_to_swf, :swf_path # aliased to avoid conflicts with a swf_path named route
      end
    end
  end
end
