# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.
require 'openssl'
require 'rosetta_stone/encryption/helper'

# This class implements RSA public/private key encryption & decryption.
#
# How to generate keys:
#    openssl genrsa -out sample_private_key.pem 2048
#    openssl rsa -in sample_private_key.pem -out sample_public_key.pem -outform PEM -pubout
#
module RosettaStone
  module Encryption
    module Rsa
      class << self
        def sign(message, key = nil)
          Helper.hexify(rsa_signer(key).private_encrypt(message.to_s))
        end

        def unsign(message, key = nil)
          rsa_unsigner(key).public_decrypt(Helper.dehexify(message.to_s))
        end

      private

        def rsa_signer(key = nil)
          key ||= Helper.private_key
          OpenSSL::PKey::RSA.new(key)
        end

        def rsa_unsigner(key = nil)
          key ||= Helper.public_key
          OpenSSL::PKey::RSA.new(key)
        end
      end
    end
  end
end
