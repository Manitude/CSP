# == Schema Information
#
# Table name: product_rights
#
#  id            :integer(4)      not null, primary key
#  license_id    :integer(4)      not null
#  product_id    :integer(4)      not null
#  ends_at       :datetime        
#  created_at    :datetime        
#  guid          :string(255)     
#  activation_id :string(255)     
#

module LicenseServer
  class ProductRight < LicenseServer::LicenseServerConnection

    belongs_to :product

    delegate :demo?, :to => :license
    delegate :identifier, :is_for_the_app?, :family, :to => :product

    def usable?; !expired?; end

    def expired?
      # Nil check is so this doesn't explode on new objects.
      !ends_at.nil? && ends_at.is_before?(Time.now)
    end

  end
end
