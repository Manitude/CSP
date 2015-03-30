# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.

# In order to include a YUI Editor into a Rails app, do the following:
# 1. In your layout, add the following line within the <head> section on any page that needs to contain a YUI editor:
#   <%= render(:inline => RosettaStone::YuiIntegration.layout_includes(:rte)) %>
# 2. In a form, make a <textarea> element with a defined DOM id.
# 3. On the same page as the form, add a line line the following:
#   <%= javascript_tag(RosettaStone::YuiIntegration.inline_js('dom_id_for_textarea', {:title => 'Titlebar Text'})) %>
#   See default_inline_js_options (below) for more configurable options!
#
# Option notes:
#
# - Pass in :switching_enabled => true to add the following methods to the editor object.
#   - editorObject.switchToRawHtml   (textarea, editing raw HTML code)
#   - editorObject.switchToWysiwyg   (default, using YUI Editor for WYSIWYG editing)

module RosettaStone
  module YuiIntegration
    BASE_DIR = File.join(File.dirname(__FILE__), 'yui_integration')
    INLINE_JS = File.join(BASE_DIR, 'inline_js.html.erb')

    class << self
      # Sample usage and what gets included as a result:
      # layout_contents           => core + rte (default for backward compatibility)
      # layout_contents(:rte)     => core + rte
      # layout_contents(:core)    => core
      # layout_contents(:tabview) => core + tabview
      # layout_contents(:rte, :tabview) => core + rte + tabview
      def layout_includes(*purposes)
        purposes.push(:rte) if purposes.empty? # default to RTS for backward compatibility
        purposes.unshift(:core) # always prepend the core includes
        purposes.uniq!

        purposes.map {|purpose| layout_contents(purpose)}.join("\n")
      end

      def inline_js(dom_id, options = {})
        raise ArgumentError, 'Must pass a valid DOM id' if dom_id.blank?
        @options = default_inline_js_options(dom_id).merge(options)
        ERB.new(File.read(INLINE_JS)).result binding
      end

      def version_string
        '2.6.0'
      end

      def default_inline_js_options(dom_id)
        {
          :dom_id => dom_id,
          :variable_name => dom_id.camelize(:lower),
          :title => 'Text Editor',
          :height => '300px',
          :width => '522px',
          :handle_submit => true,
          :switching_enabled => false
        }
      end

    private
      def layout_contents(purpose)
        File.read(File.join(BASE_DIR, "layout_includes_#{purpose}.html.erb"))
      end
    end
  end
end
