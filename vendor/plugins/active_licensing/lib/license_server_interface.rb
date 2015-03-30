# -*- encoding : utf-8 -*-
# deprecated. only used in ec_admin?
# FIXME: Remove this class entirely? Based on some searching on 2008-12-11, this class is no longer used by ec_admin. JPM
#
class LicenseServerInterface
  attr_reader :license_server

  def initialize(opts={})
  end

  def license_exists?(license_name)
    license_server.license.exists(:license => license_name)
  end

  def authenticate(license_name, password)
    license_server.license.authenticate(:license => license_name, :password => password)
  end

  def product_rights(license_name)
    license_server.license.product_rights(:license => license_name) if license_exists?(license_name)
  end

  # basically a wrapper around create_osub, since it's not obvious that an empty array means "with no product rights"
  def create_osub_with_no_product_rights(license_name, license_password)
    create_osub(license_name, license_password, [])
  end

  # returns the license server response (an array of hashes) to the multicall including the add product rights
  # or it raises a RosettaStone::ActiveLicensing::LicenseServerException
  def create_osub(license_name, license_password, osub_items)
    # In multicall mode, the API calls to the LS are queued up and do not initially return a value. Thus, this call needs to
    # be made outside the multicall block to force the local variable to have a value in the block below.
    license_exists = license_exists?(license_name)

    license_server.multicall do
      if license_exists
        license.change_password(:license => license_name, :password => license_password)
      else
        license.add(:creation_account => "OSUBs", :license => license_name, :password => license_password)
      end

      osub_items.each do |osub|
        language_code, version, duration = osub.language_code, osub.app_version, osub.duration_code
        # API expects seconds since epoch in crazy Oracle Time
        ends_at = OracleMimicTime.now.add_months(duration.to_i).to_i
        if Time.now > Time.parse('2007-08-28 04:00:00')
          ends_at += 7.days
        end
        license.add_or_extend_product_right(:license => license_name, :product => language_code, :version => version, :ends_at => ends_at)
      end
    end
  end

  # Changes the password and returns true on success, or else raises a
  # RosettaStone::ActiveLicensing::LicenseServerException (or subclass
  # thereof)
  def reset_password(license_name, license_password)
    license_server.license.change_password(:license => license_name, :password => license_password)
  end

  # Base logging method for this interface.  Logs to the interface_logs table.
  def log(level, text, license, order_id, order_number)
    InterfaceLog.new(
                     'license'      => license,
                     'order_id'     => order_id,
                     'order_number' => order_number,
                     'interface'    => 'lsservlet',
                     'level'        => level,
                     'logtext'      => text
                     ).log
  end

  protected

  def license_server
    @license_server ||= RosettaStone::ActiveLicensing::Base.instance
  end

end
