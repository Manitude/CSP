module ActiveSupport
  module JSON
    class << self
      # a quirks mode for json decoding
      #
      # the json spec doesn't allow for strings to be valid json; however,
      # #to_json does allow self to be a straight up string and encodes, for
      # instance the following:
      #
      # '"'.to_json # => "\""
      #
      # we use this in various parts of the app because JSON is a subset of
      # Javascript, and #to_json is the best tool to put a Ruby string into
      # a Javascript snippet via ERB.
      #
      # As far as I know, there aren't any imminent plans to sunset support
      # for #to_json called on strings, but just in case MultiJson (or
      # whatever JSON engine Rails happens to use) goes that route, we wrap
      # the process as #to_embedded_json in our app so that we can patch that
      # functionality back in if need be.
      #
      # In decoding, we expose json_decode_string to reverse that operation
      # for testing purposes.
      def quirks_decode string
        decode("[#{string}]")[0]
      end
    end
  end
end
