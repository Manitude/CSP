# -*- encoding : utf-8 -*-
require 'rosetta_stone/encryption/rsa'
require 'rosetta_stone/encryption/aes'

# Tokens are a signature and encrypted data concatenated together.
# This class uses AES 2048-bit symmetric encryption (using the public key) with a 256-byte RSA signature (using the private key).
# If you want to implement a different encryption/signature algorithm, override the marked methods.
#
# If you want shorter tokens, see blowfish_token_verification.rb
module RosettaStone
  module Encryption
    module TokenVerification
      class BrokenTokenException < StandardError; end

      def self.included(target_class)
        target_class.extend(ClassMethods)
        target_class.send(:include, InstanceMethods)
        target_class.metaclass_eval do
          # leave this nil to use the rsa_encryption_*_key.pem[.sample] files in RAILS_ROOT/config, or
          # set it to a subdirectory underneath RAILS_ROOT/config/encryption_keys if desired.
          # see RosettaStone::Encryption::Helper for more details
          attr_accessor :token_verification_encryption_key_subdirectory
        end
      end

      module ClassMethods
        def extract_data_from_token(token)
          raise BrokenTokenException unless verify_token(token)
          encrypted_data = token[signature_length..-1]
          decrypt_data(encrypted_data)
        end

        # override if implementing a different encryption algorithm
        def encrypt_data(message)
          RosettaStone::Encryption::Aes.encrypt(message, RosettaStone::Encryption::Helper.sha256(public_key))
        end

        # override if implementing a different signature algorithm
        def sign(encrypted_data)
          RosettaStone::Encryption::Rsa.sign(RosettaStone::Encryption::Helper.sha256(encrypted_data), private_key)
        end

      private
        def verify_token(token)
          signature, encrypted_data = token[0...signature_length], token[signature_length..-1]
          verify_signature(signature, encrypted_data)
        rescue
          false
        end

        def public_key
          RosettaStone::Encryption::Helper.public_key(token_verification_encryption_key_subdirectory)
        end

        def private_key
          RosettaStone::Encryption::Helper.private_key(token_verification_encryption_key_subdirectory)
        end

        # override if implementing a different encryption algorithm
        def decrypt_data(encrypted_data)
          RosettaStone::Encryption::Aes.decrypt(encrypted_data, RosettaStone::Encryption::Helper.sha256(public_key))
        end

        # override if implementing a different signature algorithm
        def verify_signature(signature, encrypted_data)
          RosettaStone::Encryption::Rsa.unsign(signature, private_key) == RosettaStone::Encryption::Helper.sha256(encrypted_data)
        end

        # override if implementing a different signature algorithm
        def signature_length
          256 # bytes
        end
      end

      module InstanceMethods
      private
        def token(message)
          encrypted_data = klass.encrypt_data(message)
          signature = klass.sign(encrypted_data)
          signature + encrypted_data
        end
      end

    end
  end
end
