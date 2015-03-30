require 'xsd/qname'

module LCDB


  # {http://domain.rst1.com/services/business/lcd}getOrder
  #   arg0 - LCDB::GetOrderDetailsRequestType
  class GetOrder
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getOrderDetailsRequestType
  #   licenseGuid - SOAP::SOAPString
  #   pastDueOnly - SOAP::SOAPString
  class GetOrderDetailsRequestType
    attr_accessor :licenseGuid
    attr_accessor :pastDueOnly

    def initialize(licenseGuid = nil, pastDueOnly = nil)
      @licenseGuid = licenseGuid
      @pastDueOnly = pastDueOnly
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getOrderResponse
  #   m_return - LCDB::GetOrderDetailsResponseType
  class GetOrderResponse
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

  # {http://domain.rst1.com/services/business/lcd}getOrderDetailsResponseType
  #   order - LCDB::Order
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class GetOrderDetailsResponseType
    attr_accessor :order
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(order = [], returnCode = nil, returnMessage = nil)
      @order = order
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}order
  #   licenseGuid - SOAP::SOAPString
  #   email - SOAP::SOAPString
  #   order_number - SOAP::SOAPString
  #   customer_number - SOAP::SOAPString
  #   ordered_date - SOAP::SOAPString
  #   orig_sys_document_ref - SOAP::SOAPString
  #   sales_channel - SOAP::SOAPString
  #   order_total - SOAP::SOAPDouble
  #   captureStatus - SOAP::SOAPString
  #   payment_type - SOAP::SOAPString
  #   cancel_flag - SOAP::SOAPString
  #   org - SOAP::SOAPString
  #   orderItems - LCDB::OrderItems
  #   past_due_flag - SOAP::SOAPString
  #   due_date - SOAP::SOAPString
  class Order
    attr_accessor :licenseGuid
    attr_accessor :email
    attr_accessor :order_number
    attr_accessor :customer_number
    attr_accessor :ordered_date
    attr_accessor :orig_sys_document_ref
    attr_accessor :sales_channel
    attr_accessor :order_total
    attr_accessor :captureStatus
    attr_accessor :payment_type
    attr_accessor :cancel_flag
    attr_accessor :org
    attr_accessor :orderItems
    attr_accessor :past_due_flag
    attr_accessor :due_date

    def initialize(licenseGuid = nil, email = nil, order_number = nil, customer_number = nil, ordered_date = nil, orig_sys_document_ref = nil, sales_channel = nil, order_total = nil, captureStatus = nil, payment_type = nil, cancel_flag = nil, org = nil, orderItems = [], past_due_flag = nil, due_date = nil)
      @licenseGuid = licenseGuid
      @email = email
      @order_number = order_number
      @customer_number = customer_number
      @ordered_date = ordered_date
      @orig_sys_document_ref = orig_sys_document_ref
      @sales_channel = sales_channel
      @order_total = order_total
      @captureStatus = captureStatus
      @payment_type = payment_type
      @cancel_flag = cancel_flag
      @org = org
      @orderItems = orderItems
      @past_due_flag = past_due_flag
      @due_date = due_date
    end
  end

  # {http://domain.rst1.com/services/business/lcd}orderItems
  #   order_line_id - SOAP::SOAPInt
  #   item - SOAP::SOAPString
  #   language - SOAP::SOAPString
  #   line_status - SOAP::SOAPString
  #   pr_guid - SOAP::SOAPString
  class OrderItems
    attr_accessor :order_line_id
    attr_accessor :item
    attr_accessor :language
    attr_accessor :line_status
    attr_accessor :pr_guid

    def initialize(order_line_id = nil, item = nil, language = nil, line_status = nil, pr_guid = nil)
      @order_line_id = order_line_id
      @item = item
      @language = language
      @line_status = line_status
      @pr_guid = pr_guid
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setOrder
  #   arg0 - LCDB::Order
  class SetOrder
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setOrderResponse
  #   m_return - LCDB::GenericResponseType
  class SetOrderResponse
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

  # {http://domain.rst1.com/services/business/lcd}genericResponseType
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class GenericResponseType
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(returnCode = nil, returnMessage = nil)
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setCustomerDetails
  #   arg0 - LCDB::Customer
  class SetCustomerDetails
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}customer
  #   customer_number - SOAP::SOAPString
  #   customer_flag - SOAP::SOAPString
  #   learner_flag - SOAP::SOAPString
  #   masterGuid - SOAP::SOAPString
  #   sold_to_org_id - SOAP::SOAPString
  #   org_id - SOAP::SOAPString
  #   first_name - SOAP::SOAPString
  #   last_name - SOAP::SOAPString
  #   email - SOAP::SOAPString
  #   orig_sys_document_ref - SOAP::SOAPString
  #   customerDetails - LCDB::CustomerDetails
  #   license - LCDB::License
  class Customer
    attr_accessor :customer_number
    attr_accessor :customer_flag
    attr_accessor :learner_flag
    attr_accessor :masterGuid
    attr_accessor :sold_to_org_id
    attr_accessor :org_id
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :email
    attr_accessor :orig_sys_document_ref
    attr_accessor :customerDetails
    attr_accessor :license

    def initialize(customer_number = nil, customer_flag = nil, learner_flag = nil, masterGuid = nil, sold_to_org_id = nil, org_id = nil, first_name = nil, last_name = nil, email = nil, orig_sys_document_ref = nil, customerDetails = [], license = [])
      @customer_number = customer_number
      @customer_flag = customer_flag
      @learner_flag = learner_flag
      @masterGuid = masterGuid
      @sold_to_org_id = sold_to_org_id
      @org_id = org_id
      @first_name = first_name
      @last_name = last_name
      @email = email
      @orig_sys_document_ref = orig_sys_document_ref
      @customerDetails = customerDetails
      @license = license
    end
  end

  # {http://domain.rst1.com/services/business/lcd}customerDetails
  #   site_use_id - SOAP::SOAPString
  #   site_type - SOAP::SOAPString
  #   first_name - SOAP::SOAPString
  #   last_name - SOAP::SOAPString
  #   phonetic_first_name - SOAP::SOAPString
  #   phonetic_last_name - SOAP::SOAPString
  #   address1 - SOAP::SOAPString
  #   address2 - SOAP::SOAPString
  #   city - SOAP::SOAPString
  #   country - SOAP::SOAPString
  #   state_province - SOAP::SOAPString
  #   zip - SOAP::SOAPString
  #   phone - SOAP::SOAPString
  #   email - SOAP::SOAPString
  #   credit_card_id - SOAP::SOAPString
  class CustomerDetails
    attr_accessor :site_use_id
    attr_accessor :site_type
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :phonetic_first_name
    attr_accessor :phonetic_last_name
    attr_accessor :address1
    attr_accessor :address2
    attr_accessor :city
    attr_accessor :country
    attr_accessor :state_province
    attr_accessor :zip
    attr_accessor :phone
    attr_accessor :email
    attr_accessor :credit_card_id

    def initialize(site_use_id = nil, site_type = nil, first_name = nil, last_name = nil, phonetic_first_name = nil, phonetic_last_name = nil, address1 = nil, address2 = nil, city = nil, country = nil, state_province = nil, zip = nil, phone = nil, email = nil, credit_card_id = nil)
      @site_use_id = site_use_id
      @site_type = site_type
      @first_name = first_name
      @last_name = last_name
      @phonetic_first_name = phonetic_first_name
      @phonetic_last_name = phonetic_last_name
      @address1 = address1
      @address2 = address2
      @city = city
      @country = country
      @state_province = state_province
      @zip = zip
      @phone = phone
      @email = email
      @credit_card_id = credit_card_id
    end
  end

  # {http://domain.rst1.com/services/business/lcd}license
  #   licenseGUID - SOAP::SOAPString
  #   masterFlag - SOAP::SOAPString
  #   suspendStatus - SOAP::SOAPString
  #   suspendReason - SOAP::SOAPString
  #   rsPan - SOAP::SOAPString
  #   licenseDetails - LCDB::LicenseDetails
  #   licenseType - SOAP::SOAPString
  #   serverURL - SOAP::SOAPString
  #   serverCountry - SOAP::SOAPString
  class License
    attr_accessor :licenseGUID
    attr_accessor :masterFlag
    attr_accessor :suspendStatus
    attr_accessor :suspendReason
    attr_accessor :rsPan
    attr_accessor :apiKey
    attr_accessor :licenseDetails
    attr_accessor :licenseType
    attr_accessor :serverURL
    attr_accessor :serverCountry

    def initialize(licenseGUID = nil, masterFlag = nil, suspendStatus = nil, suspendReason = nil, rsPan = nil, apiKey = nil, licenseDetails = [], licenseType = nil, serverURL = nil, serverCountry = nil)
      @licenseGUID = licenseGUID
      @masterFlag = masterFlag
      @suspendStatus = suspendStatus
      @suspendReason = suspendReason
      @rsPan = rsPan
      @apiKey = apiKey
      @licenseDetails = licenseDetails
      @licenseType = licenseType
      @serverURL = serverURL
      @serverCountry = serverCountry
    end
  end

  # {http://domain.rst1.com/services/business/lcd}licenseDetails
  #   prGUIDRec - LCDB::PrguidType
  #   language - SOAP::SOAPString
  #   autoRenewalFlag - SOAP::SOAPString
  #   renewalPrice - SOAP::SOAPString
  #   bankAcctusesId - SOAP::SOAPInt
  #   processingId - SOAP::SOAPString
  #   vendor - SOAP::SOAPString
  #   item - SOAP::SOAPString
  #   currency - SOAP::SOAPString
  #   trialFlag - SOAP::SOAPString
  #   trialStartDate - SOAP::SOAPString
  #   trialEndDate - SOAP::SOAPString
  #   source - SOAP::SOAPString
  #   start_date - SOAP::SOAPString
  #   end_date - SOAP::SOAPString
  #   xmlattr_groupId - SOAP::SOAPInt
  class LicenseDetails
    AttrGroupId = XSD::QName.new(nil, "groupId")

    attr_accessor :prGUIDRec
    attr_accessor :language
    attr_accessor :autoRenewalFlag
    attr_accessor :renewalPrice
    attr_accessor :renewalTerm
    attr_accessor :bankAcctusesId
    attr_accessor :processingId
    attr_accessor :vendor
    attr_accessor :item
    attr_accessor :currency
    attr_accessor :trialFlag
    attr_accessor :trialStartDate
    attr_accessor :trialEndDate
    attr_accessor :source
    attr_accessor :start_date
    attr_accessor :end_date
    attr_accessor :subscriptionID

    def __xmlattr
      @__xmlattr ||= {}
    end

    def xmlattr_groupId
      __xmlattr[AttrGroupId]
    end

    def xmlattr_groupId=(value)
      __xmlattr[AttrGroupId] = value
    end

    def initialize(prGUIDRec = nil, language = nil, autoRenewalFlag = nil, renewalPrice = nil, renewalTerm = nil, bankAcctusesId = nil, processingId = nil, vendor = nil, item = nil, currency = nil, trialFlag = nil, trialStartDate = nil, trialEndDate = nil, source = nil, start_date = nil, end_date = nil, subscriptionID = nil)
      @prGUIDRec = prGUIDRec
      @language = language
      @autoRenewalFlag = autoRenewalFlag
      @renewalPrice = renewalPrice
      @renewalTerm = renewalTerm
      @bankAcctusesId = bankAcctusesId
      @processingId = processingId
      @vendor = vendor
      @item = item
      @currency = currency
      @trialFlag = trialFlag
      @trialStartDate = trialStartDate
      @trialEndDate = trialEndDate
      @source = source
      @start_date = start_date
      @end_date = end_date
      @subscriptionID = subscriptionID
      @__xmlattr = {}
    end
  end

  # {http://domain.rst1.com/services/business/lcd}prguidType
  class PrguidType < ::Array
  end

  # {http://domain.rst1.com/services/business/lcd}setCustomerDetailsResponse
  #   m_return - LCDB::GenericResponseType
  class SetCustomerDetailsResponse
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

  # {http://domain.rst1.com/services/business/lcd}setCustomerNumber
  #   arg0 - LCDB::SetCustNumberRequestType
  class SetCustomerNumber
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setCustNumberRequestType
  #   bill_to_site_use_id - SOAP::SOAPString
  #   customer_number - SOAP::SOAPString
  #   orig_sys_document_ref - SOAP::SOAPString
  #   ship_to_site_use_id - SOAP::SOAPString
  #   sold_to_org_id - SOAP::SOAPString
  class SetCustNumberRequestType
    attr_accessor :bill_to_site_use_id
    attr_accessor :customer_number
    attr_accessor :orig_sys_document_ref
    attr_accessor :ship_to_site_use_id
    attr_accessor :sold_to_org_id

    def initialize(bill_to_site_use_id = nil, customer_number = nil, orig_sys_document_ref = nil, ship_to_site_use_id = nil, sold_to_org_id = nil)
      @bill_to_site_use_id = bill_to_site_use_id
      @customer_number = customer_number
      @orig_sys_document_ref = orig_sys_document_ref
      @ship_to_site_use_id = ship_to_site_use_id
      @sold_to_org_id = sold_to_org_id
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setCustomerNumberResponse
  #   m_return - LCDB::GenericResponseType
  class SetCustomerNumberResponse
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

  # {http://domain.rst1.com/services/business/lcd}updatePersonDetails
  #   arg0 - LCDB::UpdatePersonDetailRequest
  class UpdatePersonDetails
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}updatePersonDetailRequest
  #   licenseGuid - SOAP::SOAPString
  #   personDetails - LCDB::CustomerDetails
  class UpdatePersonDetailRequest
    attr_accessor :licenseGuid
    attr_accessor :personDetails

    def initialize(licenseGuid = nil, personDetails = nil)
      @licenseGuid = licenseGuid
      @personDetails = personDetails
    end
  end

  # {http://domain.rst1.com/services/business/lcd}updatePersonDetailsResponse
  #   m_return - LCDB::GenericResponseType
  class UpdatePersonDetailsResponse
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

  # {http://domain.rst1.com/services/business/lcd}getCustomerDetails
  #   arg0 - LCDB::GetCustomerDetailsRequestType
  class GetCustomerDetails
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getCustomerDetailsRequestType
  #   email - SOAP::SOAPString
  #   licenseGuid - SOAP::SOAPString
  #   language - SOAP::SOAPString
  class GetCustomerDetailsRequestType
    attr_accessor :email
    attr_accessor :licenseGuid
    attr_accessor :language

    def initialize(email = nil, licenseGuid = nil, language = nil)
      @email = email
      @licenseGuid = licenseGuid
      @language = language
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getCustomerDetailsResponse
  #   m_return - LCDB::GetCustomerDetailsResponseType
  class GetCustomerDetailsResponse
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

  # {http://domain.rst1.com/services/business/lcd}getCustomerDetailsResponseType
  #   customer - LCDB::Customer
  #   pastDueResponse - LCDB::GetPastDueResponse
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class GetCustomerDetailsResponseType
    attr_accessor :customer
    attr_accessor :pastDueResponse
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(customer = nil, pastDueResponse = nil, returnCode = nil, returnMessage = nil)
      @customer = customer
      @pastDueResponse = pastDueResponse
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getPastDueResponse
  #   pastDue - LCDB::PastDuePaymentType
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class GetPastDueResponse
    attr_accessor :pastDue
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(pastDue = [], returnCode = nil, returnMessage = nil)
      @pastDue = pastDue
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}pastDuePaymentType
  #   missedPayments - SOAP::SOAPInt
  #   amountDue - SOAP::SOAPDouble
  #   language - SOAP::SOAPString
  #   orderNumber - SOAP::SOAPString
  #   paymentType - SOAP::SOAPString
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class PastDuePaymentType
    attr_accessor :missedPayments
    attr_accessor :amountDue
    attr_accessor :language
    attr_accessor :orderNumber
    attr_accessor :paymentType
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(missedPayments = nil, amountDue = nil, language = nil, orderNumber = nil, paymentType = nil, returnCode = nil, returnMessage = nil)
      @missedPayments = missedPayments
      @amountDue = amountDue
      @language = language
      @orderNumber = orderNumber
      @paymentType = paymentType
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}updateOrderPayStatus
  #   arg0 - LCDB::Order
  class UpdateOrderPayStatus
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}updateOrderPayStatusResponse
  #   m_return - LCDB::GenericResponseType
  class UpdateOrderPayStatusResponse
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

  # {http://domain.rst1.com/services/business/lcd}getRenewal
  #   arg0 - LCDB::GetRenewalRequestType
  class GetRenewal
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getRenewalRequestType
  #   licenseGUID - SOAP::SOAPString
  #   language - SOAP::SOAPString
  #   pr_guid - SOAP::SOAPString
  #   xmlattr_groupId - SOAP::SOAPInt
  class GetRenewalRequestType
    AttrGroupId = XSD::QName.new(nil, "groupId")

    attr_accessor :licenseGUID
    attr_accessor :language
    attr_accessor :pr_guid

    def __xmlattr
      @__xmlattr ||= {}
    end

    def xmlattr_groupId
      __xmlattr[AttrGroupId]
    end

    def xmlattr_groupId=(value)
      __xmlattr[AttrGroupId] = value
    end

    def initialize(licenseGUID = nil, language = nil, pr_guid = nil)
      @licenseGUID = licenseGUID
      @language = language
      @pr_guid = pr_guid
      @__xmlattr = {}
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getRenewalResponse
  #   m_return - LCDB::GetRenewalResponseType
  class GetRenewalResponse
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

  # {http://domain.rst1.com/services/business/lcd}getRenewalResponseType
  #   licenseGuid - SOAP::SOAPString
  #   licenseDetails - LCDB::LicenseDetails
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  #   xmlattr_groupId - SOAP::SOAPInt
  class GetRenewalResponseType
    AttrGroupId = XSD::QName.new(nil, "groupId")

    attr_accessor :licenseGuid
    attr_accessor :licenseDetails
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def __xmlattr
      @__xmlattr ||= {}
    end

    def xmlattr_groupId
      __xmlattr[AttrGroupId]
    end

    def xmlattr_groupId=(value)
      __xmlattr[AttrGroupId] = value
    end

    def initialize(licenseGuid = nil, licenseDetails = [], returnCode = nil, returnMessage = nil)
      @licenseGuid = licenseGuid
      @licenseDetails = licenseDetails
      @returnCode = returnCode
      @returnMessage = returnMessage
      @__xmlattr = {}
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setRenewal
  #   arg0 - LCDB::SetRenewalRequestType
  class SetRenewal
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setRenewalRequestType
  #   licenseGuid - SOAP::SOAPString
  #   language - SOAP::SOAPString
  #   prGUID - SOAP::SOAPString
  #   autoRenewalFlag - SOAP::SOAPString
  #   renewalPrice - SOAP::SOAPString
  #   bankAcctUsesId - SOAP::SOAPInt
  #   processingId - SOAP::SOAPString
  #   vendor - SOAP::SOAPString
  #   item - SOAP::SOAPString
  #   currency - SOAP::SOAPString
  #   xmlattr_groupId - SOAP::SOAPInt
  class SetRenewalRequestType
    AttrGroupId = XSD::QName.new(nil, "groupId")

    attr_accessor :licenseGuid
    attr_accessor :language
    attr_accessor :prGUID
    attr_accessor :source
    attr_accessor :autoRenewalFlag
    attr_accessor :renewalPrice
    attr_accessor :renewalTerm
    attr_accessor :bankAcctUsesId
    attr_accessor :rsPan
    attr_accessor :processingId
    attr_accessor :vendor
    attr_accessor :item
    attr_accessor :currency

    def __xmlattr
      @__xmlattr ||= {}
    end

    def xmlattr_groupId
      __xmlattr[AttrGroupId]
    end

    def xmlattr_groupId=(value)
      __xmlattr[AttrGroupId] = value
    end

    def initialize(licenseGuid = nil, language = nil, prGUID = nil, source = nil, autoRenewalFlag = nil, renewalPrice = nil, renewalTerm = nil, bankAcctUsesId = nil, rsPan = nil, processingId = nil, vendor = nil, item = nil, currency = nil)
      @licenseGuid = licenseGuid
      @language = language
      @prGUID = prGUID
      @source = source
      @autoRenewalFlag = autoRenewalFlag
      @renewalPrice = renewalPrice
      @renewalTerm = renewalTerm
      @bankAcctUsesId = bankAcctUsesId
      @rsPan = rsPan
      @processingId = processingId
      @vendor = vendor
      @item = item
      @currency = currency
      @__xmlattr = {}
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setRenewalResponse
  #   m_return - LCDB::GenericResponseType
  class SetRenewalResponse
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

  # {http://domain.rst1.com/services/business/lcd}pingLCDBServices
  class PingLCDBServices
    def initialize
    end
  end

  # {http://domain.rst1.com/services/business/lcd}pingLCDBServicesResponse
  #   m_return - LCDB::GenericResponseType
  class PingLCDBServicesResponse
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

  # {http://domain.rst1.com/services/business/lcd}getPastDuePayments
  #   arg0 - LCDB::GetPastDueRequestType
  class GetPastDuePayments
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getPastDueRequestType
  #   licenseGuid - SOAP::SOAPString
  #   email - SOAP::SOAPString
  #   language - SOAP::SOAPString
  class GetPastDueRequestType
    attr_accessor :licenseGuid
    attr_accessor :email
    attr_accessor :language

    def initialize(licenseGuid = nil, email = nil, language = nil)
      @licenseGuid = licenseGuid
      @email = email
      @language = language
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getPastDuePaymentsResponse
  #   m_return - LCDB::GetPastDueResponse
  class GetPastDuePaymentsResponse
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

  # {http://domain.rst1.com/services/business/lcd}checkTrial
  #   arg0 - LCDB::GetCheckTrialRequestType
  class CheckTrial
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}getCheckTrialRequestType
  #   email - SOAP::SOAPString
  #   language - SOAP::SOAPString
  class GetCheckTrialRequestType
    attr_accessor :email
    attr_accessor :language

    def initialize(email = nil, language = nil)
      @email = email
      @language = language
    end
  end

  # {http://domain.rst1.com/services/business/lcd}checkTrialResponse
  #   m_return - LCDB::GetCheckTrialResponseType
  class CheckTrialResponse
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

  # {http://domain.rst1.com/services/business/lcd}getCheckTrialResponseType
  #   eligibleFlag - SOAP::SOAPString
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class GetCheckTrialResponseType
    attr_accessor :eligibleFlag
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(eligibleFlag = nil, returnCode = nil, returnMessage = nil)
      @eligibleFlag = eligibleFlag
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}updateLicense
  #   arg0 - LCDB::License
  class UpdateLicense
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}updateLicenseResponse
  #   m_return - LCDB::GenericResponseType
  class UpdateLicenseResponse
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

  # {http://domain.rst1.com/services/business/lcd}setPrGuid
  #   licenseGuid - SOAP::SOAPString
  #   language - SOAP::SOAPString
  #   prGUID - LCDB::PrguidType
  #   xmlattr_groupId - SOAP::SOAPInt
  class SetPrGuid
    AttrGroupId = XSD::QName.new(nil, "groupId")

    attr_accessor :licenseGuid
    attr_accessor :language
    attr_accessor :prGUID

    def __xmlattr
      @__xmlattr ||= {}
    end

    def xmlattr_groupId
      __xmlattr[AttrGroupId]
    end

    def xmlattr_groupId=(value)
      __xmlattr[AttrGroupId] = value
    end

    def initialize(licenseGuid = nil, language = nil, prGUID = nil)
      @licenseGuid = licenseGuid
      @language = language
      @prGUID = prGUID
      @__xmlattr = {}
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setPrGuidResponse
  #   m_return - LCDB::GenericResponseType
  class SetPrGuidResponse
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

  # {http://domain.rst1.com/services/business/lcd}switchAccount
  #   arg0 - LCDB::SwitchAccountRequestType
  class SwitchAccount
    attr_accessor :arg0

    def initialize(arg0 = nil)
      @arg0 = arg0
    end
  end

  # {http://domain.rst1.com/services/business/lcd}switchAccountRequestType
  #   licenseGuid - SOAP::SOAPString
  #   orgId - SOAP::SOAPString
  #   customerId - SOAP::SOAPDecimal
  #   currency - SOAP::SOAPString
  #   billTo - LCDB::CustomerDetails
  #   shipTo - LCDB::CustomerDetails
  class SwitchAccountRequestType
    attr_accessor :licenseGuid
    attr_accessor :orgId
    attr_accessor :customerId
    attr_accessor :currency
    attr_accessor :billTo
    attr_accessor :shipTo

    def initialize(licenseGuid = nil, orgId = nil, customerId = nil, currency = nil, billTo = nil, shipTo = nil)
      @licenseGuid = licenseGuid
      @orgId = orgId
      @customerId = customerId
      @currency = currency
      @billTo = billTo
      @shipTo = shipTo
    end
  end

  # {http://domain.rst1.com/services/business/lcd}switchAccountResponse
  #   m_return - LCDB::GenericResponseType
  class SwitchAccountResponse
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

  # {http://domain.rst1.com/services/business/lcd}getMarketValue
  class GetMarketValue < ::Array
  end

  # {http://domain.rst1.com/services/business/lcd}getMarketValueResponse
  class GetMarketValueResponse < ::Array
  end

  # {http://domain.rst1.com/services/business/lcd}getMarketValueResponseType
  #   purchaseDate - SOAP::SOAPString
  #   activationId - SOAP::SOAPString
  #   currency - SOAP::SOAPString
  #   orgId - SOAP::SOAPString
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  class GetMarketValueResponseType
    attr_accessor :purchaseDate
    attr_accessor :activationId
    attr_accessor :currency
    attr_accessor :orgId
    attr_accessor :returnCode
    attr_accessor :returnMessage

    def initialize(purchaseDate = nil, activationId = nil, currency = nil, orgId = nil, returnCode = nil, returnMessage = nil)
      @purchaseDate = purchaseDate
      @activationId = activationId
      @currency = currency
      @orgId = orgId
      @returnCode = returnCode
      @returnMessage = returnMessage
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setProductRights
  #   activationId - SOAP::SOAPString
  #   productRights - LCDB::PrDetails
  class SetProductRights
    attr_accessor :activationId
    attr_accessor :productRights

    def initialize(activationId = [], productRights = [])
      @activationId = activationId
      @productRights = productRights
    end
  end

  # {http://domain.rst1.com/services/business/lcd}prDetails
  #   family - SOAP::SOAPString
  #   extRefId - SOAP::SOAPString
  #   productRight - SOAP::SOAPString
  class PrDetails
    attr_accessor :family
    attr_accessor :extRefId
    attr_accessor :productRight

    def initialize(family = nil, extRefId = nil, productRight = nil)
      @family = family
      @extRefId = extRefId
      @productRight = productRight
    end
  end

  # {http://domain.rst1.com/services/business/lcd}setProductRightsResponse
  #   m_return - LCDB::GenericResponseType
  class SetProductRightsResponse
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

  # {http://domain.rst1.com/services/business/lcd}switchLanguage
  #   productRight - SOAP::SOAPString
  #   language - SOAP::SOAPString
  class SwitchLanguage
    attr_accessor :productRight
    attr_accessor :language

    def initialize(productRight = nil, language = nil)
      @productRight = productRight
      @language = language
    end
  end

  # {http://domain.rst1.com/services/business/lcd}switchLanguageResponse
  #   m_return - LCDB::GenericResponseType
  class SwitchLanguageResponse
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

  # {http://domain.rst1.com/services/business/lcd}validateProductRights
  #   emailAddress - SOAP::SOAPString
  #   language - SOAP::SOAPString
  class ValidateProductRights
    attr_accessor :emailAddress
    attr_accessor :language

    def initialize(emailAddress = nil, language = nil)
      @emailAddress = emailAddress
      @language = language
    end
  end

  # {http://domain.rst1.com/services/business/lcd}validateProductRightsResponse
  #   m_return - LCDB::ProductRightResponseType
  class ValidateProductRightsResponse
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

  # {http://domain.rst1.com/services/business/lcd}productRightResponseType
  #   returnCode - SOAP::SOAPString
  #   returnMessage - SOAP::SOAPString
  #   prGuid - SOAP::SOAPString
  class ProductRightResponseType
    attr_accessor :returnCode
    attr_accessor :returnMessage
    attr_accessor :prGuid

    def initialize(returnCode = nil, returnMessage = nil, prGuid = [])
      @returnCode = returnCode
      @returnMessage = returnMessage
      @prGuid = prGuid
    end
  end

  # {http://domain.rst1.com/services/business/lcd}createBillingProfile
  #   customer - LCDB::Customer
  #   paymentDetails - LCDB::PaymentDetails
  class CreateBillingProfile
    attr_accessor :customer
    attr_accessor :paymentDetails

    def initialize(customer = nil, paymentDetails = nil)
      @customer = customer
      @paymentDetails = paymentDetails
    end
  end

  # {http://domain.rst1.com/services/business/lcd}paymentDetails
  #   creditCardNum - SOAP::SOAPString
  #   expirationDate - SOAP::SOAPString
  #   cardHolderName - SOAP::SOAPString
  #   currency - SOAP::SOAPString
  class PaymentDetails
    attr_accessor :creditCardNum
    attr_accessor :expirationDate
    attr_accessor :cardHolderName
    attr_accessor :currency

    def initialize(creditCardNum = nil, expirationDate = nil, cardHolderName = nil, currency = nil)
      @creditCardNum = creditCardNum
      @expirationDate = expirationDate
      @cardHolderName = cardHolderName
      @currency = currency
    end
  end

  # {http://domain.rst1.com/services/business/lcd}createBillingProfileResponse
  #   m_return - LCDB::GenericResponseType
  class CreateBillingProfileResponse
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


end

