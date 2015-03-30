require 'xsd/qname'

module LCDB


# {http://domain.rst1.com/services/business/rsPayment}authCreditCard
#   authRec - LCDB::AuthCreditCardRequestType
class AuthCreditCard
  attr_accessor :authRec

  def initialize(authRec = nil)
    @authRec = authRec
  end
end

# {http://domain.rst1.com/services/business/rsPayment}authCreditCardRequestType
#   shipPostalCode - SOAP::SOAPString
#   postalCode - SOAP::SOAPString
#   shipCity - SOAP::SOAPString
#   currencyCode - SOAP::SOAPString
#   customerip - SOAP::SOAPString
#   shipState - SOAP::SOAPString
#   state - SOAP::SOAPString
#   cnty - SOAP::SOAPString
#   shipCuontry - SOAP::SOAPString
#   shipAddr - SOAP::SOAPString
#   bankAcctUseId - SOAP::SOAPString
#   address1 - SOAP::SOAPString
#   address2 - SOAP::SOAPString
#   address3 - SOAP::SOAPString
#   country - SOAP::SOAPString
#   city - SOAP::SOAPString
#   amount - SOAP::SOAPString
#   orgId - SOAP::SOAPString
#   customerId - SOAP::SOAPString
#   stt - SOAP::SOAPString
#   expireDate - SOAP::SOAPString
#   cvv - SOAP::SOAPString
#   variable - SOAP::SOAPString
class AuthCreditCardRequestType
  attr_accessor :shipPostalCode
  attr_accessor :postalCode
  attr_accessor :shipCity
  attr_accessor :currencyCode
  attr_accessor :customerip
  attr_accessor :shipState
  attr_accessor :state
  attr_accessor :cnty
  attr_accessor :shipCuontry
  attr_accessor :shipAddr
  attr_accessor :bankAcctUseId
  attr_accessor :address1
  attr_accessor :address2
  attr_accessor :address3
  attr_accessor :country
  attr_accessor :city
  attr_accessor :amount
  attr_accessor :orgId
  attr_accessor :customerId
  attr_accessor :stt
  attr_accessor :expireDate
  attr_accessor :cvv
  attr_accessor :variable

  def initialize(shipPostalCode = nil, postalCode = nil, shipCity = nil, currencyCode = nil, customerip = nil, shipState = nil, state = nil, cnty = nil, shipCuontry = nil, shipAddr = nil, bankAcctUseId = nil, address1 = nil, address2 = nil, address3 = nil, country = nil, city = nil, amount = nil, orgId = nil, customerId = nil, stt = nil, expireDate = nil, cvv = nil, variable = nil)
    @shipPostalCode = shipPostalCode
    @postalCode = postalCode
    @shipCity = shipCity
    @currencyCode = currencyCode
    @customerip = customerip
    @shipState = shipState
    @state = state
    @cnty = cnty
    @shipCuontry = shipCuontry
    @shipAddr = shipAddr
    @bankAcctUseId = bankAcctUseId
    @address1 = address1
    @address2 = address2
    @address3 = address3
    @country = country
    @city = city
    @amount = amount
    @orgId = orgId
    @customerId = customerId
    @stt = stt
    @expireDate = expireDate
    @cvv = cvv
    @variable = variable
  end
end

# {http://domain.rst1.com/services/business/rsPayment}authCreditCardResponse
#   m_return - LCDB::AuthCreditCardResponseType
class AuthCreditCardResponse
  def m_return
    @v_return
  end

  def m_return=(value)
    @v_return = value
  end

  def initialize(v_return = nil)
    @v_return = v_return
  end
end

# {http://domain.rst1.com/services/business/rsPayment}authCreditCardResponseType
#   authCode - SOAP::SOAPString
#   paymentProcessorId - SOAP::SOAPString
#   avsResult - SOAP::SOAPString
#   cvvResult - SOAP::SOAPString
#   vendor - SOAP::SOAPString
#   attempts - SOAP::SOAPString
#   gcStoreId - SOAP::SOAPString
#   paymentProductId - SOAP::SOAPString
#   authAmount - SOAP::SOAPString
#   paymentMethodId - SOAP::SOAPString
#   gcOrderId - SOAP::SOAPString
#   returnCode - SOAP::SOAPString
#   returnMessage - SOAP::SOAPString
class AuthCreditCardResponseType
  attr_accessor :authCode
  attr_accessor :paymentProcessorId
  attr_accessor :avsResult
  attr_accessor :cvvResult
  attr_accessor :vendor
  attr_accessor :attempts
  attr_accessor :gcStoreId
  attr_accessor :paymentProductId
  attr_accessor :authAmount
  attr_accessor :paymentMethodId
  attr_accessor :gcOrderId
  attr_accessor :returnCode
  attr_accessor :returnMessage

  def initialize(authCode = nil, paymentProcessorId = nil, avsResult = nil, cvvResult = nil, vendor = nil, attempts = nil, gcStoreId = nil, paymentProductId = nil, authAmount = nil, paymentMethodId = nil, gcOrderId = nil, returnCode = nil, returnMessage = nil)
    @authCode = authCode
    @paymentProcessorId = paymentProcessorId
    @avsResult = avsResult
    @cvvResult = cvvResult
    @vendor = vendor
    @attempts = attempts
    @gcStoreId = gcStoreId
    @paymentProductId = paymentProductId
    @authAmount = authAmount
    @paymentMethodId = paymentMethodId
    @gcOrderId = gcOrderId
    @returnCode = returnCode
    @returnMessage = returnMessage
  end
end

# {http://domain.rst1.com/Paymentdetail}PaymentDetail
#   customerId - SOAP::SOAPInt
#   currency - SOAP::SOAPString
#   orgId - SOAP::SOAPInt
#   acctNum - SOAP::SOAPString
#   acctName - SOAP::SOAPString
#   expireDate - SOAP::SOAPString
#   primaryFlag - SOAP::SOAPString
#   paymentAddress - LCDB::Address
#   updateInvoice - SOAP::SOAPString
#   bankName - SOAP::SOAPString
#   bankCntry - SOAP::SOAPString
#   bankCode - SOAP::SOAPString
#   billName - LCDB::Person
#   licenseGUID - SOAP::SOAPString
#   result - SOAP::SOAPString
#   message - SOAP::SOAPString
#   xmlattr_paymentId - SOAP::SOAPInt
class PaymentDetail
  AttrPaymentId = XSD::QName.new(nil, "paymentId")

  attr_accessor :customerId
  attr_accessor :currency
  attr_accessor :orgId
  attr_accessor :acctNum
  attr_accessor :acctName
  attr_accessor :expireDate
  attr_accessor :primaryFlag
  attr_accessor :paymentAddress
  attr_accessor :updateInvoice
  attr_accessor :bankName
  attr_accessor :bankCntry
  attr_accessor :bankCode
  attr_accessor :billName
  attr_accessor :licenseGUID
  attr_accessor :result
  attr_accessor :message

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_paymentId
    __xmlattr[AttrPaymentId]
  end

  def xmlattr_paymentId=(value)
    __xmlattr[AttrPaymentId] = value
  end

  def initialize(customerId = nil, currency = nil, orgId = nil, acctNum = nil, acctName = nil, expireDate = nil, primaryFlag = nil, paymentAddress = nil, updateInvoice = nil, bankName = nil, bankCntry = nil, bankCode = nil, billName = nil, licenseGUID = nil, result = nil, message = nil)
    @customerId = customerId
    @currency = currency
    @orgId = orgId
    @acctNum = acctNum
    @acctName = acctName
    @expireDate = expireDate
    @primaryFlag = primaryFlag
    @paymentAddress = paymentAddress
    @updateInvoice = updateInvoice
    @bankName = bankName
    @bankCntry = bankCntry
    @bankCode = bankCode
    @billName = billName
    @licenseGUID = licenseGUID
    @result = result
    @message = message
    @__xmlattr = {}
  end
end

# {http://domain.rst1.com/Faults}FaultResponse
#   errorType - SOAP::SOAPInt
#   message - SOAP::SOAPString
#   xmlattr_oid - SOAP::SOAPInt
class FaultResponse
  AttrOid = XSD::QName.new(nil, "oid")

  attr_accessor :errorType
  attr_accessor :message

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_oid
    __xmlattr[AttrOid]
  end

  def xmlattr_oid=(value)
    __xmlattr[AttrOid] = value
  end

  def initialize(errorType = nil, message = nil)
    @errorType = errorType
    @message = message
    @__xmlattr = {}
  end
end

# {http://domain.rst1.com/Result}Result
#   result - SOAP::SOAPString
#   message - SOAP::SOAPString
#   xmlattr_oid - SOAP::SOAPInt
class Result
  AttrOid = XSD::QName.new(nil, "oid")

  attr_accessor :result
  attr_accessor :message

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_oid
    __xmlattr[AttrOid]
  end

  def xmlattr_oid=(value)
    __xmlattr[AttrOid] = value
  end

  def initialize(result = nil, message = nil)
    @result = result
    @message = message
    @__xmlattr = {}
  end
end

# {http://domain.rst1.com/Global}Address
#   city - SOAP::SOAPString
#   adrLine1 - SOAP::SOAPString
#   adrLine2 - SOAP::SOAPString
#   postalCode - SOAP::SOAPString
#   country - SOAP::SOAPString
#   email - SOAP::SOAPString
#   phone - SOAP::SOAPString
#   mobile - SOAP::SOAPString
#   state - SOAP::SOAPString
#   timeZone - SOAP::SOAPString
#   alternateEmail - SOAP::SOAPString
#   county - SOAP::SOAPString
#   xmlattr_adroid - SOAP::SOAPLong
class Address
  AttrAdroid = XSD::QName.new(nil, "adroid")

  attr_accessor :city
  attr_accessor :adrLine1
  attr_accessor :adrLine2
  attr_accessor :postalCode
  attr_accessor :country
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :mobile
  attr_accessor :state
  attr_accessor :timeZone
  attr_accessor :alternateEmail
  attr_accessor :county

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_adroid
    __xmlattr[AttrAdroid]
  end

  def xmlattr_adroid=(value)
    __xmlattr[AttrAdroid] = value
  end

  def initialize(city = nil, adrLine1 = nil, adrLine2 = nil, postalCode = nil, country = nil, email = nil, phone = nil, mobile = nil, state = nil, timeZone = nil, alternateEmail = nil, county = nil)
    @city = city
    @adrLine1 = adrLine1
    @adrLine2 = adrLine2
    @postalCode = postalCode
    @country = country
    @email = email
    @phone = phone
    @mobile = mobile
    @state = state
    @timeZone = timeZone
    @alternateEmail = alternateEmail
    @county = county
    @__xmlattr = {}
  end
end

# {http://domain.rst1.com/Global}Person
#   firstName - SOAP::SOAPString
#   lastName - SOAP::SOAPString
#   dob - SOAP::SOAPString
#   gender - LCDB::GenderEnum
#   displayName - SOAP::SOAPString
#   xmlattr_usroid - SOAP::SOAPLong
class Person
  AttrUsroid = XSD::QName.new(nil, "usroid")

  attr_accessor :firstName
  attr_accessor :lastName
  attr_accessor :dob
  attr_accessor :gender
  attr_accessor :displayName

  def __xmlattr
    @__xmlattr ||= {}
  end

  def xmlattr_usroid
    __xmlattr[AttrUsroid]
  end

  def xmlattr_usroid=(value)
    __xmlattr[AttrUsroid] = value
  end

  def initialize(firstName = nil, lastName = nil, dob = nil, gender = nil, displayName = nil)
    @firstName = firstName
    @lastName = lastName
    @dob = dob
    @gender = gender
    @displayName = displayName
    @__xmlattr = {}
  end
end

# {http://domain.rst1.com/Global}GenderEnum
class GenderEnum < ::String
  Female = GenderEnum.new("Female")
  Male = GenderEnum.new("Male")
end


end
