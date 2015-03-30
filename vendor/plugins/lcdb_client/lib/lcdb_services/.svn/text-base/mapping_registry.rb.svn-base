require 'lcdb_services/service_classes'
require 'soap/mapping'

module LCDB

  module LCDBServicesImplServiceMappingRegistry
    EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
    LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
    NsLcd = "http://domain.rst1.com/services/business/lcd"

    EncodedRegistry.register(
      :class => LCDB::GetOrder,
      :schema_type => XSD::QName.new(NsLcd, "getOrder"),
      :schema_element => [
        ["arg0", ["LCDB::GetOrderDetailsRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetOrderDetailsRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getOrderDetailsRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["pastDueOnly", ["SOAP::SOAPString", XSD::QName.new(nil, "pastDueOnly")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetOrderResponse,
      :schema_type => XSD::QName.new(NsLcd, "getOrderResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetOrderDetailsResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetOrderDetailsResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getOrderDetailsResponseType"),
      :schema_element => [
        ["order", ["LCDB::Order[]", XSD::QName.new(nil, "order")], [0, nil]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::Order,
      :schema_type => XSD::QName.new(NsLcd, "order"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")]],
        ["order_number", ["SOAP::SOAPString", XSD::QName.new(nil, "order_number")]],
        ["customer_number", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_number")], [0, 1]],
        ["ordered_date", ["SOAP::SOAPString", XSD::QName.new(nil, "ordered_date")]],
        ["orig_sys_document_ref", ["SOAP::SOAPString", XSD::QName.new(nil, "orig_sys_document_ref")], [0, 1]],
        ["sales_channel", ["SOAP::SOAPString", XSD::QName.new(nil, "sales_channel")], [0, 1]],
        ["order_total", ["SOAP::SOAPDouble", XSD::QName.new(nil, "order_total")], [0, 1]],
        ["captureStatus", ["SOAP::SOAPString", XSD::QName.new(nil, "captureStatus")], [0, 1]],
        ["payment_type", ["SOAP::SOAPString", XSD::QName.new(nil, "payment_type")], [0, 1]],
        ["cancel_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "cancel_flag")], [0, 1]],
        ["org", ["SOAP::SOAPString", XSD::QName.new(nil, "org")]],
        ["orderItems", ["LCDB::OrderItems[]", XSD::QName.new(nil, "orderItems")], [0, nil]],
        ["past_due_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "past_due_flag")], [0, 1]],
        ["due_date", ["SOAP::SOAPString", XSD::QName.new(nil, "due_date")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::OrderItems,
      :schema_type => XSD::QName.new(NsLcd, "orderItems"),
      :schema_element => [
        ["order_line_id", ["SOAP::SOAPInt", XSD::QName.new(nil, "order_line_id")]],
        ["item", ["SOAP::SOAPString", XSD::QName.new(nil, "item")]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")]],
        ["line_status", ["SOAP::SOAPString", XSD::QName.new(nil, "line_status")], [0, 1]],
        ["pr_guid", ["SOAP::SOAPString", XSD::QName.new(nil, "pr_guid")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetOrder,
      :schema_type => XSD::QName.new(NsLcd, "setOrder"),
      :schema_element => [
        ["arg0", ["LCDB::Order", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetOrderResponse,
      :schema_type => XSD::QName.new(NsLcd, "setOrderResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GenericResponseType,
      :schema_type => XSD::QName.new(NsLcd, "genericResponseType"),
      :schema_element => [
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetCustomerDetails,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerDetails"),
      :schema_element => [
        ["arg0", ["LCDB::Customer", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::Customer,
      :schema_type => XSD::QName.new(NsLcd, "customer"),
      :schema_element => [
        ["customer_number", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_number")], [0, 1]],
        ["customer_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_flag")]],
        ["learner_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "learner_flag")]],
        ["masterGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "masterGuid")]],
        ["sold_to_org_id", ["SOAP::SOAPString", XSD::QName.new(nil, "sold_to_org_id")], [0, 1]],
        ["org_id", ["SOAP::SOAPString", XSD::QName.new(nil, "org_id")], [0, 1]],
        ["first_name", ["SOAP::SOAPString", XSD::QName.new(nil, "first_name")]],
        ["last_name", ["SOAP::SOAPString", XSD::QName.new(nil, "last_name")]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")]],
        ["orig_sys_document_ref", ["SOAP::SOAPString", XSD::QName.new(nil, "orig_sys_document_ref")], [0, 1]],
        ["customerDetails", ["LCDB::CustomerDetails[]", XSD::QName.new(nil, "customerDetails")], [0, nil]],
        ["license", ["LCDB::License[]", XSD::QName.new(nil, "license")], [0, nil]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::CustomerDetails,
      :schema_type => XSD::QName.new(NsLcd, "customerDetails"),
      :schema_element => [
        ["site_use_id", ["SOAP::SOAPString", XSD::QName.new(nil, "site_use_id")], [0, 1]],
        ["site_type", ["SOAP::SOAPString", XSD::QName.new(nil, "site_type")]],
        ["first_name", ["SOAP::SOAPString", XSD::QName.new(nil, "first_name")]],
        ["last_name", ["SOAP::SOAPString", XSD::QName.new(nil, "last_name")]],
        ["phonetic_first_name", ["SOAP::SOAPString", XSD::QName.new(nil, "phonetic_first_name")]],
        ["phonetic_last_name", ["SOAP::SOAPString", XSD::QName.new(nil, "phonetic_last_name")]],
        ["address1", ["SOAP::SOAPString", XSD::QName.new(nil, "address1")]],
        ["address2", ["SOAP::SOAPString", XSD::QName.new(nil, "address2")], [0, 1]],
        ["city", ["SOAP::SOAPString", XSD::QName.new(nil, "city")], [0, 1]],
        ["country", ["SOAP::SOAPString", XSD::QName.new(nil, "country")], [0, 1]],
        ["state_province", ["SOAP::SOAPString", XSD::QName.new(nil, "state_province")]],
        ["zip", ["SOAP::SOAPString", XSD::QName.new(nil, "zip")]],
        ["phone", ["SOAP::SOAPString", XSD::QName.new(nil, "phone")], [0, 1]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")]],
        ["credit_card_id", ["SOAP::SOAPString", XSD::QName.new(nil, "credit_card_id")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::License,
      :schema_type => XSD::QName.new(NsLcd, "license"),
      :schema_element => [
        ["licenseGUID", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGUID")], [0, 1]],
        ["masterFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "masterFlag")], [0, 1]],
        ["suspendStatus", ["SOAP::SOAPString", XSD::QName.new(nil, "suspendStatus")], [0, 1]],
        ["suspendReason", ["SOAP::SOAPString", XSD::QName.new(nil, "suspendReason")], [0, 1]],
        ["rsPan", ["SOAP::SOAPString", XSD::QName.new(nil, "rsPan")], [0, 1]],
        ["apiKey", ["SOAP::SOAPString", XSD::QName.new(nil, "apiKey")], [0, 1]],
        ["licenseDetails", ["LCDB::LicenseDetails[]", XSD::QName.new(nil, "licenseDetails")], [0, nil]],
        ["licenseType", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseType")], [0, 1]],
        ["serverURL", ["SOAP::SOAPString", XSD::QName.new(nil, "serverURL")], [0, 1]],
        ["serverCountry", ["SOAP::SOAPString", XSD::QName.new(nil, "serverCountry")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::LicenseDetails,
      :schema_type => XSD::QName.new(NsLcd, "licenseDetails"),
      :schema_element => [
        ["prGUIDRec", ["LCDB::PrguidType", XSD::QName.new(nil, "prGUIDRec")]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")]],
        ["autoRenewalFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "autoRenewalFlag")]],
        ["renewalPrice", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalPrice")], [0, 1]],
        ["renewalTerm", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalTerm")], [0, 1]],
        ["bankAcctusesId", ["SOAP::SOAPInt", XSD::QName.new(nil, "bankAcctusesId")], [0, 1]],
        ["processingId", ["SOAP::SOAPString", XSD::QName.new(nil, "processingId")], [0, 1]],
        ["vendor", ["SOAP::SOAPString", XSD::QName.new(nil, "vendor")], [0, 1]],
        ["item", ["SOAP::SOAPString", XSD::QName.new(nil, "item")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")], [0, 1]],
        ["trialFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "trialFlag")], [0, 1]],
        ["trialStartDate", ["SOAP::SOAPString", XSD::QName.new(nil, "trialStartDate")], [0, 1]],
        ["trialEndDate", ["SOAP::SOAPString", XSD::QName.new(nil, "trialEndDate")], [0, 1]],
        ["source", ["SOAP::SOAPString", XSD::QName.new(nil, "source")], [0, 1]],
        ["start_date", ["SOAP::SOAPString", XSD::QName.new(nil, "start_date")], [0, 1]],
        ["end_date", ["SOAP::SOAPString", XSD::QName.new(nil, "end_date")], [0, 1]],
        ["subscriptionID", ["SOAP::SOAPString", XSD::QName.new(nil, "subscriptionID")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    EncodedRegistry.register(
      :class => LCDB::PrguidType,
      :schema_type => XSD::QName.new(NsLcd, "prguidType"),
      :schema_element => [
        ["prGUID", ["SOAP::SOAPString[]", XSD::QName.new(nil, "prGUID")], [0, nil]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetCustomerDetailsResponse,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetCustomerNumber,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerNumber"),
      :schema_element => [
        ["arg0", ["LCDB::SetCustNumberRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetCustNumberRequestType,
      :schema_type => XSD::QName.new(NsLcd, "setCustNumberRequestType"),
      :schema_element => [
        ["bill_to_site_use_id", ["SOAP::SOAPString", XSD::QName.new(nil, "bill_to_site_use_id")], [0, 1]],
        ["customer_number", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_number")], [0, 1]],
        ["orig_sys_document_ref", ["SOAP::SOAPString", XSD::QName.new(nil, "orig_sys_document_ref")], [0, 1]],
        ["ship_to_site_use_id", ["SOAP::SOAPString", XSD::QName.new(nil, "ship_to_site_use_id")], [0, 1]],
        ["sold_to_org_id", ["SOAP::SOAPString", XSD::QName.new(nil, "sold_to_org_id")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetCustomerNumberResponse,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerNumberResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdatePersonDetails,
      :schema_type => XSD::QName.new(NsLcd, "updatePersonDetails"),
      :schema_element => [
        ["arg0", ["LCDB::UpdatePersonDetailRequest", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdatePersonDetailRequest,
      :schema_type => XSD::QName.new(NsLcd, "updatePersonDetailRequest"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["personDetails", ["LCDB::CustomerDetails", XSD::QName.new(nil, "personDetails")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdatePersonDetailsResponse,
      :schema_type => XSD::QName.new(NsLcd, "updatePersonDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetCustomerDetails,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetails"),
      :schema_element => [
        ["arg0", ["LCDB::GetCustomerDetailsRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetCustomerDetailsRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetailsRequestType"),
      :schema_element => [
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")], [0, 1]],
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetCustomerDetailsResponse,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetCustomerDetailsResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetCustomerDetailsResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetailsResponseType"),
      :schema_element => [
        ["customer", ["LCDB::Customer", XSD::QName.new(nil, "customer")], [0, 1]],
        ["pastDueResponse", ["LCDB::GetPastDueResponse", XSD::QName.new(nil, "pastDueResponse")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetPastDueResponse,
      :schema_type => XSD::QName.new(NsLcd, "getPastDueResponse"),
      :schema_element => [
        ["pastDue", ["LCDB::PastDuePaymentType[]", XSD::QName.new(nil, "pastDue")], [0, nil]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::PastDuePaymentType,
      :schema_type => XSD::QName.new(NsLcd, "pastDuePaymentType"),
      :schema_element => [
        ["missedPayments", ["SOAP::SOAPInt", XSD::QName.new(nil, "missedPayments")], [0, 1]],
        ["amountDue", ["SOAP::SOAPDouble", XSD::QName.new(nil, "amountDue")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["orderNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "orderNumber")], [0, 1]],
        ["paymentType", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentType")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdateOrderPayStatus,
      :schema_type => XSD::QName.new(NsLcd, "updateOrderPayStatus"),
      :schema_element => [
        ["arg0", ["LCDB::Order", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdateOrderPayStatusResponse,
      :schema_type => XSD::QName.new(NsLcd, "updateOrderPayStatusResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetRenewal,
      :schema_type => XSD::QName.new(NsLcd, "getRenewal"),
      :schema_element => [
        ["arg0", ["LCDB::GetRenewalRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetRenewalRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getRenewalRequestType"),
      :schema_element => [
        ["licenseGUID", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGUID")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "Language")], [0, 1]],
        ["pr_guid", ["SOAP::SOAPString", XSD::QName.new(nil, "pr_guid")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    EncodedRegistry.register(
      :class => LCDB::GetRenewalResponse,
      :schema_type => XSD::QName.new(NsLcd, "getRenewalResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetRenewalResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetRenewalResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getRenewalResponseType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["licenseDetails", ["LCDB::LicenseDetails[]", XSD::QName.new(nil, "licenseDetails")], [0, nil]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    EncodedRegistry.register(
      :class => LCDB::SetRenewal,
      :schema_type => XSD::QName.new(NsLcd, "setRenewal"),
      :schema_element => [
        ["arg0", ["LCDB::SetRenewalRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetRenewalRequestType,
      :schema_type => XSD::QName.new(NsLcd, "setRenewalRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["prGUID", ["SOAP::SOAPString", XSD::QName.new(nil, "prGUID")], [0, 1]],
        ["source", ["SOAP::SOAPString", XSD::QName.new(nil, "source")], [0,1]],
        ["autoRenewalFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "autoRenewalFlag")]],
        ["renewalPrice", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalPrice")], [0, 1]],
        ["renewalTerm", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalTerm")], [0, 1]],
        ["bankAcctUsesId", ["SOAP::SOAPInt", XSD::QName.new(nil, "bankAcctUsesId")], [0, 1]],
        ["rsPan", ["SOAP::SOAPString", XSD::QName.new(nil, "rsPan")], [0,1]],
        ["processingId", ["SOAP::SOAPString", XSD::QName.new(nil, "processingId")], [0, 1]],
        ["vendor", ["SOAP::SOAPString", XSD::QName.new(nil, "vendor")], [0, 1]],
        ["item", ["SOAP::SOAPString", XSD::QName.new(nil, "item")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    EncodedRegistry.register(
      :class => LCDB::SetRenewalResponse,
      :schema_type => XSD::QName.new(NsLcd, "setRenewalResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::PingLCDBServices,
      :schema_type => XSD::QName.new(NsLcd, "pingLCDBServices"),
      :schema_element => []
    )

    EncodedRegistry.register(
      :class => LCDB::PingLCDBServicesResponse,
      :schema_type => XSD::QName.new(NsLcd, "pingLCDBServicesResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetPastDuePayments,
      :schema_type => XSD::QName.new(NsLcd, "getPastDuePayments"),
      :schema_element => [
        ["arg0", ["LCDB::GetPastDueRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetPastDueRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getPastDueRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetPastDuePaymentsResponse,
      :schema_type => XSD::QName.new(NsLcd, "getPastDuePaymentsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetPastDueResponse", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::CheckTrial,
      :schema_type => XSD::QName.new(NsLcd, "checkTrial"),
      :schema_element => [
        ["arg0", ["LCDB::GetCheckTrialRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetCheckTrialRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getCheckTrialRequestType"),
      :schema_element => [
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::CheckTrialResponse,
      :schema_type => XSD::QName.new(NsLcd, "checkTrialResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetCheckTrialResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetCheckTrialResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getCheckTrialResponseType"),
      :schema_element => [
        ["eligibleFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "eligibleFlag")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdateLicense,
      :schema_type => XSD::QName.new(NsLcd, "updateLicense"),
      :schema_element => [
        ["arg0", ["LCDB::License", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::UpdateLicenseResponse,
      :schema_type => XSD::QName.new(NsLcd, "updateLicenseResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetPrGuid,
      :schema_type => XSD::QName.new(NsLcd, "setPrGuid"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["prGUID", ["LCDB::PrguidType", XSD::QName.new(nil, "prGUID")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    EncodedRegistry.register(
      :class => LCDB::SetPrGuidResponse,
      :schema_type => XSD::QName.new(NsLcd, "setPrGuidResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SwitchAccount,
      :schema_type => XSD::QName.new(NsLcd, "switchAccount"),
      :schema_element => [
        ["arg0", ["LCDB::SwitchAccountRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SwitchAccountRequestType,
      :schema_type => XSD::QName.new(NsLcd, "switchAccountRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["orgId", ["SOAP::SOAPString", XSD::QName.new(nil, "orgId")], [0, 1]],
        ["customerId", ["SOAP::SOAPDecimal", XSD::QName.new(nil, "customerId")]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")]],
        ["billTo", ["LCDB::CustomerDetails", XSD::QName.new(nil, "billTo")]],
        ["shipTo", ["LCDB::CustomerDetails", XSD::QName.new(nil, "shipTo")]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SwitchAccountResponse,
      :schema_type => XSD::QName.new(NsLcd, "switchAccountResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetMarketValue,
      :schema_type => XSD::QName.new(NsLcd, "getMarketValue"),
      :schema_element => [
        ["activationId", ["SOAP::SOAPString[]", XSD::QName.new(nil, "activationId")], [0, nil]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetMarketValueResponse,
      :schema_type => XSD::QName.new(NsLcd, "getMarketValueResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetMarketValueResponseType[]", XSD::QName.new(nil, "return")], [0, nil]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::GetMarketValueResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getMarketValueResponseType"),
      :schema_element => [
        ["purchaseDate", ["SOAP::SOAPString", XSD::QName.new(nil, "purchaseDate")], [0, 1]],
        ["activationId", ["SOAP::SOAPString", XSD::QName.new(nil, "activationId")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")], [0, 1]],
        ["orgId", ["SOAP::SOAPString", XSD::QName.new(nil, "orgId")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetProductRights,
      :schema_type => XSD::QName.new(NsLcd, "setProductRights"),
      :schema_element => [
        ["activationId", ["SOAP::SOAPString[]", XSD::QName.new(nil, "activationId")], [0, nil]],
        ["productRights", ["LCDB::PrDetails[]", XSD::QName.new(nil, "productRights")], [0, nil]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::PrDetails,
      :schema_type => XSD::QName.new(NsLcd, "prDetails"),
      :schema_element => [
        ["family", ["SOAP::SOAPString", XSD::QName.new(nil, "family")], [0, 1]],
        ["extRefId", ["SOAP::SOAPString", XSD::QName.new(nil, "extRefId")], [0, 1]],
        ["productRight", ["SOAP::SOAPString", XSD::QName.new(nil, "productRight")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SetProductRightsResponse,
      :schema_type => XSD::QName.new(NsLcd, "setProductRightsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SwitchLanguage,
      :schema_type => XSD::QName.new(NsLcd, "switchLanguage"),
      :schema_element => [
        ["productRight", ["SOAP::SOAPString", XSD::QName.new(nil, "productRight")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::SwitchLanguageResponse,
      :schema_type => XSD::QName.new(NsLcd, "switchLanguageResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::ValidateProductRights,
      :schema_type => XSD::QName.new(NsLcd, "validateProductRights"),
      :schema_element => [
        ["emailAddress", ["SOAP::SOAPString", XSD::QName.new(nil, "emailAddress")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::ValidateProductRightsResponse,
      :schema_type => XSD::QName.new(NsLcd, "validateProductRightsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::ProductRightResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::ProductRightResponseType,
      :schema_type => XSD::QName.new(NsLcd, "productRightResponseType"),
      :schema_element => [
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]],
        ["prGuid", ["SOAP::SOAPString[]", XSD::QName.new(nil, "prGuid")], [0, nil]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::CreateBillingProfile,
      :schema_type => XSD::QName.new(NsLcd, "createBillingProfile"),
      :schema_element => [
        ["customer", ["LCDB::Customer", XSD::QName.new(nil, "customer")], [0, 1]],
        ["paymentDetails", ["LCDB::PaymentDetails", XSD::QName.new(nil, "paymentDetails")], [0, 1]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::PaymentDetails,
      :schema_type => XSD::QName.new(NsLcd, "paymentDetails"),
      :schema_element => [
        ["creditCardNum", ["SOAP::SOAPString", XSD::QName.new(nil, "creditCardNum")], [0, 1]],
        ["expirationDate", ["SOAP::SOAPString", XSD::QName.new(nil, "expirationDate")], [0, 1]],
        ["cardHolderName", ["SOAP::SOAPString", XSD::QName.new(nil, "cardHolderName")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")]]
    ]
    )

    EncodedRegistry.register(
      :class => LCDB::CreateBillingProfileResponse,
      :schema_type => XSD::QName.new(NsLcd, "createBillingProfileResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetOrder,
      :schema_type => XSD::QName.new(NsLcd, "getOrder"),
      :schema_element => [
        ["arg0", ["LCDB::GetOrderDetailsRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetOrderDetailsRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getOrderDetailsRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["pastDueOnly", ["SOAP::SOAPString", XSD::QName.new(nil, "pastDueOnly")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetOrderResponse,
      :schema_type => XSD::QName.new(NsLcd, "getOrderResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetOrderDetailsResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetOrderDetailsResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getOrderDetailsResponseType"),
      :schema_element => [
        ["order", ["LCDB::Order[]", XSD::QName.new(nil, "order")], [0, nil]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::Order,
      :schema_type => XSD::QName.new(NsLcd, "order"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")]],
        ["order_number", ["SOAP::SOAPString", XSD::QName.new(nil, "order_number")]],
        ["customer_number", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_number")], [0, 1]],
        ["ordered_date", ["SOAP::SOAPString", XSD::QName.new(nil, "ordered_date")]],
        ["orig_sys_document_ref", ["SOAP::SOAPString", XSD::QName.new(nil, "orig_sys_document_ref")], [0, 1]],
        ["sales_channel", ["SOAP::SOAPString", XSD::QName.new(nil, "sales_channel")], [0, 1]],
        ["order_total", ["SOAP::SOAPDouble", XSD::QName.new(nil, "order_total")], [0, 1]],
        ["captureStatus", ["SOAP::SOAPString", XSD::QName.new(nil, "captureStatus")], [0, 1]],
        ["payment_type", ["SOAP::SOAPString", XSD::QName.new(nil, "payment_type")], [0, 1]],
        ["cancel_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "cancel_flag")], [0, 1]],
        ["org", ["SOAP::SOAPString", XSD::QName.new(nil, "org")]],
        ["orderItems", ["LCDB::OrderItems[]", XSD::QName.new(nil, "orderItems")], [0, nil]],
        ["past_due_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "past_due_flag")], [0, 1]],
        ["due_date", ["SOAP::SOAPString", XSD::QName.new(nil, "due_date")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::OrderItems,
      :schema_type => XSD::QName.new(NsLcd, "orderItems"),
      :schema_element => [
        ["order_line_id", ["SOAP::SOAPInt", XSD::QName.new(nil, "order_line_id")]],
        ["item", ["SOAP::SOAPString", XSD::QName.new(nil, "item")]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")]],
        ["line_status", ["SOAP::SOAPString", XSD::QName.new(nil, "line_status")], [0, 1]],
        ["pr_guid", ["SOAP::SOAPString", XSD::QName.new(nil, "pr_guid")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetOrder,
      :schema_type => XSD::QName.new(NsLcd, "setOrder"),
      :schema_element => [
        ["arg0", ["LCDB::Order", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetOrderResponse,
      :schema_type => XSD::QName.new(NsLcd, "setOrderResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GenericResponseType,
      :schema_type => XSD::QName.new(NsLcd, "genericResponseType"),
      :schema_element => [
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerDetails,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerDetails"),
      :schema_element => [
        ["arg0", ["LCDB::Customer", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::Customer,
      :schema_type => XSD::QName.new(NsLcd, "customer"),
      :schema_element => [
        ["customer_number", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_number")], [0, 1]],
        ["customer_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_flag")]],
        ["learner_flag", ["SOAP::SOAPString", XSD::QName.new(nil, "learner_flag")]],
        ["masterGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "masterGuid")]],
        ["sold_to_org_id", ["SOAP::SOAPString", XSD::QName.new(nil, "sold_to_org_id")], [0, 1]],
        ["org_id", ["SOAP::SOAPString", XSD::QName.new(nil, "org_id")], [0, 1]],
        ["first_name", ["SOAP::SOAPString", XSD::QName.new(nil, "first_name")]],
        ["last_name", ["SOAP::SOAPString", XSD::QName.new(nil, "last_name")]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")]],
        ["orig_sys_document_ref", ["SOAP::SOAPString", XSD::QName.new(nil, "orig_sys_document_ref")], [0, 1]],
        ["customerDetails", ["LCDB::CustomerDetails[]", XSD::QName.new(nil, "customerDetails")], [0, nil]],
        ["license", ["LCDB::License[]", XSD::QName.new(nil, "license")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CustomerDetails,
      :schema_type => XSD::QName.new(NsLcd, "customerDetails"),
      :schema_element => [
        ["site_use_id", ["SOAP::SOAPString", XSD::QName.new(nil, "site_use_id")], [0, 1]],
        ["site_type", ["SOAP::SOAPString", XSD::QName.new(nil, "site_type")]],
        ["first_name", ["SOAP::SOAPString", XSD::QName.new(nil, "first_name")]],
        ["last_name", ["SOAP::SOAPString", XSD::QName.new(nil, "last_name")]],
        ["phonetic_first_name", ["SOAP::SOAPString", XSD::QName.new(nil, "phonetic_first_name")]],
        ["phonetic_last_name", ["SOAP::SOAPString", XSD::QName.new(nil, "phonetic_last_name")]],
        ["address1", ["SOAP::SOAPString", XSD::QName.new(nil, "address1")]],
        ["address2", ["SOAP::SOAPString", XSD::QName.new(nil, "address2")], [0, 1]],
        ["city", ["SOAP::SOAPString", XSD::QName.new(nil, "city")], [0, 1]],
        ["country", ["SOAP::SOAPString", XSD::QName.new(nil, "country")], [0, 1]],
        ["state_province", ["SOAP::SOAPString", XSD::QName.new(nil, "state_province")]],
        ["zip", ["SOAP::SOAPString", XSD::QName.new(nil, "zip")]],
        ["phone", ["SOAP::SOAPString", XSD::QName.new(nil, "phone")], [0, 1]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")]],
        ["credit_card_id", ["SOAP::SOAPString", XSD::QName.new(nil, "credit_card_id")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::License,
      :schema_type => XSD::QName.new(NsLcd, "license"),
      :schema_element => [
        ["licenseGUID", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGUID")], [0, 1]],
        ["masterFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "masterFlag")], [0, 1]],
        ["suspendStatus", ["SOAP::SOAPString", XSD::QName.new(nil, "suspendStatus")], [0, 1]],
        ["suspendReason", ["SOAP::SOAPString", XSD::QName.new(nil, "suspendReason")], [0, 1]],
        ["rsPan", ["SOAP::SOAPString", XSD::QName.new(nil, "rsPan")], [0, 1]],
        ["apiKey", ["SOAP::SOAPString", XSD::QName.new(nil, "apiKey")], [0, 1]],
        ["licenseDetails", ["LCDB::LicenseDetails[]", XSD::QName.new(nil, "licenseDetails")], [0, nil]],
        ["licenseType", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseType")], [0, 1]],
        ["serverURL", ["SOAP::SOAPString", XSD::QName.new(nil, "serverURL")], [0, 1]],
        ["serverCountry", ["SOAP::SOAPString", XSD::QName.new(nil, "serverCountry")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::LicenseDetails,
      :schema_type => XSD::QName.new(NsLcd, "licenseDetails"),
      :schema_element => [
        ["prGUIDRec", ["LCDB::PrguidType", XSD::QName.new(nil, "prGUIDRec")]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")]],
        ["autoRenewalFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "autoRenewalFlag")]],
        ["renewalPrice", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalPrice")], [0, 1]],
        ["renewalTerm", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalTerm")], [0, 1]],
        ["bankAcctusesId", ["SOAP::SOAPInt", XSD::QName.new(nil, "bankAcctusesId")], [0, 1]],
        ["processingId", ["SOAP::SOAPString", XSD::QName.new(nil, "processingId")], [0, 1]],
        ["vendor", ["SOAP::SOAPString", XSD::QName.new(nil, "vendor")], [0, 1]],
        ["item", ["SOAP::SOAPString", XSD::QName.new(nil, "item")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")], [0, 1]],
        ["trialFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "trialFlag")], [0, 1]],
        ["trialStartDate", ["SOAP::SOAPString", XSD::QName.new(nil, "trialStartDate")], [0, 1]],
        ["trialEndDate", ["SOAP::SOAPString", XSD::QName.new(nil, "trialEndDate")], [0, 1]],
        ["source", ["SOAP::SOAPString", XSD::QName.new(nil, "source")], [0, 1]],
        ["start_date", ["SOAP::SOAPString", XSD::QName.new(nil, "start_date")], [0, 1]],
        ["end_date", ["SOAP::SOAPString", XSD::QName.new(nil, "end_date")], [0, 1]],
        ["subscriptionID", ["SOAP::SOAPString", XSD::QName.new(nil, "subscriptionID")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    LiteralRegistry.register(
      :class => LCDB::PrguidType,
      :schema_type => XSD::QName.new(NsLcd, "prguidType"),
      :schema_element => [
        ["prGUID", ["SOAP::SOAPString[]", XSD::QName.new(nil, "prGUID")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerDetailsResponse,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerNumber,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerNumber"),
      :schema_element => [
        ["arg0", ["LCDB::SetCustNumberRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustNumberRequestType,
      :schema_type => XSD::QName.new(NsLcd, "setCustNumberRequestType"),
      :schema_element => [
        ["bill_to_site_use_id", ["SOAP::SOAPString", XSD::QName.new(nil, "bill_to_site_use_id")], [0, 1]],
        ["customer_number", ["SOAP::SOAPString", XSD::QName.new(nil, "customer_number")], [0, 1]],
        ["orig_sys_document_ref", ["SOAP::SOAPString", XSD::QName.new(nil, "orig_sys_document_ref")], [0, 1]],
        ["ship_to_site_use_id", ["SOAP::SOAPString", XSD::QName.new(nil, "ship_to_site_use_id")], [0, 1]],
        ["sold_to_org_id", ["SOAP::SOAPString", XSD::QName.new(nil, "sold_to_org_id")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerNumberResponse,
      :schema_type => XSD::QName.new(NsLcd, "setCustomerNumberResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdatePersonDetails,
      :schema_type => XSD::QName.new(NsLcd, "updatePersonDetails"),
      :schema_element => [
        ["arg0", ["LCDB::UpdatePersonDetailRequest", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdatePersonDetailRequest,
      :schema_type => XSD::QName.new(NsLcd, "updatePersonDetailRequest"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["personDetails", ["LCDB::CustomerDetails", XSD::QName.new(nil, "personDetails")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdatePersonDetailsResponse,
      :schema_type => XSD::QName.new(NsLcd, "updatePersonDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCustomerDetails,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetails"),
      :schema_element => [
        ["arg0", ["LCDB::GetCustomerDetailsRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCustomerDetailsRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetailsRequestType"),
      :schema_element => [
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")], [0, 1]],
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCustomerDetailsResponse,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetCustomerDetailsResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCustomerDetailsResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getCustomerDetailsResponseType"),
      :schema_element => [
        ["customer", ["LCDB::Customer", XSD::QName.new(nil, "customer")], [0, 1]],
        ["pastDueResponse", ["LCDB::GetPastDueResponse", XSD::QName.new(nil, "pastDueResponse")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetPastDueResponse,
      :schema_type => XSD::QName.new(NsLcd, "getPastDueResponse"),
      :schema_element => [
        ["pastDue", ["LCDB::PastDuePaymentType[]", XSD::QName.new(nil, "pastDue")], [0, nil]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::PastDuePaymentType,
      :schema_type => XSD::QName.new(NsLcd, "pastDuePaymentType"),
      :schema_element => [
        ["missedPayments", ["SOAP::SOAPInt", XSD::QName.new(nil, "missedPayments")], [0, 1]],
        ["amountDue", ["SOAP::SOAPDouble", XSD::QName.new(nil, "amountDue")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["orderNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "orderNumber")], [0, 1]],
        ["paymentType", ["SOAP::SOAPString", XSD::QName.new(nil, "paymentType")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateOrderPayStatus,
      :schema_type => XSD::QName.new(NsLcd, "updateOrderPayStatus"),
      :schema_element => [
        ["arg0", ["LCDB::Order", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateOrderPayStatusResponse,
      :schema_type => XSD::QName.new(NsLcd, "updateOrderPayStatusResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetRenewal,
      :schema_type => XSD::QName.new(NsLcd, "getRenewal"),
      :schema_element => [
        ["arg0", ["LCDB::GetRenewalRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetRenewalRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getRenewalRequestType"),
      :schema_element => [
        ["licenseGUID", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGUID")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "Language")], [0, 1]],
        ["pr_guid", ["SOAP::SOAPString", XSD::QName.new(nil, "pr_guid")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    LiteralRegistry.register(
      :class => LCDB::GetRenewalResponse,
      :schema_type => XSD::QName.new(NsLcd, "getRenewalResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetRenewalResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetRenewalResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getRenewalResponseType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["licenseDetails", ["LCDB::LicenseDetails[]", XSD::QName.new(nil, "licenseDetails")], [0, nil]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    LiteralRegistry.register(
      :class => LCDB::SetRenewal,
      :schema_type => XSD::QName.new(NsLcd, "setRenewal"),
      :schema_element => [
        ["arg0", ["LCDB::SetRenewalRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetRenewalRequestType,
      :schema_type => XSD::QName.new(NsLcd, "setRenewalRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["prGUID", ["SOAP::SOAPString", XSD::QName.new(nil, "prGUID")], [0, 1]],
        ["source", ["SOAP::SOAPString", XSD::QName.new(nil, "source")], [0, 1]],
        ["autoRenewalFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "autoRenewalFlag")]],
        ["renewalPrice", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalPrice")], [0, 1]],
        ["renewalTerm", ["SOAP::SOAPString", XSD::QName.new(nil, "renewalTerm")], [0, 1]],
        ["bankAcctUsesId", ["SOAP::SOAPInt", XSD::QName.new(nil, "bankAcctUsesId")], [0, 1]],
        ["rsPan", ["SOAP::SOAPString", XSD::QName.new(nil, "rsPan")], [0, 1]],
        ["processingId", ["SOAP::SOAPString", XSD::QName.new(nil, "processingId")], [0, 1]],
        ["vendor", ["SOAP::SOAPString", XSD::QName.new(nil, "vendor")], [0, 1]],
        ["item", ["SOAP::SOAPString", XSD::QName.new(nil, "item")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    LiteralRegistry.register(
      :class => LCDB::SetRenewalResponse,
      :schema_type => XSD::QName.new(NsLcd, "setRenewalResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::PingLCDBServices,
      :schema_type => XSD::QName.new(NsLcd, "pingLCDBServices"),
      :schema_element => []
    )

    LiteralRegistry.register(
      :class => LCDB::PingLCDBServicesResponse,
      :schema_type => XSD::QName.new(NsLcd, "pingLCDBServicesResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetPastDuePayments,
      :schema_type => XSD::QName.new(NsLcd, "getPastDuePayments"),
      :schema_element => [
        ["arg0", ["LCDB::GetPastDueRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetPastDueRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getPastDueRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetPastDuePaymentsResponse,
      :schema_type => XSD::QName.new(NsLcd, "getPastDuePaymentsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetPastDueResponse", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CheckTrial,
      :schema_type => XSD::QName.new(NsLcd, "checkTrial"),
      :schema_element => [
        ["arg0", ["LCDB::GetCheckTrialRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCheckTrialRequestType,
      :schema_type => XSD::QName.new(NsLcd, "getCheckTrialRequestType"),
      :schema_element => [
        ["email", ["SOAP::SOAPString", XSD::QName.new(nil, "email")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CheckTrialResponse,
      :schema_type => XSD::QName.new(NsLcd, "checkTrialResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetCheckTrialResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCheckTrialResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getCheckTrialResponseType"),
      :schema_element => [
        ["eligibleFlag", ["SOAP::SOAPString", XSD::QName.new(nil, "eligibleFlag")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateLicense,
      :schema_type => XSD::QName.new(NsLcd, "updateLicense"),
      :schema_element => [
        ["arg0", ["LCDB::License", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateLicenseResponse,
      :schema_type => XSD::QName.new(NsLcd, "updateLicenseResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetPrGuid,
      :schema_type => XSD::QName.new(NsLcd, "setPrGuid"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["prGUID", ["LCDB::PrguidType", XSD::QName.new(nil, "prGUID")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    LiteralRegistry.register(
      :class => LCDB::SetPrGuidResponse,
      :schema_type => XSD::QName.new(NsLcd, "setPrGuidResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchAccount,
      :schema_type => XSD::QName.new(NsLcd, "switchAccount"),
      :schema_element => [
        ["arg0", ["LCDB::SwitchAccountRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchAccountRequestType,
      :schema_type => XSD::QName.new(NsLcd, "switchAccountRequestType"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["orgId", ["SOAP::SOAPString", XSD::QName.new(nil, "orgId")], [0, 1]],
        ["customerId", ["SOAP::SOAPDecimal", XSD::QName.new(nil, "customerId")]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")]],
        ["billTo", ["LCDB::CustomerDetails", XSD::QName.new(nil, "billTo")]],
        ["shipTo", ["LCDB::CustomerDetails", XSD::QName.new(nil, "shipTo")]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchAccountResponse,
      :schema_type => XSD::QName.new(NsLcd, "switchAccountResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetMarketValue,
      :schema_type => XSD::QName.new(NsLcd, "getMarketValue"),
      :schema_element => [
        ["activationId", ["SOAP::SOAPString[]", XSD::QName.new(nil, "activationId")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetMarketValueResponse,
      :schema_type => XSD::QName.new(NsLcd, "getMarketValueResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetMarketValueResponseType[]", XSD::QName.new(nil, "return")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetMarketValueResponseType,
      :schema_type => XSD::QName.new(NsLcd, "getMarketValueResponseType"),
      :schema_element => [
        ["purchaseDate", ["SOAP::SOAPString", XSD::QName.new(nil, "purchaseDate")], [0, 1]],
        ["activationId", ["SOAP::SOAPString", XSD::QName.new(nil, "activationId")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")], [0, 1]],
        ["orgId", ["SOAP::SOAPString", XSD::QName.new(nil, "orgId")], [0, 1]],
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetProductRights,
      :schema_type => XSD::QName.new(NsLcd, "setProductRights"),
      :schema_element => [
        ["activationId", ["SOAP::SOAPString[]", XSD::QName.new(nil, "activationId")], [0, nil]],
        ["productRights", ["LCDB::PrDetails[]", XSD::QName.new(nil, "productRights")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::PrDetails,
      :schema_type => XSD::QName.new(NsLcd, "prDetails"),
      :schema_element => [
        ["family", ["SOAP::SOAPString", XSD::QName.new(nil, "family")], [0, 1]],
        ["extRefId", ["SOAP::SOAPString", XSD::QName.new(nil, "extRefId")], [0, 1]],
        ["productRight", ["SOAP::SOAPString", XSD::QName.new(nil, "productRight")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetProductRightsResponse,
      :schema_type => XSD::QName.new(NsLcd, "setProductRightsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchLanguage,
      :schema_type => XSD::QName.new(NsLcd, "switchLanguage"),
      :schema_element => [
        ["productRight", ["SOAP::SOAPString", XSD::QName.new(nil, "productRight")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchLanguageResponse,
      :schema_type => XSD::QName.new(NsLcd, "switchLanguageResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::ValidateProductRights,
      :schema_type => XSD::QName.new(NsLcd, "validateProductRights"),
      :schema_element => [
        ["emailAddress", ["SOAP::SOAPString", XSD::QName.new(nil, "emailAddress")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::ValidateProductRightsResponse,
      :schema_type => XSD::QName.new(NsLcd, "validateProductRightsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::ProductRightResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::ProductRightResponseType,
      :schema_type => XSD::QName.new(NsLcd, "productRightResponseType"),
      :schema_element => [
        ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
        ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]],
        ["prGuid", ["SOAP::SOAPString[]", XSD::QName.new(nil, "prGuid")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CreateBillingProfile,
      :schema_type => XSD::QName.new(NsLcd, "createBillingProfile"),
      :schema_element => [
        ["customer", ["LCDB::Customer", XSD::QName.new(nil, "customer")], [0, 1]],
        ["paymentDetails", ["LCDB::PaymentDetails", XSD::QName.new(nil, "paymentDetails")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::PaymentDetails,
      :schema_type => XSD::QName.new(NsLcd, "paymentDetails"),
      :schema_element => [
        ["creditCardNum", ["SOAP::SOAPString", XSD::QName.new(nil, "creditCardNum")], [0, 1]],
        ["expirationDate", ["SOAP::SOAPString", XSD::QName.new(nil, "expirationDate")], [0, 1]],
        ["cardHolderName", ["SOAP::SOAPString", XSD::QName.new(nil, "cardHolderName")], [0, 1]],
        ["currency", ["SOAP::SOAPString", XSD::QName.new(nil, "currency")]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CreateBillingProfileResponse,
      :schema_type => XSD::QName.new(NsLcd, "createBillingProfileResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CheckTrial,
      :schema_name => XSD::QName.new(NsLcd, "checkTrial"),
      :schema_element => [
        ["arg0", ["LCDB::GetCheckTrialRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CheckTrialResponse,
      :schema_name => XSD::QName.new(NsLcd, "checkTrialResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetCheckTrialResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CreateBillingProfile,
      :schema_name => XSD::QName.new(NsLcd, "createBillingProfile"),
      :schema_element => [
        ["customer", ["LCDB::Customer", XSD::QName.new(nil, "customer")], [0, 1]],
        ["paymentDetails", ["LCDB::PaymentDetails", XSD::QName.new(nil, "paymentDetails")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::CreateBillingProfileResponse,
      :schema_name => XSD::QName.new(NsLcd, "createBillingProfileResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCustomerDetails,
      :schema_name => XSD::QName.new(NsLcd, "getCustomerDetails"),
      :schema_element => [
        ["arg0", ["LCDB::GetCustomerDetailsRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetCustomerDetailsResponse,
      :schema_name => XSD::QName.new(NsLcd, "getCustomerDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetCustomerDetailsResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetMarketValue,
      :schema_name => XSD::QName.new(NsLcd, "getMarketValue"),
      :schema_element => [
        ["activationId", ["SOAP::SOAPString[]", XSD::QName.new(nil, "activationId")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetMarketValueResponse,
      :schema_name => XSD::QName.new(NsLcd, "getMarketValueResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetMarketValueResponseType[]", XSD::QName.new(nil, "return")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetOrder,
      :schema_name => XSD::QName.new(NsLcd, "getOrder"),
      :schema_element => [
        ["arg0", ["LCDB::GetOrderDetailsRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetOrderResponse,
      :schema_name => XSD::QName.new(NsLcd, "getOrderResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetOrderDetailsResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetPastDuePayments,
      :schema_name => XSD::QName.new(NsLcd, "getPastDuePayments"),
      :schema_element => [
        ["arg0", ["LCDB::GetPastDueRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetPastDuePaymentsResponse,
      :schema_name => XSD::QName.new(NsLcd, "getPastDuePaymentsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetPastDueResponse", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetRenewal,
      :schema_name => XSD::QName.new(NsLcd, "getRenewal"),
      :schema_element => [
        ["arg0", ["LCDB::GetRenewalRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::GetRenewalResponse,
      :schema_name => XSD::QName.new(NsLcd, "getRenewalResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GetRenewalResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::PingLCDBServices,
      :schema_name => XSD::QName.new(NsLcd, "pingLCDBServices"),
      :schema_element => []
    )

    LiteralRegistry.register(
      :class => LCDB::PingLCDBServicesResponse,
      :schema_name => XSD::QName.new(NsLcd, "pingLCDBServicesResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerDetails,
      :schema_name => XSD::QName.new(NsLcd, "setCustomerDetails"),
      :schema_element => [
        ["arg0", ["LCDB::Customer", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerDetailsResponse,
      :schema_name => XSD::QName.new(NsLcd, "setCustomerDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerNumber,
      :schema_name => XSD::QName.new(NsLcd, "setCustomerNumber"),
      :schema_element => [
        ["arg0", ["LCDB::SetCustNumberRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetCustomerNumberResponse,
      :schema_name => XSD::QName.new(NsLcd, "setCustomerNumberResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetOrder,
      :schema_name => XSD::QName.new(NsLcd, "setOrder"),
      :schema_element => [
        ["arg0", ["LCDB::Order", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetOrderResponse,
      :schema_name => XSD::QName.new(NsLcd, "setOrderResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetPrGuid,
      :schema_name => XSD::QName.new(NsLcd, "setPrGuid"),
      :schema_element => [
        ["licenseGuid", ["SOAP::SOAPString", XSD::QName.new(nil, "licenseGuid")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]],
        ["prGUID", ["LCDB::PrguidType", XSD::QName.new(nil, "prGUID")], [0, 1]]
    ],
      :schema_attribute => {
      XSD::QName.new(nil, "groupId") => "SOAP::SOAPInt"
    }
    )

    LiteralRegistry.register(
      :class => LCDB::SetPrGuidResponse,
      :schema_name => XSD::QName.new(NsLcd, "setPrGuidResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetProductRights,
      :schema_name => XSD::QName.new(NsLcd, "setProductRights"),
      :schema_element => [
        ["activationId", ["SOAP::SOAPString[]", XSD::QName.new(nil, "activationId")], [0, nil]],
        ["productRights", ["LCDB::PrDetails[]", XSD::QName.new(nil, "productRights")], [0, nil]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetProductRightsResponse,
      :schema_name => XSD::QName.new(NsLcd, "setProductRightsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetRenewal,
      :schema_name => XSD::QName.new(NsLcd, "setRenewal"),
      :schema_element => [
        ["arg0", ["LCDB::SetRenewalRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SetRenewalResponse,
      :schema_name => XSD::QName.new(NsLcd, "setRenewalResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchAccount,
      :schema_name => XSD::QName.new(NsLcd, "switchAccount"),
      :schema_element => [
        ["arg0", ["LCDB::SwitchAccountRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchAccountResponse,
      :schema_name => XSD::QName.new(NsLcd, "switchAccountResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchLanguage,
      :schema_name => XSD::QName.new(NsLcd, "switchLanguage"),
      :schema_element => [
        ["productRight", ["SOAP::SOAPString", XSD::QName.new(nil, "productRight")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::SwitchLanguageResponse,
      :schema_name => XSD::QName.new(NsLcd, "switchLanguageResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateLicense,
      :schema_name => XSD::QName.new(NsLcd, "updateLicense"),
      :schema_element => [
        ["arg0", ["LCDB::License", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateLicenseResponse,
      :schema_name => XSD::QName.new(NsLcd, "updateLicenseResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateOrderPayStatus,
      :schema_name => XSD::QName.new(NsLcd, "updateOrderPayStatus"),
      :schema_element => [
        ["arg0", ["LCDB::Order", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdateOrderPayStatusResponse,
      :schema_name => XSD::QName.new(NsLcd, "updateOrderPayStatusResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdatePersonDetails,
      :schema_name => XSD::QName.new(NsLcd, "updatePersonDetails"),
      :schema_element => [
        ["arg0", ["LCDB::UpdatePersonDetailRequest", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::UpdatePersonDetailsResponse,
      :schema_name => XSD::QName.new(NsLcd, "updatePersonDetailsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::GenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::ValidateProductRights,
      :schema_name => XSD::QName.new(NsLcd, "validateProductRights"),
      :schema_element => [
        ["emailAddress", ["SOAP::SOAPString", XSD::QName.new(nil, "emailAddress")], [0, 1]],
        ["language", ["SOAP::SOAPString", XSD::QName.new(nil, "language")], [0, 1]]
    ]
    )

    LiteralRegistry.register(
      :class => LCDB::ValidateProductRightsResponse,
      :schema_name => XSD::QName.new(NsLcd, "validateProductRightsResponse"),
      :schema_element => [
        ["v_return", ["LCDB::ProductRightResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
    )
  end

end

