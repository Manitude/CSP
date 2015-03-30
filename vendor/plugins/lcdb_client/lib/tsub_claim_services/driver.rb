require 'tsub_claim_services/service_classes.rb'
require 'tsub_claim_services/mapping_registry.rb'
require 'soap/rpc/driver'

module LCDB

class TsubClaimServices < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://ashdevias01.rosettastone.local:7003/ClaimServices/ClaimServices"

  Methods = [
    [ "",
      "checkOutTokens",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://claimservices/", "checkOutTokens"]],
        ["in", "token", ["::SOAP::SOAPElement", "http://claimservices/", "token"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://claimservices/", "checkOutTokensResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "getAssociatedFeatures",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://claimservices/", "getAssociatedFeatures"]],
        ["in", "token", ["::SOAP::SOAPElement", "http://claimservices/", "token"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://claimservices/", "getAssociatedFeaturesResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "pingLCDBServices",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://claimservices/", "pingLCDBServices"]],
        ["in", "token", ["::SOAP::SOAPElement", "http://claimservices/", "token"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://claimservices/", "pingLCDBServicesResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = ClaimServicesMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = ClaimServicesMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end


end
