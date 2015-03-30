# -*- encoding : utf-8 -*-
class RSLocale
  cattr_accessor :supported_locales
  cattr_accessor :all_locales

  class << self
    def load_locales
      self.supported_locales = YAML.load_file(File.join(RAILS_ROOT, 'config', 'supported_locales.yml')) # we have this in a config instead of looking in the filesystem because svn might have shared files but the particular app doesn't need those locales
      self.all_locales = YAML.load_file(File.join(RAILS_ROOT, 'config', 'supported_locales.yml.sample'))
    end

    def locale_language(iso, do_spanify = false, bypass = false)
      {
        'de-DE' => _('German', {}, do_spanify, bypass),
        'en-US' => _('English', {}, do_spanify, bypass),
        'es-419' => _('Spanish', {}, do_spanify, bypass),
        'fr-FR' => _('French', {}, do_spanify, bypass),
        'it-IT' => _('Italian', {}, do_spanify, bypass),
        'ja-JP' => _('Japanese', {}, do_spanify, bypass),
        'ko-KR' => _('Korean', {}, do_spanify, bypass),
        'pt-BR' => _('Portuguese', {}, do_spanify, bypass),
        'ru-RU' => _('Russian', {}, do_spanify, bypass),
        'zh-CN' => _('Chinese', {}, do_spanify, bypass)
      }[iso]
    end
  end

end

RSLocale.load_locales
