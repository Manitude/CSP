require 'soap/header/simplehandler'
require 'xsd/datatypes'
require 'claim_services/driver'
require 'tsub_claim_services/driver'
require 'lcdb_services/driver'
require 'payment_services/driver'

module LCDB
  Families = ['application', 'eschool', 'premium_community', 'lotus', 'eschool_group_sessions', 'eschool_one_on_one_sessions', 'language_switching'].freeze

  class CliamAuthHeaderHandler < SOAP::Header::SimpleHandler
    #TokenName = XSD::QName.new('http://claimservices/', 'token')
    TokenName = XSD::QName.new('http://domain.rst1.com', 'securityToken')

    def initialize(token)
      super(TokenName)
      @token = token
    end

    def on_simple_outbound
      @token
    end
  end

  class TsubClaimAuthHeaderHandler < SOAP::Header::SimpleHandler
    TokenName = XSD::QName.new('http://claimservices/', 'token')

    def initialize(token)
      super(TokenName)
      @token = token
    end

    def on_simple_outbound
      @token
    end
  end

  class LcdbAuthHeaderHandler < SOAP::Header::SimpleHandler
    TokenName = XSD::QName.new('http://domain.rst1.com/services/business/lcd', 'token')

    def initialize(token)
      super(TokenName)
      @token = token
    end

    def on_simple_outbound
      @token
    end
  end

  class PaymentAuthHeaderHandler < SOAP::Header::SimpleHandler
    TokenName = XSD::QName.new('http://domain.rst1.com/services/paymentdetail/', 'token')

    def initialize(token)
      super(TokenName)
      @token = token
    end

    def on_simple_outbound
      @token
    end
  end


  class Client

    def initialize(claim, lcdb, payment=nil, log_device=nil, tsub_claim=nil)
      @cclient = ClaimServices.new(claim['end_point'])
      @tclient = TsubClaimServices.new(tsub_claim['end_point']) if tsub_claim
      @lclient = LCDBServices.new(lcdb['end_point'])
      @pclient = PaymentServiceWS.new(payment['end_point']) if payment
      #@cclient.wiredump_dev = @lclient.wiredump_dev = @tclient.wiredump_dev = STDOUT #if log_device
      @cclient.wiredump_dev = @lclient.wiredump_dev = log_device if log_device

      if claim['token']
        @cclient.headerhandler << CliamAuthHeaderHandler.new(claim['token'])
      end
      if tsub_claim && tsub_claim['token']
        @tclient.headerhandler << TsubClaimAuthHeaderHandler.new(tsub_claim['token'])
      end
      if lcdb['token']
        @lclient.headerhandler << LcdbAuthHeaderHandler.new(lcdb['token'])
      end
      if payment && payment['token']
        @pclient.headerhandler << PaymentAuthHeaderHandler.new(payment['token'])
      end
    end

    def log_dev=(logger)
      @cclient.wiredump_dev = logger
      @lclient.wiredump_dev = logger
      @pclient.wiredump_dev = logger if @pclient
    end

    #****************************************CLAIM****************************************
    # SYNOPSIS
    #   checkOutTokens(parameters)
    #
    # ARGS
    #   parameters      CheckOutTokens - {http://claimservices/}checkOutTokens
    #
    # RETURNS
    #   parameters      CheckOutTokensResponse - {http://claimservices/}checkOutTokensResponse
    #
    def checkout_tokens(claim_code, token_count)
      @cclient.checkOutTokens(CheckOutTokensRequest.new(claim_code, token_count))
    end

    # SYNOPSIS
    #   getAssociatedFeatures(parameters)
    #
    # ARGS
    #   parameters      GetAssociatedFeatures - {http://claimservices/}getAssociatedFeatures
    #
    # RETURNS
    #   parameters      GetAssociatedFeaturesResponse - {http://claimservices/}getAssociatedFeaturesResponse
    #
    def get_associated_features(claim_code)
      #@cclient.getAssociatedFeatures(GetAssociatedFeatures.new(GetFeaturesRequestType.new(claim_code)),"db4e1edf195319fc6b0f4305039a2fea")
      @cclient.getAssociatedFeatures(GetAssociatedFeaturesRequest.new(claim_code))
    end

    def tsub_get_associated_features(claim_code)
      @tclient.getAssociatedFeatures(TsubGetAssociatedFeatures.new(TsubGetFeaturesRequestType.new(claim_code)),"db4e1edf195319fc6b0f4305039a2fea")
    end


    # SYNOPSIS
    #   setDownloadTime(parameters)
    #
    # ARGS
    #   parameters      SetDownloadTimeRequest - {http://domain.rst1.com/services/business/claim}setDownloadTimeRequest
    #
    # RETURNS
    #   parameters      SetDownloadTimeResponse - {http://domain.rst1.com/services/business/claim}setDownloadTimeResponse

    def set_download_time(activation_id)
      @cclient.setDownloadTime(SetDownloadTimeRequest.new(activation_id))
    end


    #****************************************LCDB*****************************************
    # SYNOPSIS
    #   setCustomerDetails(parameters)
    #
    # ARGS
    #   parameters      SetCustomerDetails - {http://lcdb_services/}setCustomerDetails
    #
    # RETURNS
    #   parameters      SetCustomerDetailsResponse - {http://lcdb_services/}setCustomerDetailsResponse
    #
    #parameters = nil
    #puts obj.setCustomerDetails(parameters)

    def set_customer_details_from_claim_flow(claim_customer_details)
      #LicenseDetails object
      license_details = LicenseDetails.new
      license_details.prGUIDRec = PrguidType.new(claim_customer_details[:pr_guids])
      license_details.language = claim_customer_details[:language]
      license_details.currency = claim_customer_details[:currency]
      license_details.autoRenewalFlag = claim_customer_details[:renewal_flag].nil? ? "N" : claim_customer_details[:renewal_flag]
      license_details.renewalPrice = claim_customer_details[:renewal_price].nil? ? "0.0" : claim_customer_details[:renewal_price]
      #License Object
      license = License.new
      license.licenseGUID = claim_customer_details[:license_guid]
      license.licenseDetails = license_details
      #Customer Object
      customer = Customer.new 
      customer.customer_number = claim_customer_details[:license_guid]
      customer.learner_flag = 'Y'
      customer.org_id = claim_customer_details[:org_id]
      customer.first_name = claim_customer_details[:first_name]
      customer.last_name = claim_customer_details[:last_name]
      customer.email = claim_customer_details[:email]
      customer.license = license
      #Creating SetCustomerDetails object and making the call.
      @lclient.setCustomerDetails(SetCustomerDetails.new(customer))
    end

    def set_customer_details_for_trial(customer, values, new_customer_flag)
      customer_details = CustomerDetails.new
      customer_details.site_use_id = ''
      customer_details.site_type  = 'BILL_TO'
      customer_details.first_name = values[:first_name]
      customer_details.last_name = values[:last_name]
      customer_details.email = values[:email]
      if new_customer_flag
        customer_number = values[:guid]
      else
        customer_number = customer.customer_number
      end
      site = Site.find_by_code(values[:site_code])
      
      prguid = PrguidType.new()
      values[:pr_guids].each do |pr_guid|
        prguid << pr_guid.guid
      end

      license_details = LicenseDetails.new
      license_details.prGUIDRec = prguid
      license_details.language = values[:language]
      license_details.trialFlag = "Y"
      license_details.autoRenewalFlag = "N"
      if site.code == "JP_WEBSITE"
        license_details.trialStartDate = DateTime.now.in_time_zone('Tokyo').strftime("%m/%d/%Y %H:%M:%S")
        end_date = DateTime.now.in_time_zone('Tokyo') + values[:duration].days
      elsif site.code == "KR_WEBSITE"
        license_details.trialStartDate = DateTime.now.in_time_zone('Seoul').strftime("%m/%d/%Y %H:%M:%S")
        end_date = DateTime.now.in_time_zone('Seoul') + values[:duration].days
      elsif site.code == "UK_WEBSITE"
        license_details.trialStartDate = DateTime.now.in_time_zone('London').strftime("%m/%d/%Y %H:%M:%S")
        end_date = DateTime.now.in_time_zone('London') + values[:duration].days
      elsif site.code == "DE_WEBSITE"
        license_details.trialStartDate = DateTime.now.in_time_zone('Berlin').strftime("%m/%d/%Y %H:%M:%S")
        end_date = DateTime.now.in_time_zone('Berlin') + values[:duration].days
      else
        license_details.trialStartDate = Time.now.utc.strftime("%m/%d/%Y %H:%M:%S")
        end_date = Time.now.utc + values[:duration].days
      end
      license_details.currency = site.currency.code
      #end_date = Time.now.utc + values[:duration].days
      license_details.trialEndDate = end_date.strftime("%m/%d/%Y %H:%M:%S")
      license = License.new
      license.licenseGUID = values[:guid]
      license.licenseDetails = license_details

      customer = Customer.new
      customer.customer_number = customer_number
      customer.customer_flag = "Y"
      customer.learner_flag = "Y"
      customer.org_id = site.organization_id
      customer.first_name = values[:first_name]
      customer.last_name = values[:last_name]
      customer.email = values[:email]
      customer.customerDetails = customer_details
      customer.license = license
      @lclient.setCustomerDetails(SetCustomerDetails.new(customer))

    end

    def set_customer_details(order, new_customer_flag, is_myaccount_order,child_email = nil)
      logger.info "********* inside set_customer_details order: #{order.inspect}, new_customer_flag: #{new_customer_flag.inspect}, is_myaccount_order: #{is_myaccount_order.inspect}*********"
      customer_details = []
      is_customer_only = (!is_myaccount_order && !order.customer.guid) || (is_myaccount_order && order.customer.guid != order.master_guid && !child_email)
      is_customer_and_learner = (!is_myaccount_order && !order.customer.guid.nil?) || (is_myaccount_order && order.customer.guid == order.master_guid)
      is_learner_only = is_myaccount_order && order.customer.guid != order.master_guid && !child_email.nil?
      if is_customer_only || is_customer_and_learner
      [:bill_address, :ship_address].each do |address_type|
        next if order.send(address_type).nil?
        customer_detail = CustomerDetails.new
        customer_detail.site_use_id = ''
        if address_type == "ship_address".to_sym
          customer_detail.site_type  = 'SHIP_TO'
        else
          customer_detail.site_type  = 'BILL_TO'
        end
        
        if order.send(address_type).country.code == "JP"
          customer_detail.phonetic_first_name = order.send(address_type).first_name_phonetic
          customer_detail.phonetic_last_name = order.send(address_type).last_name_phonetic
        end
        customer_detail.first_name = order.send(address_type).first_name
        customer_detail.country = order.send(address_type).country.code
        customer_detail.last_name = order.send(address_type).last_name
        customer_detail.address1 = order.send(address_type).address1
        customer_detail.address2 = order.send(address_type).address2
        customer_detail.city = order.send(address_type).city
        customer_detail.state_province = order.send(address_type).state || order.send(address_type).province
        customer_detail.zip = order.send(address_type).postal_code
        customer_detail.phone = order.send(address_type).phone_number || order.customer.phone_number
        customer_detail.email = order.customer.email

        customer_details << customer_detail
      end
      end

      customer_number = (is_learner_only ||  is_customer_and_learner) ? order.customer.guid : order.master_guid
      unless is_customer_only
        license_details = []
        license = License.new
        license.licenseGUID = order.customer.guid
        license.masterFlag = 'Y' if order.master_guid && order.master_guid == license.licenseGUID
        renewal_info = Hash.new
         prguid = PrguidType.new() 
        order.lines.each do | line |
           unless line.eschool_one_on_one_sessions_guid!=nil && order.lines.count >1 && order.lines.map(&:language).uniq.count==1 && order.form_where_entered!="CALL"
          prguid = PrguidType.new()
           end
          Families.collect do |family|
            guid = line.send("#{family}_guid")
            prguid.push(guid) if guid
          end

          unless prguid.blank?
              unless renewal_info[line.language] && renewal_info[line.language]['renewal_flag'] == "Y"
                renewal_flag, renewal_price, renewal_term = determine_renewal_status(order, line, license.licenseGUID, prguid.first)
                puts "renewal info : #{renewal_flag}, renewal_price : #{renewal_price}, renewal_term : #{renewal_term} "
                renewal_info[line.language] = {"renewal_flag" => renewal_flag, "renewal_price" => renewal_price, "renewal_term" => renewal_term}
              end
              unless line.eschool_one_on_one_sessions_guid!=nil && order.lines.count > 1 && order.lines.map(&:language).uniq.count==1 && order.form_where_entered!="CALL"
              license_detail = LicenseDetails.new
              puts "prguid - #{prguid}"
              license_detail.prGUIDRec = prguid
              license_detail.language = line.language
              license_detail.item = Item.find(line.item_id).sku if line.eschool_one_on_one_sessions_guid.nil?
              #license_detail.item = line.item_id if line.eschool_one_on_one_sessions_guid.nil?
              if renewal_info[line.language]
                license_detail.autoRenewalFlag = renewal_info[line.language]["renewal_flag"]
                license_detail.renewalPrice = renewal_info[line.language]["renewal_price"]
                license_detail.renewalTerm = renewal_info[line.language]["renewal_term"]
              end
              get_license_details = get_customer_details(order.customer.email,line.language)
              if !get_license_details.nil? && !get_license_details.v_return.nil? && !get_license_details.v_return.customer.nil? && !get_license_details.v_return.customer.license.nil? && !get_license_details.v_return.customer.license.first.nil? && !get_license_details.v_return.customer.license.first.licenseDetails.nil? && !get_license_details.v_return.customer.license.first.licenseDetails.first.nil?
                get_cust_det = get_license_details.v_return.customer.license.first.licenseDetails.detect { |ld| ld.language == line.language}
                if !get_cust_det.nil? && !get_cust_det.trialFlag.nil? && get_cust_det.trialFlag == "Y"
                  license_detail.trialFlag = "N"
                end
              end
              license_detail.currency = order.currency.code
              puts "curreny - #{license_detail.currency}"
              if order.organization_id == 2885
                license_detail.vendor = "kcp"
              elsif order.payment_type == "p"  
                #if line.auto_renew==1
                license_detail.vendor = "pap"
                license_detail.processingId = order.billing_agreement_id
                #else 
                # logger.info "not updating pap"
                #end
              else
                license_detail.vendor = "glc" #if order.save_credit_card!=0
              end
              end
              license_details << license_detail
          end
        end
        license.licenseDetails = license_details
      end
      customer = Customer.new
      customer.customer_number = customer_number.nil? ? -1 : customer_number
      customer.customer_flag = is_learner_only ? 'N' : 'Y' 
      customer.license = license unless is_customer_only 
      customer.learner_flag = order.customer.guid ? 'Y' : 'N'
      customer.org_id = order.organization_id
      customer.first_name = order.customer.first_name
      customer.last_name = order.customer.last_name
      customer.email = child_email || order.customer.email
      unless is_learner_only
        customer.sold_to_org_id = order.sold_to_org_id
        customer.orig_sys_document_ref = order.orig_sys_document_ref
        customer.customerDetails = customer_details
      end
      @lclient.setCustomerDetails(SetCustomerDetails.new(customer))
    end

   def set_license_for_customer(customer, values)
     license = License.new
     license.licenseGUID = values["license_guid"]
     license.masterFlag = values["master_flag"] if !values["master_flag"].nil?
     license_detail = LicenseDetails.new
     license_detail.language = values["language"] 
     license_detail.prGUIDRec = values["pr_guids"]
     license_detail.autoRenewalFlag = values["renewal_flag"]
     license_detail.renewalPrice = values["renewal_price"]
     license_detail.vendor = "glc"
     license_detail.bankAcctusesId = values["bank_acct_uses_id"]
     license_detail.currency = values["currency"]
     license_detail.trialFlag = values["trial_flag"] if !values["trial_flag"].nil?
     license.licenseDetails << license_detail
     if customer.license.nil?
       customer.license = [license]
     else
       customer.license << license
     end
     customer.org_id = values["org_id"]
     customer.masterGuid = values["master_guid"]
     @lclient.setCustomerDetails(SetCustomerDetails.new(customer))
   end
  
  def set_customer_for_renewal(values)
    customer  = Customer.new
    customer.email = values["email"] 
    customer.customer_flag = "N"
    customer.learner_flag = "Y"
    customer.org_id = values["org_id"]
    customer.customer_number = values["license_guid"]
    customer.sold_to_org_id = -1
    set_license_for_customer(customer, values)
  end

  def set_license_details_for_customer(customer, values)
    license_detail = LicenseDetails.new
    license_detail.language = values["language"]
    license_detail.prGUIDRec = values["pr_guids"]
    license_detail.autoRenewalFlag = values["renewal_flag"]
    license_detail.renewalPrice = values["renewal_price"]
    license_detail.vendor = "glc"
    license_detail.currency = values["currency"]
    license_detail.bankAcctusesId = values["bank_acct_uses_id"]
    customer.license.detect { |l| l.licenseGUID == values["license_guid"]}.licenseDetails << license_detail
    customer.org_id = values["org_id"]
    @lclient.setCustomerDetails(SetCustomerDetails.new(customer))
  end

  def create_billing_profile(values)
    payment = PaymentDetails.new
    if values["payment_details"]
      payment_info = values["payment_details"]
      payment.creditCardNum = payment_info["number"]
      payment.expirationDate = payment_info["expiration_month"] + "/" + payment_info["expiration_year"]
      payment.currency = values["currency"]
      payment.cardHolderName = payment_info["holder_name"]
    end
    customer = Customer.new
    customer.customer_number = values["license_guid"]
    customer.customer_flag = "Y"
    customer.learner_flag = "Y" #He comes from myaccount, so yeah. he is a learner
    customer.sold_to_org_id = -1
    customer.org_id = values["org_id"]
    if values["bill_address_contact"]
      customer.first_name = values["bill_address_contact"]["firstName"]
      customer.last_name = values["bill_address_contact"]["lastName"]
      customer.email = values["login"]["email"] if values["login"]
    end

     customer_details = []
     keys = ["bill_address"]
     keys << "ship_address" if values.has_key?("ship_address")
     keys.each do |address_type|
       customer_detail = CustomerDetails.new
       customer_detail.site_use_id = ''
       if address_type == "ship_address"
         customer_detail.site_type  = 'SHIP_TO'
       else
         customer_detail.site_type  = 'BILL_TO'
       end

       #Take bill address data and send to ship address if they are all the same.
       address_type = "bill_address" if values["ship_same_as_bill"] == "1"

       customer_detail.first_name = values["#{address_type}_contact"]["firstName"]
       customer_detail.last_name = values["#{address_type}_contact"]["lastName"]
       customer_detail.phonetic_first_name = values["#{address_type}_contact"]["phoneticFirstName"]
       customer_detail.phonetic_last_name = values["#{address_type}_contact"]["phoneticLastName"]
       customer_detail.phone = values["#{address_type}_contact"]["phoneNumber"]
       customer_detail.country = values[address_type]["country"]
       customer_detail.address1 = values[address_type]["address1"]
       customer_detail.address2 = values[address_type]["address2"]
       customer_detail.city = values[address_type]["city"]
       customer_detail.state_province = values[address_type]["state"] || values[address_type]["province"]
       customer_detail.zip = values[address_type]["zip"] 
       customer_detail.email = values["login"]["email"] if values["login"]

       customer_details << customer_detail
     end

     customer.customerDetails = customer_details
     license = License.new 
     license.licenseGUID = values["license_guid"] 
     license.masterFlag = 'Y' 
     license_detail = LicenseDetails.new 
     license_detail.prGUIDRec = values["pr_guids"] 
     license_detail.language = values["language"] 
     if values["auto_renewal_flag"].nil? || values["auto_renewal_flag"] == ""
       license_detail.autoRenewalFlag = 'N' 
     else
       license_detail.autoRenewalFlag = values["auto_renewal_flag"]
     end
     license_detail.currency = values["currency"]                    
     license.licenseDetails = license_detail 
     license.rsPan=values["rsPan"]
     customer.license = license 

     resp = @lclient.createBillingProfile(CreateBillingProfile.new(customer,payment))

  end 
    
    # SYNOPSIS
    #   switchLanguage(param, token)
    #
    # ARGS
    #   param           SwitchLanguage - {http://domain.rst1.com/services/business/lcd}switchLanguage
    #   token           C_String - {http://www.w3.org/2001/XMLSchema}string
    #
    # RETURNS
    #   result          SwitchLanguageResponse - {http://domain.rst1.com/services/business/lcd}switchLanguageResponse
    #
    def switch_language(prGuid, language)
        @lclient.switchLanguage(SwitchLanguage.new(prGuid, language))
    end
    
    # SYNOPSIS
    #   setCustomerNumber(parameters, token)
    #
    # ARGS
    #   parameters      SetCustomerNumber - {http://lcdb_services/}setCustomerNumber
    #   token           C_String - {http://www.w3.org/2001/XMLSchema}string
    #
    # RETURNS
    #   result          SetCustomerNumberResponse - {http://lcdb_services/}setCustomerNumberResponse
    #
    #parameters = token = nil
    #puts obj.setCustomerNumber(parameters, token)

    # SYNOPSIS
    #   getCustomerDetails(parameters)
    #
    # ARGS
    #   parameters      GetCustomerDetails - {http://lcdb_services/}getCustomerDetails
    #
    # RETURNS
    #   parameters      GetCustomerDetailsResponse - {http://lcdb_services/}getCustomerDetailsResponse
    #


    def get_customer_details(email, license_guid = nil, language = 'ALL')
      rec = GetCustomerDetails.new(GetCustomerDetailsRequestType.new(email, license_guid, language))
      @lclient.getCustomerDetails(rec)
    end

    # SYNOPSIS
    #   getRenewal(parameters)
    #
    # ARGS
    #   parameters      GetRenewal - {http://lcdb_services/}getRenewal
    #
    # RETURNS
    #   parameters      GetRenewalResponse - {http://lcdb_services/}getRenewalResponse
    #
    def get_renewal(license_guid, language, pr_guid)
      @lclient.getRenewal(GetRenewal.new(GetRenewalRequestType.new(license_guid, language, pr_guid)))
    end

    # SYNOPSIS
    #   setRenewal(parameters)
    #
    # ARGS
    #   parameters      SetRenewal - {http://lcdb_services/}setRenewal
    #
    # RETURNS
    #   parameters      SetRenewalResponse - {http://lcdb_services/}setRenewalResponse
    #
    def set_renewal(values)
      @lclient.setRenewal(SetRenewal.new(
                            SetRenewalRequestType.new(values["license_guid"], values["language"], values["pr_guid"], values["source"], values["auto_renewal_flag"], values["renewal_price"], values["renewal_term"], values["bank_acct_uses_id"], values["rspan"], values["processingId"], values["vendor"], values["item"], values["currency"])))
    end

    # SYNOPSIS
    #   setOrder(parameters)
    #
    # ARGS
    #   parameters      SetOrder - {http://lcdb_services/}setOrder
    #
    # RETURNS
    #   parameters      SetOrderResponse - {http://lcdb_services/}setOrderResponse
    #
    #parameters = nil
    #puts obj.setOrder(parameters)


    def set_order(order,new_customer_flag = true)
      line = order.lines.first
      order_items = []
      order.lines.each do |line|
        order_item = OrderItems.new
        order_item.order_line_id = line.id
        order_item.item = line.item.id
        order_item.language = line.language
        order_item.line_status = ''
        order_items <<  order_item
      end
      if new_customer_flag
        customer_number = order.master_guid || order.customer.guid
      else
        customer_number = order.customer_number 
      end
      if (order.site && order.site.code.include?('CALL'))
        sales_channel_code = case order.site.code
          when 'HS_US_CALL_CENTER'
            'OTHER'
          when 'HS_RESELLER_CALL_CENTER'
            'RESELLER'
          else
            'CALL CENTER'
          end
      elsif order.ebay?
        sales_channel_code = 'EBAY'
      elsif order.site.myaccount?
        sales_channel_code = 'MYACCOUNT'
      elsif (order.customer.generic_lead_code=="Facebook")
        sales_channel_code = 'FACEBOOK'
      else
        sales_channel_code = 'WEB'
      end
      order_obj = Order.new
      order_obj.order_number = order.order_number.to_s
      order_obj.licenseGuid = order.customer.guid
      order_obj.email = order.customer.email
      order_obj.orig_sys_document_ref = order.orig_sys_document_ref
      order_obj.ordered_date = order.ordered_date.utc.strftime("%m/%d/%Y %H:%M:%S")
      order_obj.due_date = order.ordered_date.utc.strftime("%m/%d/%Y %H:%M:%S")
      order_obj.sales_channel = sales_channel_code
      order_obj.order_total = order.total.to_f
      order_obj.payment_type = order.payment_type
      order_obj.org = order.organization_id
      order_obj.orderItems = order_items
      order_obj.captureStatus = 'Y'
      @lclient.setOrder(SetOrder.new(order_obj))
    end
  
  # SYNOPSIS
  #   getOrder(parameters, token)
  #
  # ARGS
  #   parameters      GetOrder - {http://lcdb_services/}getOrder
  #   token           C_String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   result          GetOrderResponse - {http://lcdb_services/}getOrderResponse
  #
  def get_order(license_guid, past_due_only)
    @lclient.getOrder(GetOrder.new(GetOrderDetailsRequestType.new(license_guid, past_due_only)))
  end

  def check_trial(email, language)
    record = GetCheckTrialRequestType.new
    record.email = email
    record.language = language
    @lclient.checkTrial(CheckTrial.new(record))
  end

  # SYNOPSIS
  #   getPaymentDetail(getPaymentDetail)
  #
  # ARGS
  #   getPaymentDetail PaymentDetail - {http://domain.rst1.com/Paymentdetail}PaymentDetail
  #
  # RETURNS
  #   getPaymentDeatilResponse PaymentDetail - {http://domain.rst1.com/Paymentdetail}PaymentDetail
  #
  # RAISES
  #   messageServiceFault FaultResponse - {http://domain.rst1.com/Faults}FaultResponse
  #
  def get_payment_details(customer_id, currency, org_id)
    payment_detail = PaymentDetail.new
    payment_detail.customerId = customer_id
    payment_detail.currency = currency
    payment_detail.orgId = org_id
    #@pclient.getPaymentDetail(payment_detail)
    payment_detail
  end

  # SYNOPSIS
  #   setPaymentDetail(setPaymentDetail)
  #
  # ARGS
  #   setPaymentDetail PaymentDetail - {http://domain.rst1.com/Paymentdetail}PaymentDetail
  #
  # RETURNS
  #   setPaymentDetailResponse Long - {http://www.w3.org/2001/XMLSchema}long
  #
  # RAISES
  #   messageServiceFault FaultResponse - {http://domain.rst1.com/Faults}FaultResponse
  #
  def set_payment_details(values)
    bill_address = values["bill_address"]
    contact_info = values["bill_address_contact"]

    address = Address.new
    if bill_address
      address.adrLine1 = bill_address["address1"]
      address.adrLine2 = bill_address["address2"]
      address.postalCode = bill_address["zip"]
      address.city = bill_address["city"]
      address.country = bill_address["country"]
      address.state = bill_address["state"]
    end

    address.timeZone = values["time_zone"]
    address.xmlattr_adroid = values["site_use_id"]
    
    address.phone = contact_info["phoneNumber"] if contact_info

    person = Person.new
    if contact_info
      person.firstName = contact_info["firstName"]
      person.lastName = contact_info["lastName"]
    end
    
    payment_info = values["payment_details"]

    payment_detail = PaymentDetail.new
    payment_detail.xmlattr_paymentId = values["payment_id"] if values["payment_id"]
    payment_detail.licenseGUID = values["license_guid"] 
    payment_detail.customerId = values["customer_id"]
    payment_detail.currency = values["currency"]
    payment_detail.orgId = values["org_id"]
    payment_detail.paymentAddress = address
    payment_detail.billName = person
    payment_detail.primaryFlag = "Y"
    if payment_info
      payment_detail.acctNum = payment_info["number"]
      payment_detail.acctName = payment_info["holder_name"]
      payment_detail.expireDate = payment_info["expiration_month"] + "/" + payment_info["expiration_year"]
    end

    @pclient.setPaymentDetail(payment_detail)
  end
  
  # SYNOPSIS
  #   getMarketValue(param, token)
  #
  # ARGS
  #   param           GetMarketValue - {http://domain.rst1.com/services/business/lcd}getMarketValue
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          GetMarketValueResponse - {http://domain.rst1.com/services/business/lcd}getMarketValueResponse
  #
  def find_markets(activation_ids)
    @lclient.getMarketValue(GetMarketValue.new(activation_ids))
  end

  
  # SYNOPSIS
  #   pingLCDBServices(parameters, token)
  #
  # ARGS
  #   parameters      PingLCDBServices - {http://lcdb_services/}pingLCDBServices
  #   token           C_String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   result          PingLCDBServicesResponse - {http://lcdb_services/}pingLCDBServicesResponse
  #
  #
  #parameters = token = nil
  #puts obj.pingLCDBServices(parameters, token)


  # SYNOPSIS
  #   udpateLicense(parameters, token)
  #
  #
  # ARGS
  # parameters      UdpateLicense - {http://lcdb_services/}udpateLicense
  # token           C_String - {http://www.w3.org/2001/XMLSchema}string
  # RETURNS
  # result          UdpateLicenseResponse - {http://lcdb_services/}udpateLicenseResponse
  #
  #parameters = token = nil
  #puts obj.udpateLicense(parameters, token)
  
  # SYNOPSIS
  #   getPastDuePayments(param, token)
  #
  # ARGS
  #   param           GetPastDuePayments - {http://domain.rst1.com/services/business/lcd}getPastDuePayments
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          GetPastDuePaymentsResponse - {http://domain.rst1.com/services/business/lcd}getPastDuePaymentsResponse
  #
  #param = token = nil
  #puts obj.getPastDuePayments(param, token)

  # SYNOPSIS
  #   setPrGuid(param, token)
  #
  # ARGS
  #   param           SetPrGuid - {http://domain.rst1.com/services/business/lcd}setPrGuid
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          SetPrGuidResponse - {http://domain.rst1.com/services/business/lcd}setPrGuidResponse
  #
  #params = token = nil
  #puts obj.setPrGuid(param, token)
 
  def notify_claim(activation_id, rights)
    productRights = []
    rights.each do | right |
      prDetail = PrDetails.new
      prDetail.family = right['family']
      prDetail.extRefId = right['reference']
      prDetail.productRight = right['guid']
      productRights.push(prDetail)
    end
    logger.info "inside lcdb_client.rb inspecting SetProductRights #{productRights.inspect} === inspecting activation id #{activation_id.inspect}"
    @lclient.setProductRights(SetProductRights.new(activation_id, productRights))
  end
  # SYNOPSIS
  #   switchAccount(param, token)
  #
  # ARGS
  #   param           SwitchAccount - {http://domain.rst1.com/services/business/lcd}switchAccount
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          SwitchAccountResponse - {http://domain.rst1.com/services/business/lcd}switchAccountResponse
  #
  def switch_account(values)
    request_obj = SwitchAccountRequestType.new
    request_obj.licenseGuid = values["license_guid"]
    request_obj.orgId = values["org_id"]
    request_obj.customerId = values["customer_id"]
    request_obj.currency = values["currency"]
    request_obj.billTo = CustomerDetails.new
    request_obj.shipTo = CustomerDetails.new
    @lclient.switchAccount(SwitchAccount.new(request_obj))
  end
  # SYNOPSIS
  #   updateLicense(param, token)
  #
  # ARGS
  #   param           UpdateLicense - {http://domain.rst1.com/services/business/lcd}updateLicense
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          UpdateLicenseResponse - {http://domain.rst1.com/services/business/lcd}updateLicenseResponse
  #
  #param = token = nil
  #puts obj.updateLicense(param, token)

  # SYNOPSIS
  #   updateOrderPayStatus(param, token)
  #
  # ARGS
  #   param           UpdateOrderPayStatus - {http://domain.rst1.com/services/business/lcd}updateOrderPayStatus
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          UpdateOrderPayStatusResponse - {http://domain.rst1.com/services/business/lcd}updateOrderPayStatusResponse
  #
  #param = token = nil
  #puts obj.updateOrderPayStatus(param, token)

  # SYNOPSIS
  #   updatePersonDetails(param, token)
  #
  # ARGS
  #   param           UpdatePersonDetails - {http://domain.rst1.com/services/business/lcd}updatePersonDetails
  #   token           Token - {http://domain.rst1.com/services/business/lcd}token
  #
  # RETURNS
  #   result          UpdatePersonDetailsResponse - {http://domain.rst1.com/services/business/lcd}updatePersonDetailsResponse
  #
  def update_address(values)
    customer_details = CustomerDetails.new
    #ustomer_details.site_use_id = values['site_use_id']
    #ustomer_details.site_type  = 'BILL_TO'

    #This method is to update shipping address. But if bill is same as ship, 
    #we need take the billing address to update shipping address 
#   address_type = if values["ship_same_as_bill"] == "1"
 #                   "bill_address"
  #                else
   #                  "ship_address"
    #               end
    if values["ship_same_as_bill"] == "1"
      address_type="bill_address"
    else
      address_type="ship_address"
    end
      if values["#{address_type}_contact"]
        customer_details.site_use_id = values['ship_to_site_use_id']
        customer_details.site_type  = 'SHIP_TO'
        customer_details.first_name = values["#{address_type}_contact"]['firstName']
        customer_details.last_name = values["#{address_type}_contact"]['lastName']
        customer_details.zip = values['postal_code']
        customer_details.phone = values["#{address_type}_contact"]['phoneNumber']
        customer_details.email = values["login"]['email'] if values["login"]
      end

      if values[address_type]
        customer_details.address1 = values[address_type]["address1"]
        customer_details.address2 = values[address_type]["address2"]
        customer_details.city = values[address_type]['city']
        customer_details.zip = values[address_type]['zip']
        customer_details.state_province = values[address_type]['state'] || values[address_type]['province']
        customer_details.country = values[address_type]['country']
      end
      @lclient.updatePersonDetails(UpdatePersonDetails.new(UpdatePersonDetailRequest.new(values["license_guid"], customer_details)))
    #end

    address_type="bill_address"
    if values["#{address_type}_contact"]
      customer_details.site_use_id = values['site_use_id']
      customer_details.site_type  = 'BILL_TO'
      customer_details.first_name = values["#{address_type}_contact"]['firstName']
      customer_details.last_name = values["#{address_type}_contact"]['lastName']
      customer_details.zip = values['postal_code']
      customer_details.phone = values["#{address_type}_contact"]['phoneNumber']
      customer_details.email = values["login"]['email'] if values["login"]
    end

    if values[address_type]
      customer_details.address1 = values[address_type]["address1"]
      customer_details.address2 = values[address_type]["address2"]
      customer_details.city = values[address_type]['city']
      customer_details.zip = values[address_type]['zip']
      customer_details.state_province = values[address_type]['state'] || values[address_type]['province']
      customer_details.country = values[address_type]['country']
    end
    @lclient.updatePersonDetails(UpdatePersonDetails.new(UpdatePersonDetailRequest.new(values["license_guid"], customer_details)))

  end

  def auth_credit_card(order,payment_details,ip)
    request = AuthCreditCardRequestType.new
    bill_address = order.bill_address
    request.customerip = ip
    request.postalCode = bill_address.postal_code
    request.state = bill_address.state || bill_address.province
    request.city = bill_address.city
    request.cnty = bill_address.county
    request.address1 = bill_address.address1
    request.address3 = bill_address.address2
    request.address3 = bill_address.address3
    request.country = bill_address.country.code

    ship_address = order.ship_address
    if ship_address
      request.shipPostalcode = ship_address.postal_code
      request.shipCity = ship_address.city
      request.shipState = ship_address.state || ship_address.province
      request.shipCuontry = ship_address.country.code
      request.shipAddr = ship_address.address1
    end

    request.currencyCode = order.currency.code
    request.customerip = ip
    request.cvv = payment_details.cvv
    request.bankAcctUseId = payment_details.bank_acct_useid
    request.expireDate = payment_details.expiry_date
    request.amount = order.total.units.round(2, BigDecimal::ROUND_HALF_UP).to_s
    request.orgId = order.organization_id
    request.customerId = payment_details.customer_id
    @pclient.authCreditCard(AuthCreditCard.new(request))
  end
  
  def set_rspan_for_customer(customer,rsPan)
    customer.license.first.rsPan = rsPan
    @lclient.setCustomerDetails(SetCustomerDetails.new(customer))
  end
   private
    def determine_renewal_status(order, line, license_guid, prguid)
      renewal_flag = 'N'
      renewal_price = 0.0
      renewal_term = 'N'
      if line.auto_renew == 1
        renewal_flag = 'Y'
        renewal_price = line.item.monthly_renewal_price(order).to_f.round
        if order.site.code == "MYACCOUNT_US"
          renewal_price = 0.0
          renewal_term = 'Y'
        end
      elsif ["TO","TSPK"].include?(line.item.product_type)
        renewal_resp = get_renewal(license_guid, line.language, nil).v_return
        if renewal_resp.returnCode.to_i == 1 && !renewal_resp.licenseDetails.nil?
          renewal_flag = renewal_resp.licenseDetails.first.autoRenewalFlag
          renewal_price = renewal_resp.licenseDetails.first.renewalPrice
          renewal_term = renewal_resp.licenseDetails.first.renewalTerm
        end
      end
      [renewal_flag, renewal_price, renewal_term]
    end

  
  end
end

