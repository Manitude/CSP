# -*- encoding : utf-8 -*-
module RosettaStone
  module Encryption
    module Helper
      require 'digest'
      class << self
        attr_accessor :cached_private_keys, :cached_public_keys

        def hexify(encrypted_message)
          encrypted_message.unpack('H*').first
        end

        def dehexify(message)
          [message].pack('H*')
        end

        def sha256(message)
          Digest::SHA2.new(256).digest(message.to_s)
        end

        # if config_subdirectory is nil, we will pull the private key from RAILS_ROOT/config/rsa_encryption_private_key.pem (falling back to .sample).
        # if present, we will look first for RAILS_ROOT/config/encryption_keys/#{config_subdirectory}/rsa_encryption_private_key.pem[.sample]
        # falling back to RAILS_ROOT/config if not present.
        def private_key(config_subdirectory = nil)
          self.cached_private_keys[config_subdirectory.to_s] ||= File.read(key_file_path(:private, config_subdirectory))
        end

        # if config_subdirectory is nil, we will pull the public key from RAILS_ROOT/config/rsa_encryption_public_key.pem (falling back to .sample).
        # if present, we will look first for RAILS_ROOT/config/encryption_keys/#{config_subdirectory}/rsa_encryption_public_key.pem[.sample]
        # falling back to RAILS_ROOT/config if not present.
        def public_key(config_subdirectory = nil)
          self.cached_public_keys[config_subdirectory.to_s] ||= File.read(key_file_path(:public, config_subdirectory))
        end

        def clear_key_file_cache!
          self.cached_private_keys, self.cached_public_keys = {}, {}
        end

      private

        def key_file_path(public_or_private, config_subdirectory)
          configs_to_try = [config_subdirectory, nil].uniq
          configs_to_try.each do |config_base|
            [false, true].each do |sample|
              Framework.logger.warn("Failed to locate a .pem file for the requested config subdirectory '#{config_subdirectory}', falling back to RAILS_ROOT/config") if config_subdirectory.present? && config_base.nil?
              file_path = sample_or_real_file_path(public_or_private, sample, config_base)
              return file_path if File.exist?(file_path)
            end
          end
          raise RuntimeError.new('Failed to locate a suitable .pem file for encryption')
        end

        def sample_or_real_file_path(public_or_private, sample = false, config_subdirectory = nil)
          config_path = config_subdirectory.blank? ? '' : File.join('encryption_keys', config_subdirectory.to_s)
          File.join(config_base_directory, config_path, "rsa_encryption_#{public_or_private}_key.pem" + (sample ? '.sample' : ''))
        end

        def config_base_directory
          File.join(Framework.root, 'config')
        end
      end

      self.clear_key_file_cache!
    end
  end
end
