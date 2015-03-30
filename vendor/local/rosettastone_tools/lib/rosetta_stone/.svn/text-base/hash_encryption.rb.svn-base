# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.
#
# Intended to allow an arbitrary hash to be encrypted and URL-encoded into a
# URL-safe string to be URL-decoded and decrypted later.
module RosettaStone
  module HashEncryption
    DES_KEY = '9d5e3ecdeb4cdb7acfd63075ae046672'
    ENCODING_CLASS = Rails::VERSION::MAJOR >= 3 ? Base64 : ActiveSupport::Base64

    def self.encrypt(hash)
      unencrypted = hash.to_yaml
      cipher = OpenSSL::Cipher::DES.new
      cipher.encrypt
      cipher.key = DES_KEY
      cipher.iv = DES_KEY[0..7]
      result = cipher.update(unencrypted)
      result << cipher.final
      CGI.escape(ENCODING_CLASS.encode64(result).chomp)
    end

    def self.decrypt(string)
      cipher = OpenSSL::Cipher::DES.new
      cipher.decrypt
      cipher.key = DES_KEY
      cipher.iv = DES_KEY[0..7]
      result = cipher.update(ENCODING_CLASS.decode64(CGI.unescape(string)))
      result << cipher.final
      YAML::load(result)
    end
  end

  # Loading YAML that includes a Bignum is broken in certain builds of ruby 1.8.4 on OS X. Barf.
  module BignumExtension
    def self.included(klass)
      klass.send(:yaml_as, "tag:yaml.org,2002:int")
    end
  end
end

# this fix is for ruby 1.8.4 only, and 1.8.2 chokes on the send
if RUBY_VERSION == "1.8.4"
  Bignum.send(:include, RosettaStone::BignumExtension)
end
