require 'claim_services/service_classes.rb'
require 'soap/mapping'

module LCDB

module ClaimServicesImplServiceMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsClaim = "http://domain.rst1.com/services/business/claim"

  EncodedRegistry.register(
    :class => LCDB::CheckOutTokensRequest,
    :schema_type => XSD::QName.new(NsClaim, "checkOutTokensRequest"),
    :schema_element => [
      ["activation_id", ["SOAP::SOAPString", XSD::QName.new(nil, "activation_id")]],
      ["tokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "tokenValue")]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::CheckOutTokensResponse,
    :schema_type => XSD::QName.new(NsClaim, "checkOutTokensResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::GetAssociatedFeaturesRequest,
    :schema_type => XSD::QName.new(NsClaim, "getAssociatedFeaturesRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::GetAssociatedFeaturesResponse,
    :schema_type => XSD::QName.new(NsClaim, "getAssociatedFeaturesResponse"),
    :schema_element => [
      ["feature", ["LCDB::FeatureType[]", XSD::QName.new(nil, "feature")], [0, nil]],
      ["availableTokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "availableTokenValue")]],
      ["orgID", ["SOAP::SOAPInt", XSD::QName.new(nil, "orgID")]],
      ["individualConsumables", ["SOAP::SOAPInt", XSD::QName.new(nil, "individualConsumables")]],
      ["groupConsumables", ["SOAP::SOAPInt", XSD::QName.new(nil, "groupConsumables")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::FeatureType,
    :schema_type => XSD::QName.new(NsClaim, "featureType"),
    :schema_element => [
      ["featureCode", ["SOAP::SOAPString", XSD::QName.new(nil, "featureCode")], [0, 1]],
      ["featureName", ["SOAP::SOAPString", XSD::QName.new(nil, "featureName")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::PingLCDBServicesRequest,
    :schema_type => XSD::QName.new(NsClaim, "pingLCDBServicesRequest"),
    :schema_element => []
  )

  EncodedRegistry.register(
    :class => LCDB::PingLCDBServicesResponse,
    :schema_type => XSD::QName.new(NsClaim, "pingLCDBServicesResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::ValidateSerialNumberRequest,
    :schema_type => XSD::QName.new(NsClaim, "validateSerialNumberRequest"),
    :schema_element => [
      ["items", ["LCDB::Items[]", XSD::QName.new(nil, "items")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::Items,
    :schema_type => XSD::QName.new(NsClaim, "items"),
    :schema_element => [
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["productType", ["SOAP::SOAPString", XSD::QName.new(nil, "productType")], [0, 1]],
      ["productCode", ["SOAP::SOAPString", XSD::QName.new(nil, "productCode")], [0, 1]],
      ["productLevel", ["SOAP::SOAPString", XSD::QName.new(nil, "productLevel")], [0, 1]],
      ["months", ["SOAP::SOAPString", XSD::QName.new(nil, "months")], [0, 1]],
      ["edition", ["SOAP::SOAPString", XSD::QName.new(nil, "edition")], [0, 1]],
      ["brand", ["SOAP::SOAPString", XSD::QName.new(nil, "brand")], [0, 1]],
      ["localization", ["SOAP::SOAPString", XSD::QName.new(nil, "localization")], [0, 1]],
      ["productVersion", ["SOAP::SOAPString", XSD::QName.new(nil, "productVersion")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::ValidateSerialNumberResponse,
    :schema_type => XSD::QName.new(NsClaim, "validateSerialNumberResponse"),
    :schema_element => [
      ["serialNumber", ["LCDB::SerialResponse[]", XSD::QName.new(nil, "serialNumber")], [0, nil]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::SerialResponse,
    :schema_type => XSD::QName.new(NsClaim, "serialResponse"),
    :schema_element => [
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnString", ["SOAP::SOAPString", XSD::QName.new(nil, "returnString")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::UpdatePosaStatusRequest,
    :schema_type => XSD::QName.new(NsClaim, "updatePosaStatusRequest"),
    :schema_element => [
      ["serialNumber", ["LCDB::SerialType[]", XSD::QName.new(nil, "serialNumber")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::SerialType,
    :schema_type => XSD::QName.new(NsClaim, "serialType"),
    :schema_element => [
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::UpdatePosaStatusResponse,
    :schema_type => XSD::QName.new(NsClaim, "updatePosaStatusResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::ValidatePOSARequest,
    :schema_type => XSD::QName.new(NsClaim, "validatePOSARequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::ValidatePOSAResponse,
    :schema_type => XSD::QName.new(NsClaim, "validatePOSAResponse"),
    :schema_element => [
      ["status", ["SOAP::SOAPString", XSD::QName.new(nil, "status")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::GenerateActivationIDRequest,
    :schema_type => XSD::QName.new(NsClaim, "generateActivationIDRequest"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]],
      ["token", ["SOAP::SOAPString", XSD::QName.new(nil, "token")], [0, 1]],
      ["orderNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "orderNumber")], [0, 1]],
      ["orgID", ["SOAP::SOAPString", XSD::QName.new(nil, "orgID")], [0, 1]],
      ["groupConsumables", ["SOAP::SOAPString", XSD::QName.new(nil, "groupConsumables")], [0, 1]],
      ["individualConsumables", ["SOAP::SOAPString", XSD::QName.new(nil, "individualConsumables")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::GenerateActivationIDResponse,
    :schema_type => XSD::QName.new(NsClaim, "generateActivationIDResponse"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]],
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::SetDownloadTimeRequest,
    :schema_type => XSD::QName.new(NsClaim, "setDownloadTimeRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::SetDownloadTimeResponse,
    :schema_type => XSD::QName.new(NsClaim, "setDownloadTimeResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::DeactivateKeyRequest,
    :schema_type => XSD::QName.new(NsClaim, "deactivateKeyRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::DeactivateKeyResponse,
    :schema_type => XSD::QName.new(NsClaim, "deactivateKeyResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::GetFNOCatCodeRequest,
    :schema_type => XSD::QName.new(NsClaim, "getFNOCatCodeRequest"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => LCDB::GetFNOCatCodeResponse,
    :schema_type => XSD::QName.new(NsClaim, "getFNOCatCodeResponse"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::CheckOutTokensRequest,
    :schema_type => XSD::QName.new(NsClaim, "checkOutTokensRequest"),
    :schema_element => [
      ["activation_id", ["SOAP::SOAPString", XSD::QName.new(nil, "activation_id")]],
      ["tokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "tokenValue")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::CheckOutTokensResponse,
    :schema_type => XSD::QName.new(NsClaim, "checkOutTokensResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetAssociatedFeaturesRequest,
    :schema_type => XSD::QName.new(NsClaim, "getAssociatedFeaturesRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetAssociatedFeaturesResponse,
    :schema_type => XSD::QName.new(NsClaim, "getAssociatedFeaturesResponse"),
    :schema_element => [
      ["feature", ["LCDB::FeatureType[]", XSD::QName.new(nil, "feature")], [0, nil]],
      ["availableTokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "availableTokenValue")]],
      ["orgID", ["SOAP::SOAPInt", XSD::QName.new(nil, "orgID")]],
      ["individualConsumables", ["SOAP::SOAPInt", XSD::QName.new(nil, "individualConsumables")]],
      ["groupConsumables", ["SOAP::SOAPInt", XSD::QName.new(nil, "groupConsumables")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::FeatureType,
    :schema_type => XSD::QName.new(NsClaim, "featureType"),
    :schema_element => [
      ["featureCode", ["SOAP::SOAPString", XSD::QName.new(nil, "featureCode")], [0, 1]],
      ["featureName", ["SOAP::SOAPString", XSD::QName.new(nil, "featureName")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::PingLCDBServicesRequest,
    :schema_type => XSD::QName.new(NsClaim, "pingLCDBServicesRequest"),
    :schema_element => []
  )

  LiteralRegistry.register(
    :class => LCDB::PingLCDBServicesResponse,
    :schema_type => XSD::QName.new(NsClaim, "pingLCDBServicesResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidateSerialNumberRequest,
    :schema_type => XSD::QName.new(NsClaim, "validateSerialNumberRequest"),
    :schema_element => [
      ["items", ["LCDB::Items[]", XSD::QName.new(nil, "items")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::Items,
    :schema_type => XSD::QName.new(NsClaim, "items"),
    :schema_element => [
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["productType", ["SOAP::SOAPString", XSD::QName.new(nil, "productType")], [0, 1]],
      ["productCode", ["SOAP::SOAPString", XSD::QName.new(nil, "productCode")], [0, 1]],
      ["productLevel", ["SOAP::SOAPString", XSD::QName.new(nil, "productLevel")], [0, 1]],
      ["months", ["SOAP::SOAPString", XSD::QName.new(nil, "months")], [0, 1]],
      ["edition", ["SOAP::SOAPString", XSD::QName.new(nil, "edition")], [0, 1]],
      ["brand", ["SOAP::SOAPString", XSD::QName.new(nil, "brand")], [0, 1]],
      ["localization", ["SOAP::SOAPString", XSD::QName.new(nil, "localization")], [0, 1]],
      ["productVersion", ["SOAP::SOAPString", XSD::QName.new(nil, "productVersion")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidateSerialNumberResponse,
    :schema_type => XSD::QName.new(NsClaim, "validateSerialNumberResponse"),
    :schema_element => [
      ["serialNumber", ["LCDB::SerialResponse[]", XSD::QName.new(nil, "serialNumber")], [0, nil]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::SerialResponse,
    :schema_type => XSD::QName.new(NsClaim, "serialResponse"),
    :schema_element => [
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnString", ["SOAP::SOAPString", XSD::QName.new(nil, "returnString")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::UpdatePosaStatusRequest,
    :schema_type => XSD::QName.new(NsClaim, "updatePosaStatusRequest"),
    :schema_element => [
      ["serialNumber", ["LCDB::SerialType[]", XSD::QName.new(nil, "serialNumber")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::SerialType,
    :schema_type => XSD::QName.new(NsClaim, "serialType"),
    :schema_element => [
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::UpdatePosaStatusResponse,
    :schema_type => XSD::QName.new(NsClaim, "updatePosaStatusResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidatePOSARequest,
    :schema_type => XSD::QName.new(NsClaim, "validatePOSARequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidatePOSAResponse,
    :schema_type => XSD::QName.new(NsClaim, "validatePOSAResponse"),
    :schema_element => [
      ["status", ["SOAP::SOAPString", XSD::QName.new(nil, "status")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GenerateActivationIDRequest,
    :schema_type => XSD::QName.new(NsClaim, "generateActivationIDRequest"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]],
      ["token", ["SOAP::SOAPString", XSD::QName.new(nil, "token")], [0, 1]],
      ["orderNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "orderNumber")], [0, 1]],
      ["orgID", ["SOAP::SOAPString", XSD::QName.new(nil, "orgID")], [0, 1]],
      ["groupConsumables", ["SOAP::SOAPString", XSD::QName.new(nil, "groupConsumables")], [0, 1]],
      ["individualConsumables", ["SOAP::SOAPString", XSD::QName.new(nil, "individualConsumables")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GenerateActivationIDResponse,
    :schema_type => XSD::QName.new(NsClaim, "generateActivationIDResponse"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]],
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::SetDownloadTimeRequest,
    :schema_type => XSD::QName.new(NsClaim, "setDownloadTimeRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::SetDownloadTimeResponse,
    :schema_type => XSD::QName.new(NsClaim, "setDownloadTimeResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::DeactivateKeyRequest,
    :schema_type => XSD::QName.new(NsClaim, "deactivateKeyRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::DeactivateKeyResponse,
    :schema_type => XSD::QName.new(NsClaim, "deactivateKeyResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetFNOCatCodeRequest,
    :schema_type => XSD::QName.new(NsClaim, "getFNOCatCodeRequest"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetFNOCatCodeResponse,
    :schema_type => XSD::QName.new(NsClaim, "getFNOCatCodeResponse"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::CheckOutTokensRequest,
    :schema_name => XSD::QName.new(NsClaim, "checkOutTokensRequest"),
    :schema_element => [
      ["activation_id", ["SOAP::SOAPString", XSD::QName.new(nil, "activation_id")]],
      ["tokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "tokenValue")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::CheckOutTokensResponse,
    :schema_name => XSD::QName.new(NsClaim, "checkOutTokensResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::DeactivateKeyRequest,
    :schema_name => XSD::QName.new(NsClaim, "deactivateKeyRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::DeactivateKeyResponse,
    :schema_name => XSD::QName.new(NsClaim, "deactivateKeyResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GenerateActivationIDRequest,
    :schema_name => XSD::QName.new(NsClaim, "generateActivationIDRequest"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]],
      ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")], [0, 1]],
      ["token", ["SOAP::SOAPString", XSD::QName.new(nil, "token")], [0, 1]],
      ["orderNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "orderNumber")], [0, 1]],
      ["orgID", ["SOAP::SOAPString", XSD::QName.new(nil, "orgID")], [0, 1]],
      ["groupConsumables", ["SOAP::SOAPString", XSD::QName.new(nil, "groupConsumables")], [0, 1]],
      ["individualConsumables", ["SOAP::SOAPString", XSD::QName.new(nil, "individualConsumables")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GenerateActivationIDResponse,
    :schema_name => XSD::QName.new(NsClaim, "generateActivationIDResponse"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]],
      ["serialNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "serialNumber")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetAssociatedFeaturesRequest,
    :schema_name => XSD::QName.new(NsClaim, "getAssociatedFeaturesRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetAssociatedFeaturesResponse,
    :schema_name => XSD::QName.new(NsClaim, "getAssociatedFeaturesResponse"),
    :schema_element => [
      ["feature", ["LCDB::FeatureType[]", XSD::QName.new(nil, "feature")], [0, nil]],
      ["availableTokenValue", ["SOAP::SOAPInt", XSD::QName.new(nil, "availableTokenValue")]],
      ["orgID", ["SOAP::SOAPInt", XSD::QName.new(nil, "orgID")]],
      ["individualConsumables", ["SOAP::SOAPInt", XSD::QName.new(nil, "individualConsumables")]],
      ["groupConsumables", ["SOAP::SOAPInt", XSD::QName.new(nil, "groupConsumables")]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetFNOCatCodeRequest,
    :schema_name => XSD::QName.new(NsClaim, "getFNOCatCodeRequest"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::GetFNOCatCodeResponse,
    :schema_name => XSD::QName.new(NsClaim, "getFNOCatCodeResponse"),
    :schema_element => [
      ["catCode", ["SOAP::SOAPString", XSD::QName.new(nil, "catCode")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::PingLCDBServicesRequest,
    :schema_name => XSD::QName.new(NsClaim, "pingLCDBServicesRequest"),
    :schema_element => []
  )

  LiteralRegistry.register(
    :class => LCDB::PingLCDBServicesResponse,
    :schema_name => XSD::QName.new(NsClaim, "pingLCDBServicesResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::SetDownloadTimeRequest,
    :schema_name => XSD::QName.new(NsClaim, "setDownloadTimeRequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::SetDownloadTimeResponse,
    :schema_name => XSD::QName.new(NsClaim, "setDownloadTimeResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::UpdatePosaStatusRequest,
    :schema_name => XSD::QName.new(NsClaim, "updatePosaStatusRequest"),
    :schema_element => [
      ["serialNumber", ["LCDB::SerialType[]", XSD::QName.new(nil, "serialNumber")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::UpdatePosaStatusResponse,
    :schema_name => XSD::QName.new(NsClaim, "updatePosaStatusResponse"),
    :schema_element => [
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidatePOSARequest,
    :schema_name => XSD::QName.new(NsClaim, "validatePOSARequest"),
    :schema_element => [
      ["activationID", ["SOAP::SOAPString", XSD::QName.new(nil, "activationID")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidatePOSAResponse,
    :schema_name => XSD::QName.new(NsClaim, "validatePOSAResponse"),
    :schema_element => [
      ["status", ["SOAP::SOAPString", XSD::QName.new(nil, "status")], [0, 1]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidateSerialNumberRequest,
    :schema_name => XSD::QName.new(NsClaim, "validateSerialNumberRequest"),
    :schema_element => [
      ["items", ["LCDB::Items[]", XSD::QName.new(nil, "items")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => LCDB::ValidateSerialNumberResponse,
    :schema_name => XSD::QName.new(NsClaim, "validateSerialNumberResponse"),
    :schema_element => [
      ["serialNumber", ["LCDB::SerialResponse[]", XSD::QName.new(nil, "serialNumber")], [0, nil]],
      ["returnCode", ["SOAP::SOAPString", XSD::QName.new(nil, "returnCode")], [0, 1]],
      ["returnMessage", ["SOAP::SOAPString", XSD::QName.new(nil, "returnMessage")], [0, 1]]
    ]
  )
end

end
