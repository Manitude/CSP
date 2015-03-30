# == Schema Information
#
# Table name: licenses
#
#  id                  :integer(4)      not null, primary key
#  identifier          :string(255)     not null
#  hashed_password     :string(255)     
#  salt                :string(255)     
#  creation_account_id :integer(4)      default(0), not null
#  active              :boolean(1)      default(TRUE)
#  created_at          :datetime        
#  updated_at          :datetime        
#  test                :boolean(1)      
#  guid                :string(255)     not null
#

module LicenseServer
	class License < LicenseServer::LicenseServerConnection

    has_many :product_rights, :dependent => :destroy, :include => :product
    has_many :products, :through => :product_rights

    module UsableProductRight
      def for(language_unit_chapter, app_version)
          detect {|product_right| product_right.product.version == app_version.to_s && product_right.allows_access_to_language_unit_chapter?(language_unit_chapter)}
        end

        def count
          size
        end

        def owner=(owner)
          @owner = owner
        end
      end

      def usable_products
        usable_product_rights.collect(&:product)
      end

      def usable_product_rights(application_only = false)
        # It seems we're always returning an empty Array for usable product rights when the License is not active.
        prs = (active?) ? product_rights.select(&:usable?) : []
        prs = prs.select(&:is_for_the_app?) if application_only
        returning(prs.extend(UsableProductRight)) do |pr_collection|
          pr_collection.owner = self
        end
      end

      def usable?
        active? && has_usable_products?
      end

      def has_usable_products?
        !usable_products.empty?
      end

    end
  end
