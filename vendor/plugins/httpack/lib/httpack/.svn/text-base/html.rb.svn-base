module PlanetArgon # :nodoc:
  module HttPack # :nodoc:
    # A collection of helpers to assist in doing XHTML right.
    module Html
      # Renders an xhtml doctype declaration for the document's prolog. Defaults to xhtml transitional.
      # <tt>xhtml_doctype :strict</tt>
      def xhtml_doctype doctype = :transitional
        doctype ||= :transitional
        raise 'Invalid doctype' unless [:transitional, :strict, :frameset].include? doctype
        case doctype
        when :transitional
          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
        when :strict
          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
        when :frameset
          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
        end
      end

      # Displays an html tag, complete with xhtml namespace and language. Accepts arbitrary parameters, but gives
      # special treatment to <tt>:lang</tt>, displaying it in the <tt>lang</tt> and <tt>xml:lang</tt> parameters.
      # Defaults to English (en) if no <tt>:lang</tt> is specified. See
      # http://diveintoaccessibility.org/day_7_identifying_your_language.html for more information.
      #   html_tag
      #     # => '<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">'
      #   html_tag :lang => 'de'
      #     # => '<html xmlns="http://www.w3.org/1999/xhtml" lang="de" xml:lang="de">'
      def html_tag options = {}
        options[:lang]       ||= 'en'
        options[:'xml:lang'] = options[:lang]
        options[:xmlns]      = 'http://www.w3.org/1999/xhtml'
        tag( 'html', options.stringify_keys, true )
      end
    
      # End html tag.
      def end_html_tag; "</html>" end

      def body_tag options = {}
        hash = HashWithIndifferentAccess.new( options )
        tag( 'body', hash.stringify_keys, true )
      end

      # End body tag
      def end_body_tag; '</body>' end
    end
  end
end

ActionView::Base.send :include, PlanetArgon::HttPack::Html
