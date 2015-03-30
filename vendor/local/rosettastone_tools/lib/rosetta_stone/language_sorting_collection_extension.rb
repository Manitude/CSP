# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module LanguageSortingCollectionExtension

    # Trac #507: Here's the deal. Ruby uses binary sorting by default, because it doesn't know anything about how to
    # sort Unicode strings. So we're using MySQL's ability to sort by selecting the text (in order) from
    # Globalize::ViewTranslation and then re-indexing the collection of entities with that ordering (except for English
    # where a simple .sort_by call suffices).
    #
    # An entity is either an AvailableProduct or a ProductRight (really anything that responds to product_identifier)
    #
    # Further complication with changing the locale was added by changing the query to select based on the indexed
    # tr_key column, instead of the non-indexed text column for performance.
    #
    #--
    # FIXME: This is ugly as a mofo, but it works. I imagine this will be fixed in the refactor that add
    # an actual Language model.
    #++
    #
    # namer:: A closure to the language_name function, so we can keep this code in the model and not muck up
    # our controllers
    def fix_sorting!(namer)
      unless Globalize::Locale.base?
        saved_lang_code, user_language_id = Localization.current.to_s, Globalize::Locale.active.language.id

        Localization.set_locale_to_default
        language_names = self.collect { |entity| namer.call(entity.product_identifier, entity.product_version) }

        # FIXME : gross hacks ahoy
        if language_names.empty?
          Localization.set(saved_lang_code)
          return language_names
        end

        entity_ordering = Globalize::ViewTranslation.find(:all,
          :select => 'distinct text',
          :conditions => ["tr_key in (?) and language_id = ? and text is not null", language_names, user_language_id],
          :order => 'text asc'
        )
        Localization.set(saved_lang_code)

        new_entities = []
        entity_ordering.each do |sorted_language_result|
          new_entities << self.select {|entity| namer.call(entity.product_identifier, entity.product_version).t == sorted_language_result.text }
        end

        new_entities.flatten! if new_entities

        self.replace new_entities
      else
        self.replace self.sort_by {|entity| namer.call(entity.product_identifier, entity.product_version)} # English is the easy case.
      end
    end

  end
end
