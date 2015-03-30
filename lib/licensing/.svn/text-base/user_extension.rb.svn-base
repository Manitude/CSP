module Licensing
  module UserExtension
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def licensing_info_for_cold_start
        batch_size, batch = 2000, 0
        UserUpdateExecutionDetail.record_time(Learner::UPDATE_IDENTIFIER[:license]) do
          while true
            Rails.logger.info "Getting license information for #{(batch + 1).ordinalize} batch"
            learners = find(:all, :conditions => ["user_source_type != ?", "Ollc::Administrator"], :limit => batch_size, :offset => (batch * batch_size), :order => "id ASC")
            batch = batch + 1
            break if learners.empty?
          end #While ends
        end #UserUpdateExecutionDetail ends
      end

    end

    private
    def update_license_info_for_cold_start
      license = LicenseServer::License.find_by_identifier(license_identifier)
      license = LicenseServer::License.find_by_guid(guid) unless license

      return unless license

      active = license.active? rescue false #To check if a license exist and the license is active
      if active
        upr = license.usable_product_rights || [] rescue [] #usable_product_rights (To avoid name conflicts)
        if enterprise_user?
          self.enterprise_license_active = !upr.empty? #User has an active license with atleast a single usable product rights
        else
          self.rworld = community_user? && upr.empty? #User is an rworld user if he is from community has ZERO usable product rights

          upi = upr.map(&:identifier) #usable product identifier(To avoid name conflicts)

          is_totale_active = upi.any? { |identifier| has_totale_license_for_cold_start?(upr, identifier) }
          self.totale, self.totale_active = is_totale_active, is_totale_active

          is_osub_active = upi.any? { |identifier| !has_totale_license_for_cold_start?(upr, identifier) && has_osub_license_for_cold_start(upr, identifier)}
          self.osub, self.osub_active = is_osub_active, is_osub_active
        end
      else
        self.rworld = community_user?
      end

      #FIXME: remove the call to update_without_callbacks private method
      self.send(:update_without_callbacks) if changed?
    rescue
      return
    end

    def has_totale_license_for_cold_start?(upr, identifier)
      upr.collect { |pr| pr.identifier == identifier ? pr.family : nil }.include_all?(LicenseServer::Product::VALID_FAMILIES)
    end

    def has_osub_license_for_cold_start(upr, identifier)
      upr.collect { |pr| pr.identifier == identifier ? pr.family : nil }.include_all?(LicenseServer::Product::DEFAULT_FAMILY)
    end

  end
end

