# This file is not required by default; viper requires it in config/.

class SystemReadiness::LibxmlSax2Modifications < SystemReadiness::Base
  class << self
    def verify
      mock_sax_parser = MockSaxParser.new
      parser = LibXML::XML::SaxParser.string('<?xml version="1.0" encoding="UTF-8" ?><elem xmlns:n1="http://rs.com"><stuff n1:attr="something"></stuff></elem>')
      parser.callbacks = mock_sax_parser
      parser.parse
      if mock_sax_parser.using_modified_libxml_ruby
        return true
      else
        return false, "the libxml-ruby library has not been compiled for your architecture with the necessary modifications.  Please compile a new version for your architecture (#{RUBY_PLATFORM})"
      end
    rescue Exception => e
      return false, "failed: #{e.message}"
    end
  end

  class MockSaxParser
    attr_accessor :using_modified_libxml_ruby
    include LibXML::XML::SaxParser::Callbacks

    def on_start_element_ns(name, attr_hash, prefix, uri, namespaces)
      self.using_modified_libxml_ruby = attr_hash.any?{|key,value| value.is_a?(Hash)}
    end

    def on_error(msg)
      raise ParseError.new(msg)
    end
  end
end
