require 'stringio'
require 'time'
require 'thread'
require 'lcdb_client'
module LCDBIface
  @client = ::LCDB::Client.new(LCDBConfig['claim'], LCDBConfig['lcdb'])
  class << self; attr_reader :client, :lock; end

  def lcdb_get_customer_details(email, license_guid)
    result = with_lcdb_client do | client |
      client.get_customer_details(email, license_guid)
    end
    result.v_return
  end

  def lcdb_switch_language(prGuid, language)
    result = with_lcdb_client do | client |
      client.switch_language(prGuid, language)
    end
    result.v_return
  end

  def lcdb_set_customer_details_from_claim_flow(claim_code_details)
    begin
      result = with_lcdb_client do | client |
        client.set_customer_details_from_claim_flow(claim_code_details)
      end
      result

    rescue Exception => ex
      logger.info "Exception while connecting to LCDB :: #{ex.backtrace}"
    end
  end


  def lcdb_set_renewal(license_guid, language, prGuids, auto_renewal_flag, renewal_price)
    result = with_lcdb_client do | client |
      client.set_renewal(license_guid, language, prGuids, auto_renewal_flag, renewal_price)
    end
    result.v_return
  end

  def lcdb_get_renewal(license_guid, language)
    result = with_lcdb_client do | client |
      client.get_renewal(license_guid, language)
    end
    result.v_return
  end


  def with_lcdb_client
    client = LCDBIface.client
    logger = StringIO.new
    resp = yield client
  rescue Exception => ex
    logger.rewind
    raise ex
  else
    logger.rewind
    resp
  end

end