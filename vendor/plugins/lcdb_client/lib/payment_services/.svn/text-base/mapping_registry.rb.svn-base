require 'payment_services/service_classes'
require 'soap/mapping'

module LCDB

module PaymentServiceWSImplServiceMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsFaults = "http://domain.rst1.com/Faults"
  NsGlobal = "http://domain.rst1.com/Global"
  NsPaymentdetail = "http://domain.rst1.com/Paymentdetail"
  NsResult = "http://domain.rst1.com/Result"
  NsRsPayment = "http://domain.rst1.com/services/business/rsPayment"

  EncodedRegistry.register(
    :class => LCDB::AuthCreditCard,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCard"),
    :schema_element => [
      ["authRec", ["LCDB::AuthCreditCardRequestType", XSD::QName.new(nil, "authRec")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::AuthCreditCardRequestType,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCardRequestType"),
    :schema_element => [
      ["shipPostalCode", ["SOAP::SOAPString", XSD::QName.new(nil, "shipPostalCode")]],
      ["postalCode", ["SOAP::SOAPString", XSD::QName.new(nil, "postalCode")]],
      ["shipCity", ["SOAP::SOAPString", XSD::QName.new(nil, "shipCity")]],
      ["currencyCode", ["SOAP::SOAPString", XSD::QName.new(nil, "currencyCode")]],
      ["customerip", ["SOAP::SOAPString", XSD::QName.new(nil, "customerip")]],
      ["shipState", ["SOAP::SOAPString", XSD::QName.new(nil, "shipState")]],
      ["state", ["SOAP::SOAPString", XSD::QName.new(nil, "state")]],
      ["cnty", ["SOAP::SOAPString", XSD::QName.new(nil, "cnty")]],
      ["shipCuontry", ["SOAP::SOAPString", XSD::QName.new(nil, "shipCuontry")]],
      ["shipAddr", ["SOAP::SOAPString", XSD::QName.new(nil, "shipAddr")]],
      ["bankAcctUseId", ["SOAP::SOAPString", XSD::QName.new(nil, "bankAcctUseId")]],
      ["address1", ["SOAP::SOAPString", XSD::QName.new(nil, "address1")]],
      ["address2", ["SOAP::SOAPString", XSD::QName.new(nil, "address2")]],
      ["address3", ["SOAP::SOAPString", XSD::QName.new(nil, "address3")]],
      ["country", ["SOAP::SOAPString", XSD::QName.new(nil, "country")]],
      ["city", ["SOAP::SOAPString", XSD::QName.new(nil, "city")]],
      ["amount", ["SOAP::SOAPString", XSD::QName.new(nil, "amount")]],
      ["orgId", ["SOAP::SOAPString", XSD::QName.new(nil, "orgId")]],
      ["customerId", ["SOAP::SOAPString", XSD::QName.new(nil, "customerId")]],
      ["stt", ["SOAP::SOAPString", XSD::QName.new(nil, "stt")]],
      ["expireDate", ["SOAP::SOAPString", XSD::QName.new(nil, "expireDate")]],
      ["cvv", ["SOAP::SOAPString", XSD::QName.new(nil, "cvv")]],
      ["variable", ["SOAP::SOAPString", XSD::QName.new(nil, "variable")]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::AuthCreditCardResponse,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCardResponse"),
    :schema_element => [
      ["v_return", ["LCDB::AuthCreditCardResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::AuthCreditCardResponseType,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCardResponseType"),
    :schema_element => [
      ["authCode", ["SOAP::SOAPString", XSD::QName.new(nil, "authCode")]],
      ["paymentProcessorId", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentProcessorId")]],
      ["avsResult", ["SOAP::SOAPString", XSD::QName.new(nil, "avsResult")]],
      ["cvvResult", ["SOAP::SOAPString", XSD::QName.new(nil, "cvvResult")]],
      ["vendor", ["SOAP::SOAPString", XSD::QName.new(nil, "vendor")]],
      ["attempts", ["SOAP::SOAPString", XSD::QName.new(nil, "attempts")]],
      ["gcStoreId", ["SOAP::SOAPString", XSD::QName.new(nil, "gcStoreId")]],
      ["paymentProductId", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentProductId")]],
      ["authAmount", ["SOAP::SOAPString", XSD::QName.new(nil, "authAmount")]],
      ["paymentMethodId", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentMethodId")]],
      ["gcOrderId", ["SOAP::SOAPString", XSD::QName.new(nil, "gcOrderId")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::PaymentDetail,
    :schema_type => XSD::QName.new(NsPaymentdetail, "PaymentDetail"),
    :schema_element => [
      ["customerId", "SOAP::SOAPInt"],
      ["currency", "SOAP::SOAPString"],
      ["orgId", "SOAP::SOAPInt"],
      ["acctNum", "SOAP::SOAPString"],
      ["acctName", "SOAP::SOAPString"],
      ["expireDate", "SOAP::SOAPString"],
      ["primaryFlag", "SOAP::SOAPString"],
      ["paymentAddress", "LCDB::Address"],
      ["updateInvoice", "SOAP::SOAPString"],
      ["bankName", "SOAP::SOAPString"],
      ["bankCntry", "SOAP::SOAPString"],
      ["bankCode", "SOAP::SOAPString"],
      ["billName", "LCDB::Person"],
      ["licenseGUID", "SOAP::SOAPString"],
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "paymentId") => "SOAP::SOAPInt"
    }
  )

  EncodedRegistry.register(
    :class => LCDB::FaultResponse,
    :schema_type => XSD::QName.new(NsFaults, "FaultResponse"),
    :schema_element => [
      ["errorType", "SOAP::SOAPInt"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )

  EncodedRegistry.register(
    :class => LCDB::Result,
    :schema_type => XSD::QName.new(NsResult, "Result"),
    :schema_element => [
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )

  EncodedRegistry.register(
    :class => LCDB::Address,
    :schema_type => XSD::QName.new(NsGlobal, "Address"),
    :schema_element => [
      ["city", "SOAP::SOAPString"],
      ["adrLine1", "SOAP::SOAPString"],
      ["adrLine2", "SOAP::SOAPString"],
      ["postalCode", "SOAP::SOAPString"],
      ["country", "SOAP::SOAPString"],
      ["email", "SOAP::SOAPString"],
      ["phone", "SOAP::SOAPString"],
      ["mobile", "SOAP::SOAPString"],
      ["state", "SOAP::SOAPString"],
      ["timeZone", "SOAP::SOAPString"],
      ["alternateEmail", "SOAP::SOAPString"],
      ["county", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "adroid") => "SOAP::SOAPLong"
    }
  )

  EncodedRegistry.register(
    :class => LCDB::Person,
    :schema_type => XSD::QName.new(NsGlobal, "Person"),
    :schema_element => [
      ["firstName", "SOAP::SOAPString"],
      ["lastName", "SOAP::SOAPString"],
      ["dob", "SOAP::SOAPString"],
      ["gender", "LCDB::GenderEnum"],
      ["displayName", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "usroid") => "SOAP::SOAPLong"
    }
  )

  EncodedRegistry.register(
    :class => LCDB::GenderEnum,
    :schema_type => XSD::QName.new(NsGlobal, "GenderEnum")
  )

  LiteralRegistry.register(
    :class => LCDB::AuthCreditCard,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCard"),
    :schema_element => [
      ["authRec", ["LCDB::AuthCreditCardRequestType", XSD::QName.new(nil, "authRec")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::AuthCreditCardRequestType,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCardRequestType"),
    :schema_element => [
      ["shipPostalCode", ["SOAP::SOAPString", XSD::QName.new(nil, "shipPostalCode")]],
      ["postalCode", ["SOAP::SOAPString", XSD::QName.new(nil, "postalCode")]],
      ["shipCity", ["SOAP::SOAPString", XSD::QName.new(nil, "shipCity")]],
      ["currencyCode", ["SOAP::SOAPString", XSD::QName.new(nil, "currencyCode")]],
      ["customerip", ["SOAP::SOAPString", XSD::QName.new(nil, "customerip")]],
      ["shipState", ["SOAP::SOAPString", XSD::QName.new(nil, "shipState")]],
      ["state", ["SOAP::SOAPString", XSD::QName.new(nil, "state")]],
      ["cnty", ["SOAP::SOAPString", XSD::QName.new(nil, "cnty")]],
      ["shipCuontry", ["SOAP::SOAPString", XSD::QName.new(nil, "shipCuontry")]],
      ["shipAddr", ["SOAP::SOAPString", XSD::QName.new(nil, "shipAddr")]],
      ["bankAcctUseId", ["SOAP::SOAPString", XSD::QName.new(nil, "bankAcctUseId")]],
      ["address1", ["SOAP::SOAPString", XSD::QName.new(nil, "address1")]],
      ["address2", ["SOAP::SOAPString", XSD::QName.new(nil, "address2")]],
      ["address3", ["SOAP::SOAPString", XSD::QName.new(nil, "address3")]],
      ["country", ["SOAP::SOAPString", XSD::QName.new(nil, "country")]],
      ["city", ["SOAP::SOAPString", XSD::QName.new(nil, "city")]],
      ["amount", ["SOAP::SOAPString", XSD::QName.new(nil, "amount")]],
      ["orgId", ["SOAP::SOAPString", XSD::QName.new(nil, "orgId")]],
      ["customerId", ["SOAP::SOAPString", XSD::QName.new(nil, "customerId")]],
      ["stt", ["SOAP::SOAPString", XSD::QName.new(nil, "stt")]],
      ["expireDate", ["SOAP::SOAPString", XSD::QName.new(nil, "expireDate")]],
      ["cvv", ["SOAP::SOAPString", XSD::QName.new(nil, "cvv")]],
      ["variable", ["SOAP::SOAPString", XSD::QName.new(nil, "variable")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::AuthCreditCardResponse,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCardResponse"),
    :schema_element => [
      ["v_return", ["LCDB::AuthCreditCardResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::AuthCreditCardResponseType,
    :schema_type => XSD::QName.new(NsRsPayment, "authCreditCardResponseType"),
    :schema_element => [
      ["authCode", ["SOAP::SOAPString", XSD::QName.new(nil, "authCode")]],
      ["paymentProcessorId", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentProcessorId")]],
      ["avsResult", ["SOAP::SOAPString", XSD::QName.new(nil, "avsResult")]],
      ["cvvResult", ["SOAP::SOAPString", XSD::QName.new(nil, "cvvResult")]],
      ["vendor", ["SOAP::SOAPString", XSD::QName.new(nil, "vendor")]],
      ["attempts", ["SOAP::SOAPString", XSD::QName.new(nil, "attempts")]],
      ["gcStoreId", ["SOAP::SOAPString", XSD::QName.new(nil, "gcStoreId")]],
      ["paymentProductId", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentProductId")]],
      ["authAmount", ["SOAP::SOAPString", XSD::QName.new(nil, "authAmount")]],
      ["paymentMethodId", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentMethodId")]],
      ["gcOrderId", ["SOAP::SOAPString", XSD::QName.new(nil, "gcOrderId")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::PaymentDetail,
    :schema_type => XSD::QName.new(NsPaymentdetail, "PaymentDetail"),
    :schema_element => [
      ["customerId", "SOAP::SOAPInt"],
      ["currency", "SOAP::SOAPString"],
      ["orgId", "SOAP::SOAPInt"],
      ["acctNum", "SOAP::SOAPString"],
      ["acctName", "SOAP::SOAPString"],
      ["expireDate", "SOAP::SOAPString"],
      ["primaryFlag", "SOAP::SOAPString"],
      ["paymentAddress", "LCDB::Address"],
      ["updateInvoice", "SOAP::SOAPString"],
      ["bankName", "SOAP::SOAPString"],
      ["bankCntry", "SOAP::SOAPString"],
      ["bankCode", "SOAP::SOAPString"],
      ["billName", "LCDB::Person"],
      ["licenseGUID", "SOAP::SOAPString"],
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "paymentId") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::FaultResponse,
    :schema_type => XSD::QName.new(NsFaults, "FaultResponse"),
    :schema_element => [
      ["errorType", "SOAP::SOAPInt"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::Result,
    :schema_type => XSD::QName.new(NsResult, "Result"),
    :schema_element => [
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::Address,
    :schema_type => XSD::QName.new(NsGlobal, "Address"),
    :schema_element => [
      ["city", "SOAP::SOAPString"],
      ["adrLine1", "SOAP::SOAPString"],
      ["adrLine2", "SOAP::SOAPString"],
      ["postalCode", "SOAP::SOAPString"],
      ["country", "SOAP::SOAPString"],
      ["email", "SOAP::SOAPString"],
      ["phone", "SOAP::SOAPString"],
      ["mobile", "SOAP::SOAPString"],
      ["state", "SOAP::SOAPString"],
      ["timeZone", "SOAP::SOAPString"],
      ["alternateEmail", "SOAP::SOAPString"],
      ["county", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "adroid") => "SOAP::SOAPLong"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::Person,
    :schema_type => XSD::QName.new(NsGlobal, "Person"),
    :schema_element => [
      ["firstName", "SOAP::SOAPString"],
      ["lastName", "SOAP::SOAPString"],
      ["dob", "SOAP::SOAPString"],
      ["gender", "LCDB::GenderEnum"],
      ["displayName", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "usroid") => "SOAP::SOAPLong"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::GenderEnum,
    :schema_type => XSD::QName.new(NsGlobal, "GenderEnum")
  )

  LiteralRegistry.register(
    :class => LCDB::AuthCreditCard,
    :schema_name => XSD::QName.new(NsRsPayment, "authCreditCard"),
    :schema_element => [
      ["authRec", ["LCDB::AuthCreditCardRequestType", XSD::QName.new(nil, "authRec")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::AuthCreditCardResponse,
    :schema_name => XSD::QName.new(NsRsPayment, "authCreditCardResponse"),
    :schema_element => [
      ["v_return", ["LCDB::AuthCreditCardResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::PaymentDetail,
    :schema_name => XSD::QName.new(NsRsPayment, "getPaymentDeatilResponse"),
    :schema_element => [
      ["customerId", "SOAP::SOAPInt"],
      ["currency", "SOAP::SOAPString"],
      ["orgId", "SOAP::SOAPInt"],
      ["acctNum", "SOAP::SOAPString"],
      ["acctName", "SOAP::SOAPString"],
      ["expireDate", "SOAP::SOAPString"],
      ["primaryFlag", "SOAP::SOAPString"],
      ["paymentAddress", "LCDB::Address"],
      ["updateInvoice", "SOAP::SOAPString"],
      ["bankName", "SOAP::SOAPString"],
      ["bankCntry", "SOAP::SOAPString"],
      ["bankCode", "SOAP::SOAPString"],
      ["billName", "LCDB::Person"],
      ["licenseGUID", "SOAP::SOAPString"],
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "paymentId") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::PaymentDetail,
    :schema_name => XSD::QName.new(NsPaymentdetail, "getPaymentDetail"),
    :schema_element => [
      ["customerId", "SOAP::SOAPInt"],
      ["currency", "SOAP::SOAPString"],
      ["orgId", "SOAP::SOAPInt"],
      ["acctNum", "SOAP::SOAPString"],
      ["acctName", "SOAP::SOAPString"],
      ["expireDate", "SOAP::SOAPString"],
      ["primaryFlag", "SOAP::SOAPString"],
      ["paymentAddress", "LCDB::Address"],
      ["updateInvoice", "SOAP::SOAPString"],
      ["bankName", "SOAP::SOAPString"],
      ["bankCntry", "SOAP::SOAPString"],
      ["bankCode", "SOAP::SOAPString"],
      ["billName", "LCDB::Person"],
      ["licenseGUID", "SOAP::SOAPString"],
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "paymentId") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::FaultResponse,
    :schema_name => XSD::QName.new(NsRsPayment, "messageServiceFault"),
    :schema_element => [
      ["errorType", "SOAP::SOAPInt"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::PaymentDetail,
    :schema_name => XSD::QName.new(NsPaymentdetail, "setPaymentDetail"),
    :schema_element => [
      ["customerId", "SOAP::SOAPInt"],
      ["currency", "SOAP::SOAPString"],
      ["orgId", "SOAP::SOAPInt"],
      ["acctNum", "SOAP::SOAPString"],
      ["acctName", "SOAP::SOAPString"],
      ["expireDate", "SOAP::SOAPString"],
      ["primaryFlag", "SOAP::SOAPString"],
      ["paymentAddress", "LCDB::Address"],
      ["updateInvoice", "SOAP::SOAPString"],
      ["bankName", "SOAP::SOAPString"],
      ["bankCntry", "SOAP::SOAPString"],
      ["bankCode", "SOAP::SOAPString"],
      ["billName", "LCDB::Person"],
      ["licenseGUID", "SOAP::SOAPString"],
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "paymentId") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::Result,
    :schema_name => XSD::QName.new(NsRsPayment, "setPaymentDetailResponse"),
    :schema_element => [
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::PaymentDetail,
    :schema_name => XSD::QName.new(NsPaymentdetail, "paymentDetail"),
    :schema_element => [
      ["customerId", "SOAP::SOAPInt"],
      ["currency", "SOAP::SOAPString"],
      ["orgId", "SOAP::SOAPInt"],
      ["acctNum", "SOAP::SOAPString"],
      ["acctName", "SOAP::SOAPString"],
      ["expireDate", "SOAP::SOAPString"],
      ["primaryFlag", "SOAP::SOAPString"],
      ["paymentAddress", "LCDB::Address"],
      ["updateInvoice", "SOAP::SOAPString"],
      ["bankName", "SOAP::SOAPString"],
      ["bankCntry", "SOAP::SOAPString"],
      ["bankCode", "SOAP::SOAPString"],
      ["billName", "LCDB::Person"],
      ["licenseGUID", "SOAP::SOAPString"],
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "paymentId") => "SOAP::SOAPInt"
    }
  )

  LiteralRegistry.register(
    :class => LCDB::Result,
    :schema_name => XSD::QName.new(NsResult, "result"),
    :schema_element => [
      ["result", "SOAP::SOAPString"],
      ["message", "SOAP::SOAPString"]
    ],
    :schema_attribute => {
      XSD::QName.new(nil, "oid") => "SOAP::SOAPInt"
    }
  )
end

end
