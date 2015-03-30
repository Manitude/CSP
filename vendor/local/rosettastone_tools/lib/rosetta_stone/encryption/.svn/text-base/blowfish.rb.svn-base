# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.
require 'openssl'

# This class implements Blowfish symmetric key encryption & decryption.
module RosettaStone
  module Encryption
    module Blowfish
      class << self
        def encrypt(message, key)
          Helper.hexify(cipher(:encrypt, message.to_s, key))
        end

        def decrypt(message, key)
          cipher(:decrypt, Helper.dehexify(message.to_s), key)
        end

      private

        def cipher(mode, message, key)
          cipher = OpenSSL::Cipher::Cipher.new('bf-cbc').send(mode)
          cipher.key = Digest::SHA256.digest(key)
          cipher.update(message) << cipher.final
        end
      end
    end
  end
end
