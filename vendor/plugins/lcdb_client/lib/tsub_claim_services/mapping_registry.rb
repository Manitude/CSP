require 'claim_services/service_classes.rb'
require 'soap/mapping'

module LCDB

module ClaimServicesMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsClaimservices = "http://claimservices/"

  EncodedRegistry.register(
    :class => LCDB::TsubGetAssociatedFeatures,
    :schema_type => XSD::QName.new(NsClaimservices, "getAssociatedFeatures"),
    :schema_element => [
      ["arg0", ["LCDB::TsubGetFeaturesRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubGetFeaturesRequestType,
    :schema_type => XSD::QName.new(NsClaimservices, "getFeaturesRequestType"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubGetAssociatedFeaturesResponse,
    :schema_type => XSD::QName.new(NsClaimservices, "getAssociatedFeaturesResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubGetFeaturesResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubGetFeaturesResponseType,
    :schema_type => XSD::QName.new(NsClaimservices, "getFeaturesResponseType"),
    :schema_element => [
      ["feature", ["LCDB::TsubFeatureType[]", XSD::QName.new(nil, "feature")], [0, nil]],
      ["availableTokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "availableTokenValue")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubFeatureType,
    :schema_type => XSD::QName.new(NsClaimservices, "featureType"),
    :schema_element => [
      ["featureCode", ["SOAP::SOAPString", XSD::QName.new(nil, "featureCode")], [0, 1]],
      ["featureName", ["SOAP::SOAPString", XSD::QName.new(nil, "featureName")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubCheckOutTokens,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokens"),
    :schema_element => [
      ["arg0", ["LCDB::TsubCheckOutTokensRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubCheckOutTokensRequestType,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokensRequestType"),
    :schema_element => [
      ["activation_id", ["SOAP::SOAPString", XSD::QName.new(nil, "activation_id")]],
      ["tokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "tokenValue")]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubCheckOutTokensResponse,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokensResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubCheckOutTokensResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubCheckOutTokensResponseType,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokensResponseType"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubPingLCDBServices,
    :schema_type => XSD::QName.new(NsClaimservices, "pingLCDBServices"),
    :schema_element => []
  )

  EncodedRegistry.register(
    :class => LCDB::TsubPingLCDBServicesResponse,
    :schema_type => XSD::QName.new(NsClaimservices, "pingLCDBServicesResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubGenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::TsubGenericResponseType,
    :schema_type => XSD::QName.new(NsClaimservices, "genericResponseType"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGetAssociatedFeatures,
    :schema_type => XSD::QName.new(NsClaimservices, "getAssociatedFeatures"),
    :schema_element => [
      ["arg0", ["LCDB::TsubGetFeaturesRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGetFeaturesRequestType,
    :schema_type => XSD::QName.new(NsClaimservices, "getFeaturesRequestType"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGetAssociatedFeaturesResponse,
    :schema_type => XSD::QName.new(NsClaimservices, "getAssociatedFeaturesResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubGetFeaturesResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGetFeaturesResponseType,
    :schema_type => XSD::QName.new(NsClaimservices, "getFeaturesResponseType"),
    :schema_element => [
      ["feature", ["LCDB::TsubFeatureType[]", XSD::QName.new(nil, "feature")], [0, nil]],
      ["availableTokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "availableTokenValue")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubFeatureType,
    :schema_type => XSD::QName.new(NsClaimservices, "featureType"),
    :schema_element => [
      ["featureCode", ["SOAP::SOAPString", XSD::QName.new(nil, "featureCode")], [0, 1]],
      ["featureName", ["SOAP::SOAPString", XSD::QName.new(nil, "featureName")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubCheckOutTokens,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokens"),
    :schema_element => [
      ["arg0", ["LCDB::TsubCheckOutTokensRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubCheckOutTokensRequestType,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokensRequestType"),
    :schema_element => [
      ["activation_id", ["SOAP::SOAPString", XSD::QName.new(nil, "activation_id")]],
      ["tokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "tokenValue")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubCheckOutTokensResponse,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokensResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubCheckOutTokensResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubCheckOutTokensResponseType,
    :schema_type => XSD::QName.new(NsClaimservices, "checkOutTokensResponseType"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubPingLCDBServices,
    :schema_type => XSD::QName.new(NsClaimservices, "pingLCDBServices"),
    :schema_element => []
  )

  LiteralRegistry.register(
    :class => LCDB::TsubPingLCDBServicesResponse,
    :schema_type => XSD::QName.new(NsClaimservices, "pingLCDBServicesResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubGenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGenericResponseType,
    :schema_type => XSD::QName.new(NsClaimservices, "genericResponseType"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubCheckOutTokens,
    :schema_name => XSD::QName.new(NsClaimservices, "checkOutTokens"),
    :schema_element => [
      ["arg0", ["LCDB::TsubCheckOutTokensRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubCheckOutTokensResponse,
    :schema_name => XSD::QName.new(NsClaimservices, "checkOutTokensResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubCheckOutTokensResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGetAssociatedFeatures,
    :schema_name => XSD::QName.new(NsClaimservices, "getAssociatedFeatures"),
    :schema_element => [
      ["arg0", ["LCDB::TsubGetFeaturesRequestType", XSD::QName.new(nil, "arg0")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubGetAssociatedFeaturesResponse,
    :schema_name => XSD::QName.new(NsClaimservices, "getAssociatedFeaturesResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubGetFeaturesResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::TsubPingLCDBServices,
    :schema_name => XSD::QName.new(NsClaimservices, "pingLCDBServices"),
    :schema_element => []
  )

  LiteralRegistry.register(
    :class => LCDB::TsubPingLCDBServicesResponse,
    :schema_name => XSD::QName.new(NsClaimservices, "pingLCDBServicesResponse"),
    :schema_element => [
      ["v_return", ["LCDB::TsubGenericResponseType", XSD::QName.new(nil, "return")], [0, 1]]
    ]
  )
end

end
