# == Schema Information
#
# Table name: products
#
#  id                 :integer(4)      not null, primary key
#  identifier         :string(255)     not null
#  version            :string(64)      not null
#  family             :string(255)     not null
#  min_available_unit :integer(4)      not null
#  max_available_unit :integer(4)      not null
#

module LicenseServer
  class Product < LicenseServer::LicenseServerConnection

    VALID_FAMILIES = %w(application eschool premium_community)
    DEFAULT_FAMILY = 'application'

    has_many :product_rights

    def is_for_the_app?
      family == DEFAULT_FAMILY
    end

  end
end
