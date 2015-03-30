require 'claim_services/service_classes.rb'
require 'claim_services/mapping_registry.rb'
require 'soap/rpc/driver'

module LCDB

class ClaimServices < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://ashdevas1.lan.flt:8080/business.services.claims/ClaimService"

  Methods = [
    [ "",
      "checkOutTokens",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "checkOutTokensRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "checkOutTokensResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "deactivateKey",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "deactivateKeyRequest"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "deactivateKeyResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "generateActivationID",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "generateActivationIDRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "generateActivationIDResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "getAssociatedFeatures",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "getAssociatedFeaturesRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "getAssociatedFeaturesResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "getFNOCatCode",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "getFNOCatCodeRequest"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "getFNOCatCodeResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "pingLCDBServices",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "pingLCDBServicesRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "pingLCDBServicesResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "setDownloadTime",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "setDownloadTimeRequest"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "setDownloadTimeResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "updatePosaStatus",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "updatePosaStatusRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "updatePosaStatusResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "validatePOSA",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "validatePOSARequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "validatePOSAResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "validateSerialNumber",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "validateSerialNumberRequest"]],
        ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/claim", "validateSerialNumberResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = ClaimServicesImplServiceMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = ClaimServicesImplServiceMappingRegistry::LiteralRegistry
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
