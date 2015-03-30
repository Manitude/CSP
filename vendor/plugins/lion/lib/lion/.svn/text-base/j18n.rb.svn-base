class Lion
  class J18n
    cattr_accessor :keys

    class << self
      def load_keys
        files = Lion::Query.javascript_files_to_search_for_translation_strings
        self.keys = Lion::Query.find_keys_in(files)
      end
    end
  end
end

Lion::J18n.load_keys
