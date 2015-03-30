# -*- encoding : utf-8 -*-
# Provides String#substr and String#substr! which have slightly different behaviour
# to String#slice/String#slice! in Ruby
require File.dirname(__FILE__) + '/../string_ext'
require 'base64'

module RosettaStone
  module Encryption
    module Mcode

      # A collection of module methods that together implement FLTmcode encryption and decryption.
      #
      # Main entry points are gfunction, ginverse, and generate_random_key.
      #
      # FLTmcoding is a scheme that maps strings with only standard printable ASCII characters, to strings that contain only
      # numeric digits.  Numeric digits that represent real plaintext characters are interleaved with random "fill" digits,
      # that seem merely obfuscatory.  The number of fill digits used at each position ranges from 0 to 3, and is determined
      # by the specified encryption key.
      #
      # EXAMPLE:
      #
      # string_to_encrypt = "ROCK"
      # encryption_key = 1275
      #
      # Each character ('R','O','C','K') is converted to ASCII code, less 32  =>  "50", "47", "35", "43"
      #
      # The two least significant bits of the encryption key are used to determine the initial number of fill digits, the next
      # two LSBs determine the next number of fill digits, and so on.  A particularly convenient way to visualize this is to
      # convert the encryption_key to base-4 notation, and read its digits right-to-left, cyclically.
      #
      # encryption_key.to_s(4)  =>  "103323"       number of fill digits  =>  3, 2, 3, 3, 0, 1, 3, 2, 3, 3, 0, 1...
      #
      # The fill digits themselves are simply random numeric digits.  Fill digits go first, then the character data, like so:
      #
      # Mcode.gfunction("ROCK", 1275)  =>  "...50..47...35...43"   (Periods represent the random fill digits.)
      #
      # Thus, the return value of Mcode.gfunction("ROCK", 1275) will vary randomly with each call, but the relevant
      # part (representing the character data) will remain the same.
      #
      # Mcode.gfunction("ROCK", 1275)  =>  "3845027470393579343"
      # Mcode.gfunction("ROCK", 1275)  =>  "5365077477413558043"    etc.
      #

      EXTENSION_PREFIX = '-'

      # Mcode.gfunction now supports characters that would have broken the old scheme.  Basically, it checks to see if
      # the old encryption scheme "works" (i.e. Mcode.ginverse_base properly yields the original string).  If not, then
      # the string_to_encrypt is base-64 encoded first, and a prefix is prepended to signal Mcode.ginverse that it needs
      # to base-64 decode the result before returning it.
      #
      # NOTE: By default, Base64.encode64 does a base-64 encoding with embedded newlines.  Newlines aren't handled well by
      #       Mcode.gfunction_base, so we need to wax those with .map(&:chomp).join before encryption.
      #
      def self.gfunction(string_to_encrypt, encryption_key)
        string_to_encrypt = string_to_encrypt.to_s
        old_school = self.gfunction_base(string_to_encrypt, encryption_key)
        (self.ginverse_base(old_school, encryption_key) == string_to_encrypt) ?
          old_school : EXTENSION_PREFIX + self.gfunction_base(::Base64.encode64(string_to_encrypt).split(/\n/).map(&:chomp).join, encryption_key)
      end

      # This is a clean refactor of Mcode.gfunction_old.
      def self.gfunction_base(string_to_encrypt, encryption_key)
        encrypted, fill_array, fill_index = '', self.two_bit_array(encryption_key.to_i), 0
        string_to_encrypt.to_s.each_byte do |character|
          encrypted << "0123456789".rand(fill_array[fill_index]) << sprintf('%02d', character - 32)
          fill_index = (fill_index + 1) % fill_array.size
        end
        encrypted
      end

      # Mcode.ginverse decodes strings that have been encoded using Mcode.gfunction.  The same encryption_key used
      # to encode is a required parameter.  If EXTENSION_PREFIX is detected at the start of encrypted_parameter, base-64 decoding
      # will be performed after the normal decryption process.  Since all encrypted strings are composed of numeric digits, a
      # non-numeric EXTENSION_PREFIX is sufficient for recognition.
      #
      def self.ginverse(encrypted_parameter, encryption_key)
        extension_match = Regexp.new('^' + EXTENSION_PREFIX)
        if encrypted_parameter.match(extension_match) 
          inverse = ::Base64.decode64(self.ginverse_base(encrypted_parameter.sub(extension_match, ''), encryption_key))
          inverse.respond_to?(:force_encoding) ? inverse.force_encoding("UTF-8") : inverse
        else
          self.ginverse_base(encrypted_parameter, encryption_key)
        end
      end

      # This is a clean refactor of Mcode.ginverse_old.
      def self.ginverse_base(encrypted_parameter, encryption_key)
        decrypted, fill_array, fill_index = '', self.two_bit_array(encryption_key.to_i), 0
        working_parameter = encrypted_parameter.dup
        until (working_parameter.empty?)
          working_parameter.slice!(0, fill_array[fill_index])
          fill_index = (fill_index + 1) % fill_array.size
          decrypted << (working_parameter.slice!(0, 2).to_i + 32).chr
        end
        decrypted
      end

      # Returns an array of integers n, where 0 <= n <= 3, indicating the number of fill digits which should be used
      # at each step of the encryption process, based on the specified encryption key.  Numbers should be pulled from
      # this array starting at index 0; if more numbers are needed than are in the returned array, "wrap around" to
      # index 0 as needed.
      #
      def self.two_bit_array(encryption_key)
        raise ArgumentError, "Encryption keys must be positive integers no longer than 9 digits" if encryption_key > 999999999 || encryption_key < 1
        encryption_key.to_s(4).reverse.split('').map(&:to_i)
      end

      def self.generate_random_key
        "123456789".rand + "0123456789".rand(8)
      end

  ############################################################################################################
  # Older version of an FLTMcode implementation, preserved for testing purposes
  #
  # self.gfunction_old was a prior version of self.gfunction, and so on.
  ############################################################################################################

      # Encrypts string_to_encrypt with encryption_key using this algorithm that the
      # application understands. Encryption keys longer than 9 characters generate
      # bogus data, and encryption keys have to be digits.
      def self.gfunction_old(string_to_encrypt, encryption_key)
        string_to_encrypt, encryption_key = string_to_encrypt.to_s, encryption_key.to_i
        reserved_key, out = encryption_key, ''
        string_to_encrypt.each_byte do |character|
          twobits = encryption_key % 4
          encryption_key = encryption_key / 4
          encryption_key = reserved_key if encryption_key < 1
          # This crazy one line collect and join makes a 3 character random number and then
          # takes off the first "twobits" worth of characters
          fill = Array.new(3).collect{rand(10)}.join('').substr(0, twobits) unless twobits.zero?
          ascii_char_code = sprintf('%02d', character - 32)
          out << fill.to_s << ascii_char_code
        end
        return out
      end

      # Decrypts encrypted_parameter with encryption_key that's been encrypted using
      # gfunction.
      def self.ginverse_old(encrypted_parameter, encryption_key)
        encrypted_parameter, encryption_key = encrypted_parameter.to_s.dup, encryption_key.to_i
        reserved_encryption_key, out = encryption_key, ''

        while encrypted_parameter.length != 0 do
          twobits = encryption_key % 4
          encryption_key = encryption_key / 4
          encryption_key = reserved_encryption_key if encryption_key < 1

          encrypted_parameter.substr!(twobits)
          ascii_character = encrypted_parameter.slice!(0, 2)
          real_ascii_value = ascii_character.to_i + 32
          out << real_ascii_value.chr
        end

        return out
      end

      # ginverse/gfunction don't work with keys longer than 9 characters, so this ensures
      # that unfortunate situation will never occur
      def self.generate_random_key_old
        x = 0
        while(x == 0)
          x = Time.now.usec
        end
        ((Time.now.to_i % x).to_s + (x * 2).to_s)[0,9]
      end

    end # module Mcode
  end # module Encryption
end # module RosettaStone
