require 'libxml'

class EschoolResponseParser

  def initialize(xml_text)
    document = LibXML::XML::Document.string(xml_text)
    @xml = document.find('//eschool_session')
  end

  def parse
    eschool_sessions = []
    @xml.each do |xml_node|
      session = {}
      xml_node.each_element do |element| 
        session[element.name.to_sym] = element.content
      end
      eschool_sessions <<  Eschool::Session.new(session)
    end
    eschool_sessions
  end
end