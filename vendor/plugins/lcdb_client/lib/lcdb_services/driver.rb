require 'lcdb_services/service_classes'
require 'lcdb_services/mapping_registry'
require 'soap/rpc/driver'

module LCDB

  class LCDBServices < ::SOAP::RPC::Driver
    DefaultEndpointUrl = "http://ashstgas0.lan.flt:8080/business.services/LCDService"

    Methods = [
      [ "",
        "checkTrial",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "checkTrial"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "checkTrialResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "createBillingProfile",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "createBillingProfile"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "createBillingProfileResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "getCustomerDetails",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getCustomerDetails"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getCustomerDetailsResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "getMarketValue",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getMarketValue"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getMarketValueResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "getOrder",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getOrder"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getOrderResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "getPastDuePayments",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getPastDuePayments"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getPastDuePaymentsResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "getRenewal",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getRenewal"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "getRenewalResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "pingLCDBServices",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "pingLCDBServices"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "pingLCDBServicesResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "setCustomerDetails",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setCustomerDetails"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setCustomerDetailsResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "setCustomerNumber",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setCustomerNumber"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setCustomerNumberResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "setOrder",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setOrder"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setOrderResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "setPrGuid",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setPrGuid"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setPrGuidResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "setProductRights",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setProductRights"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setProductRightsResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "setRenewal",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setRenewal"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "setRenewalResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "switchAccount",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "switchAccount"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "switchAccountResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "switchLanguage",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "switchLanguage"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "switchLanguageResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "updateLicense",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "updateLicense"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "updateLicenseResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "updateOrderPayStatus",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "updateOrderPayStatus"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "updateOrderPayStatusResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "updatePersonDetails",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "updatePersonDetails"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "updatePersonDetailsResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ],
      [ "",
        "validateProductRights",
        [ ["in", "param", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "validateProductRights"]],
          ["out", "result", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/lcd", "validateProductRightsResponse"]] ],
          { :request_style =>  :document, :request_use =>  :literal,
            :response_style => :document, :response_use => :literal,
            :faults => {} }
    ]
    ]

    def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = LCDBServicesImplServiceMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = LCDBServicesImplServiceMappingRegistry::LiteralRegistry
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
