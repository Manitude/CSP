require 'payment_services/service_classes'
require 'payment_services/mapping_registry'
require 'soap/rpc/driver'

module LCDB

class PaymentServiceWS < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://ashstgas0.lan.flt:8080/business.services/PaymentService"

  Methods = [
    [ "authCreditCard",
      "authCreditCard",
      [ ["in", "authCreditCard", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/rsPayment", "authCreditCard"]],
        ["out", "authCreditCardResponse", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/rsPayment", "authCreditCardResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "getPaymentDetail",
      "getPaymentDetail",
      [ ["in", "getPaymentDetail", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/rsPayment", "getPaymentDetail"]],
        ["out", "getPaymentDeatilResponse", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/rsPayment", "getPaymentDeatilResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {"LCDB::MessageServiceFault"=>{:use=>"literal", :encodingstyle=>"document", :ns=>"http://domain.rst1.com/services/business/rsPayment", :namespace=>nil, :name=>"messageServiceFault"}} }
    ],
    [ "setPaymentDetail",
      "setPaymentDetail",
      [ ["in", "setPaymentDetail", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/rsPayment", "setPaymentDetail"]],
        ["out", "setPaymentDetailResponse", ["::SOAP::SOAPElement", "http://domain.rst1.com/services/business/rsPayment", "setPaymentDetailResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {"LCDB::MessageServiceFault"=>{:use=>"literal", :encodingstyle=>"document", :ns=>"http://domain.rst1.com/services/business/rsPayment", :namespace=>nil, :name=>"messageServiceFault"}} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = PaymentServiceWSImplServiceMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = PaymentServiceWSImplServiceMappingRegistry::LiteralRegistry
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
