require 'libxml'

class SaasResponseParser

  def initialize(xml_text)
    document = LibXML::XML::Document.string(xml_text)
    @xml = document.find('//slot')
  end

  def parse
    saas_sessions = []
    @xml.each do |xml_node|
      node = xml_node.to_hash
      session = {}
      session[:slot_id] = node["slot"]["title"]["id"]
      session[:session_start_time] =  node["slot"]["start"]
      session[:count] = node["slot"]["count"]["__content__"].to_i
      saas_sessions <<  SuperSaas::Session.new(session)
    end
    saas_sessions
  end

  def self.parse_reservations(response_body)
    res = []
    response = JSON.parse(response_body)
    response["b"].each do |details|
      booking = {}
      booking[:booking_id] = details.first
      booking[:email] = details.last
      booking[:full_name] = details.at(-2)
      booking[:guid] = details[4].split(" ").first
      res << booking
    end 
    [res,response["count"]]
  end 

  def self.parse_rsa_reservations(response_body)
    res = []
    response = JSON.parse(response_body)
    response["b"].each do |details|
      booking = {}
      booking[:booking_id] = details.first
      booking[:full_name] = details.at(-3)
      booking[:email] = details.at(-2)
    #  booking[:contact_type] = JSON.parse(details.last)["t"]
    #  booking[:contact_point] = JSON.parse(details.last)["v"]
      booking[:guid] = details[4].split(" ").first
      res << booking
    end 
    [res,response["count"]]
  end

end