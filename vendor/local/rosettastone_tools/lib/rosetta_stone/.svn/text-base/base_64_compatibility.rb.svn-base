# -*- encoding : utf-8 -*-
# blarg.  Rails versions 2.0.4 and up might not have ::Base64 but will have
# ActiveSupport::Base64 defined.  Rails 2.0.2 and down had ::Base64 but not
# ActiveSupport::Base64.  There are also Ruby version complications...
# Note: we can remove this once Viper is off 1.2.6
unless defined? ActiveSupport::Base64
  module ActiveSupport
    Base64 = ::Base64
  end
end
