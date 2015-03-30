module ActiveLicensing
  module ProductRights

    def self.included(base)

      base.extend ClassMethods

      attr_accessor :usable_product_rights, :all_product_rights, :license_details, :creation_account_details
      ########################
      # Licensing methods
      ########################

      # access using product_rights vendor/plugins/active_licensing/lib/base.rbfor instance-level caching; this method forces them to be loaded from the LS API
      def load_all_product_rights
        ls_api.license.product_rights(:guid => guid) #Ollc user are removed so removing used of license_identifier because
      rescue RosettaStone::ActiveLicensing::LicenseNotFound
        []
      rescue => e
        logger.info "Error occured while fetching product rights for guid:#{guid}"
      end

      # Returns a hash of License attributes
      def load_license_details
        @license_details ||= ls_api.license.details(:guid => guid) #Ollc user are removed so removing used of license_identifier because
      rescue RosettaStone::ActiveLicensing::LicenseNotFound, RosettaStone::ActiveLicensing::ConnectionException
        @license_details = {}
      end

      def load_license_creation_account_details(creation_account_identifier)
        @creation_acount_details ||= ls_api.creation_account.details(:creation_account => creation_account_identifier)
      rescue RosettaStone::ActiveLicensing::LicenseNotFound, RosettaStone::ActiveLicensing::ConnectionException
        @creation_acount_details = {}
      end

      def get_all_product_rights
        @all_product_rights ||= load_all_product_rights
      end

      def get_usable_product_rights
        @usable_product_rights ||=  get_all_product_rights.select{|pr| pr['usable']}
      end

      def get_unusable_product_rights
        get_all_product_rights.reject{|pr| pr['usable']}
      end

      def has_premium_community_access?(language = nil)
        if language
          @usable_product_rights.any? {|pr| pr['product_identifier'] == language.identifier && pr.is_premium_community? }
        else
          @usable_product_rights.any? { |pr| pr.is_premium_community? }
        end
      end

      def is_totale_user?(language = nil)
        get_usable_product_rights
        if language
          has_totale_license?(language.identifier)
        else
          usable_product_identifiers.any? { |pi| has_totale_license?(pi) }
        end
      end

      #retuns an array of various product identifiers for which the product rights are usable
      def usable_product_identifiers
        get_usable_product_rights.collect { |upr| upr['product_identifier'] }.uniq
      end

      def unusable_product_identifiers
        get_unusable_product_rights.collect { |upr| upr['product_identifier'] }.uniq
      end


      def is_rworld_user?(language = nil)
        if language
          !get_usable_product_rights.any? { |pr| pr['product_identifier'] == language }
        else
          get_usable_product_rights.empty?
        end
      end

      def is_osub_user?(language = nil)
        get_usable_product_rights
        if language
          has_osub_license?(language.identifier)
        else
          usable_product_identifiers.any? { |pi| !has_totale_license?(pi) && has_osub_license?(pi) }
        end
      end

      def totale_languages
        usable_product_identifiers.select { |pi| has_totale_license?(pi) }
      end
      def all_user_product_rights
        get_all_product_rights.collect { |upr| upr['product_identifier'] }.uniq
      end

      def totale_languages_along_with_expired_lisences
       all_user_product_rights.select { |pi| has_totale_license_for_all?(pi) }
      end

      def has_totale_license_for_all?(language)
        all_product_rights.collect { |pr| pr['product_identifier'] == language ? pr['product_family'] : nil }.include_all?(%w(application eschool premium_community))
      end

      def rworld_languages
        unusable_product_identifiers.select { |pi| is_rworld_user?(pi) }
      end

      # Returns a hash of License identifier history
      def license_identifier_history
        @license_identifier_history ||= ls_api.license.previous_identifiers(:guid => guid) #Ollc user are removed so removing used of license_identifier because
      rescue => e # RosettaStone::ActiveLicensing::LicenseNotFound
        @license_identifier_history = {}
      end

      #License Methods
      def ls_api
        RosettaStone::ActiveLicensing::Base.instance
      end

      private
      #License Methods

      #Got to check if the user has 3 product rights [application, eschool, premium_community]
      # => uprs is short for usable_product_rights. Used to prevent the reload of product_rights from API
      def has_totale_license?(language)
        usable_product_rights.collect { |pr| pr['product_identifier'] == language ? pr['product_family'] : nil }.include_all?(%w(application eschool premium_community))
      end

      def has_osub_license?(language)
        has_application_license = usable_product_rights.collect { |pr| pr['product_identifier'] == language ? pr['product_family'] : nil }.include_all?(%w(application))
        has_lotus_license = usable_product_rights.collect { |pr| pr['product_identifier'] == language ? pr['product_family'] : nil }.include_all?(%w(lotus))
        has_application_license || has_lotus_license
      end

    end

    module ClassMethods
      def guids_for_recently_updated_licenses(opts = {})
        opts.reverse_merge!({:untill => Time.now.utc})
        new.ls_api.license.recently_updated_guids(opts)[:guids]
      end

      def guids_for_recently_updated_identifiers(opts = {})
        opts.reverse_merge!({:untill => Time.now.utc})
        new.ls_api.license.guids_for_recently_updated_identifiers(opts)[:guids]
      end
    end
  end

end
