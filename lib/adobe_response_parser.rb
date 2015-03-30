require 'libxml'

class AdobeResponseParser

  def initialize(xml_text)
    document = LibXML::XML::Document.string(xml_text)
    @xml = document.find('//row')
  end

  def parse
    participants = []
    @xml.each do |xml_node|
      participant = {}
      participant["principal-id"] = xml_node["principal-id"]
      xml_node.each_element do |element| 
        participant[element.name.to_sym] = element.content
      end
      participants <<  participant
    end
    participants
  end
end