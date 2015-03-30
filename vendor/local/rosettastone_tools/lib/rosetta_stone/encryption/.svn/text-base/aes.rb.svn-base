# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.
require 'openssl'

# This class implements AES symmetric key encryption & decryption.
# FIXME: It fails when that which you are trying to encrypt ends with null characters.
module RosettaStone
  module Encryption
    module Aes
      class << self
        def encrypt(message, key)
          Helper.hexify(aes_encrypter(message.to_s, key))
        end

        def decrypt(message, key)
          aes_decrypter(Helper.dehexify(message.to_s), key)
        end

      private

        def aes_encrypter(message, key)
          cipher = OpenSSL::Cipher::Cipher.new("aes-#{key.length * 8}-cbc")
          cipher.encrypt
          cipher.key = key
          cipher.padding = 0
          iv = cipher.iv = cipher.random_iv
          ciphertext = cipher.update(message)
          # Pad with nulls to make it the correct block size if necessary
          ciphertext << cipher.update("\000" * (cipher.block_size - (message.length % cipher.block_size))) if message.length % cipher.block_size > 0
          ciphertext << cipher.final
          iv + ciphertext
        end

        def aes_decrypter(message, key)
          raise ArgumentError, "Can't decrypt a blank message" if message.blank?
          cipher = OpenSSL::Cipher::Cipher.new("aes-#{key.length * 8}-cbc")
          cipher.decrypt
          cipher.key = key
          cipher.padding = 0
          cipher.iv = message[0..15]
          ciphertext = cipher.update(message[16..-1])
          ciphertext << cipher.final
          ciphertext.sub(/\000+$/, '')
        end
      end
    end
  end
end
