require 'xsd/qname'

module LCDB


# {http://domain.rst1.com/services/business/claim}checkOutTokensRequest
#   activation_id - SOAP::SOAPString
#   tokenValue - SOAP::SOAPInt
class CheckOutTokensRequest
  attr_accessor :activation_id
  attr_accessor :tokenValue

  def initialize(activation_id = nil, tokenValue = nil)
    @activation_id = activation_id
    @tokenValue = tokenValue
  end
end

# {http://domain.rst1.com/services/business/claim}checkOutTokensResponse
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class CheckOutTokensResponse
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(returnCode = nil, returnMessage = nil)
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}getAssociatedFeaturesRequest
#   activationID - SOAP::SOAPString
class GetAssociatedFeaturesRequest
  attr_accessor :activationID

  def initialize(activationID = nil)
    @activationID = activationID
  end
end

# {http://domain.rst1.com/services/business/claim}getAssociatedFeaturesResponse
#   feature - LCDB::FeatureType
#   availableTokenValue - SOAP::SOAPInt
#   orgID - SOAP::SOAPInt
#   individualConsumables - SOAP::SOAPInt
#   groupConsumables - SOAP::SOAPInt
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class GetAssociatedFeaturesResponse
  attr_accessor :feature
  attr_accessor :availableTokenValue
  attr_accessor :orgID
  attr_accessor :individualConsumables
  attr_accessor :groupConsumables
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(feature = [], availableTokenValue = nil, orgID = nil, individualConsumables = nil, groupConsumables = nil, returnCode = nil, returnMessage = nil)
    @feature = feature
    @availableTokenValue = availableTokenValue
    @orgID = orgID
    @individualConsumables = individualConsumables
    @groupConsumables = groupConsumables
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}featureType
#   featureCode - SOAP::SOAPString
#   featureName - SOAP::SOAPString
#   version - SOAP::SOAPString
class FeatureType
  attr_accessor :featureCode
  attr_accessor :featureName
  attr_accessor :version

  def initialize(featureCode = nil, featureName = nil, version = nil)
    @featureCode = featureCode
    @featureName = featureName
    @version = version
  end
end

# {http://domain.rst1.com/services/business/claim}pingLCDBServicesRequest
class PingLCDBServicesRequest
  def initialize
  end
end

# {http://domain.rst1.com/services/business/claim}pingLCDBServicesResponse
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class PingLCDBServicesResponse
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(returnCode = nil, returnMessage = nil)
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}validateSerialNumberRequest
class ValidateSerialNumberRequest < ::Array
end

# {http://domain.rst1.com/services/business/claim}items
#   serialNumber - SOAP::SOAPString
#   productType - SOAP::SOAPString
#   productCode - SOAP::SOAPString
#   productLevel - SOAP::SOAPString
#   months - SOAP::SOAPString
#   edition - SOAP::SOAPString
#   brand - SOAP::SOAPString
#   localization - SOAP::SOAPString
#   productVersion - SOAP::SOAPString
class Items
  attr_accessor :serialNumber
  attr_accessor :productType
  attr_accessor :productCode
  attr_accessor :productLevel
  attr_accessor :months
  attr_accessor :edition
  attr_accessor :brand
  attr_accessor :localization
  attr_accessor :productVersion

  def initialize(serialNumber = nil, productType = nil, productCode = nil, productLevel = nil, months = nil, edition = nil, brand = nil, localization = nil, productVersion = nil)
    @serialNumber = serialNumber
    @productType = productType
    @productCode = productCode
    @productLevel = productLevel
    @months = months
    @edition = edition
    @brand = brand
    @localization = localization
    @productVersion = productVersion
  end
end

# {http://domain.rst1.com/services/business/claim}validateSerialNumberResponse
#   serialNumber - LCDB::SerialResponse
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class ValidateSerialNumberResponse
  attr_accessor :serialNumber
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(serialNumber = [], returnCode = nil, returnMessage = nil)
    @serialNumber = serialNumber
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}serialResponse
#   serialNumber - SOAP::SOAPString
#   returnCode - SOAP::SOAPString
#   returnString - SOAP::SOAPString
class SerialResponse
  attr_accessor :serialNumber
  attr_accessor :returnCode
  attr_accessor :returnString

  def initialize(serialNumber = nil, returnCode = nil, returnString = nil)
    @serialNumber = serialNumber
    @returnCode = returnCode
    @returnString = returnString
  end
end

# {http://domain.rst1.com/services/business/claim}updatePosaStatusRequest
class UpdatePosaStatusRequest < ::Array
end

# {http://domain.rst1.com/services/business/claim}serialType
#   serialNumber - SOAP::SOAPString
class SerialType
  attr_accessor :serialNumber

  def initialize(serialNumber = nil)
    @serialNumber = serialNumber
  end
end

# {http://domain.rst1.com/services/business/claim}updatePosaStatusResponse
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class UpdatePosaStatusResponse
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(returnCode = nil, returnMessage = nil)
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}validatePOSARequest
#   activationID - SOAP::SOAPString
class ValidatePOSARequest
  attr_accessor :activationID

  def initialize(activationID = nil)
    @activationID = activationID
  end
end

# {http://domain.rst1.com/services/business/claim}validatePOSAResponse
#   status - SOAP::SOAPString
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class ValidatePOSAResponse
  attr_accessor :status
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(status = nil, returnCode = nil, returnMessage = nil)
    @status = status
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}generateActivationIDRequest
#   catCode - SOAP::SOAPString
#   version - SOAP::SOAPString
#   token - SOAP::SOAPString
#   orderNumber - SOAP::SOAPString
#   orgID - SOAP::SOAPString
#   groupConsumables - SOAP::SOAPString
#   individualConsumables - SOAP::SOAPString
class GenerateActivationIDRequest
  attr_accessor :catCode
  attr_accessor :version
  attr_accessor :token
  attr_accessor :orderNumber
  attr_accessor :orgID
  attr_accessor :groupConsumables
  attr_accessor :individualConsumables

  def initialize(catCode = nil, version = nil, token = nil, orderNumber = nil, orgID = nil, groupConsumables = nil, individualConsumables = nil)
    @catCode = catCode
    @version = version
    @token = token
    @orderNumber = orderNumber
    @orgID = orgID
    @groupConsumables = groupConsumables
    @individualConsumables = individualConsumables
  end
end

# {http://domain.rst1.com/services/business/claim}generateActivationIDResponse
#   activationID - SOAP::SOAPString
#   serialNumber - SOAP::SOAPString
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class GenerateActivationIDResponse
  attr_accessor :activationID
  attr_accessor :serialNumber
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(activationID = nil, serialNumber = nil, returnCode = nil, returnMessage = nil)
    @activationID = activationID
    @serialNumber = serialNumber
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}setDownloadTimeRequest
#   activationID - SOAP::SOAPString
class SetDownloadTimeRequest
  attr_accessor :activationID

  def initialize(activationID = nil)
    @activationID = activationID
  end
end

# {http://domain.rst1.com/services/business/claim}setDownloadTimeResponse
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class SetDownloadTimeResponse
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(returnCode = nil, returnMessage = nil)
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}deactivateKeyRequest
#   activationID - SOAP::SOAPString
class DeactivateKeyRequest
  attr_accessor :activationID

  def initialize(activationID = nil)
    @activationID = activationID
  end
end

# {http://domain.rst1.com/services/business/claim}deactivateKeyResponse
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class DeactivateKeyResponse
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(returnCode = nil, returnMessage = nil)
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/services/business/claim}getFNOCatCodeRequest
#   catCode - SOAP::SOAPString
class GetFNOCatCodeRequest
  attr_accessor :catCode

  def initialize(catCode = nil)
    @catCode = catCode
  end
end

# {http://domain.rst1.com/services/business/claim}getFNOCatCodeResponse
#   catCode - SOAP::SOAPString
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class GetFNOCatCodeResponse
  attr_accessor :catCode
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(catCode = nil, returnCode = nil, returnMessage = nil)
    @catCode = catCode
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end


end
