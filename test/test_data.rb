class TestData

  class << self

    def coaches
      ['jramanathan','psubramanian','ssitoke', 'snallamuthu','dranjit', 'dutchfellow']
    end

    def timezones(index = nil)
      t = ['Kolkata','Eastern Time (US & Canada)','Hawaii']
      index ? t[index] : t
    end

    def lang_codes
      [
        ['FRA', 'TotaleLanguage', '30','eschool',"null"],
        ['EBR', 'TotaleLanguage', '30','eschool',"null"],
        ['ENG', 'TotaleLanguage', '30','eschool',"null"],
        ['GLE', 'TotaleLanguage', '30','eschool',"null"],
        ['HEB', 'TotaleLanguage', '30','eschool',"null"],
        ['TGL', 'TotaleLanguage', '30','eschool',"null"],
        ['TUR', 'TotaleLanguage', '30','eschool',"null"],
        ['KLE', 'ReflexLanguage', '30','eschool',"null"],
        ['POL', 'TotaleLanguage', '30','eschool',"null"],
        ['DEU', 'TotaleLanguage', '30','eschool',"null"],
        ['ITA', 'TotaleLanguage', '30','eschool',"null"],
        ['POR', 'TotaleLanguage', '30','eschool',"null"],
        ['GRK', 'TotaleLanguage', '30','eschool',"null"],
        ['RUS', 'TotaleLanguage', '30','eschool',"null"],
        ['FAR', 'TotaleLanguage', '30','eschool',"null"],
        ['AUK', 'AriaLanguage',   '60','supersaas','supersaas1'],
        ['JPN', 'TotaleLanguage', '30','eschool',"null"],
        ['VIE', 'TotaleLanguage', '30','eschool',"null"],
        ['KOR', 'TotaleLanguage', '30','eschool',"null"],
        ['HIN', 'TotaleLanguage', '30','eschool',"null"],
        ['ESP', 'TotaleLanguage', '30','eschool',"null"],
        ['ESC', 'TotaleLanguage', '30','eschool',"null"],
        ['NED', 'TotaleLanguage', '30','eschool',"null"],
        ['CHI', 'TotaleLanguage', '30','eschool',"null"],
        ['AUS', 'AriaLanguage',   '60','supersaas','supersaas1'],
        ['SVE', 'TotaleLanguage', '30','eschool',"null"],
        ['TMM-NED-P', 'TMMPhoneLanguage', '30','supersaas','supersaas2'],
        ['TMM-ENG-P', 'TMMPhoneLanguage', '30','supersaas','supersaas2'],
        ['TMM-FRA-P', 'TMMPhoneLanguage', '30','supersaas','supersaas2'],
        ['TMM-DEU-P', 'TMMPhoneLanguage', '30','supersaas','supersaas2'],
        ['TMM-ITA-P', 'TMMPhoneLanguage', '30','supersaas','supersaas2'],
        ['TMM-ESP-P', 'TMMPhoneLanguage', '30','supersaas','supersaas2'],
        ['TMM-NED-L', 'TMMLiveLanguage', '60',"null","null"],
        ['TMM-ENG-L','TMMLiveLanguage', '60',"null","null"],
        ['TMM-FRA-L', 'TMMLiveLanguage', '60',"null","null"],
        ['TMM-DEU-L', 'TMMLiveLanguage', '60',"null","null"],
        ['TMM-ITA-L','TMMLiveLanguage', '60',"null","null"],
        ['TMM-ESP-L', 'TMMLiveLanguage', '60',"null","null"],
        ['TMM-MCH-L','TMMMichelinLanguage','60',"null","null"]
      ]
    end

    def coachmanagers
      ['skumar', 'vramanan', 'ajayakodi']
    end

  end#class<<self

end

