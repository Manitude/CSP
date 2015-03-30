# -*- encoding : utf-8 -*-
# RenderContext makes it easy to use render() from ActionView::Base from a context outside
# of a controller.  For example:
#
# xml = RosettaStone::RenderContext.render(:file => '/some/path_to/template.xml.builder', :locals => {:var => true})
#
# inspiration and original implementation from http://blog.choonkeat.com/weblog/2006/08/rails-calling-r.html
if defined?(ActionView::Base)
  if Rails.version >= '3'
    module RosettaStone
      class RenderContext
        def self.render(options, assigns = {})
          unless assigns == {}
            raise ArgumentError.new('RenderContext does not support assigns for Rails 3 at the moment')
          end
          status, headers, body = RenderingController.action(:show).call(
            'REQUEST_METHOD' => 'GET',
            'rack.input' => '',
            'rosetta_stone.standalone_render_options' => options)
          body.body
        end

        class RenderingController < ActionController::Base
          def show
            render env['rosetta_stone.standalone_render_options']
          end
        end
      end
    end
  else
    module RosettaStone
      class RenderContext
        # set up a fake controller with some context to make ActionView happy
        class FakeController
          def logger
            Rails.logger
          end

          def headers
            {}
          end

          def response
            OpenStruct.new({:content_type => Mime::XML})
          end

          def request
            OpenStruct.new({:ssl? => false, :template_format => :html, :parameters => {}})
          end
        end

        class << self
          def render(options, assigns = {})
            viewer = ActionView::Base.new(Rails::Configuration.new.view_path, assigns, FakeController.new)
            viewer.render options
          end
        end
      end
    end
  end
end
