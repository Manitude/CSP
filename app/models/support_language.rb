# == Schema Information
#
# Table name: support_languages
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     
#  language_code :string(255)     
#  created_at    :datetime        
#  updated_at    :datetime        
#

class SupportLanguage < ActiveRecord::Base
  audit_logged

  def self.display_name(code)
    obj = find_by_language_code(code) unless code.blank?
    obj.name if obj
  end

  def self.language_code_and_display_name_hash
    language_hash = Hash.new(0) 
    find(:all).each do |lang| 
      language_hash[lang.language_code.to_s] = lang.name.to_s 
    end 
    language_hash 
  end

  def self.language_code(language)
    obj = find_by_name(language) unless language.blank?
    obj.language_code if obj
  end

  def self.supported_languages
    support_languages = []
    support_languages << %w(All None)
    all.each do |language|
      support_languages << [language.name, language.language_code] if !unsupported_languages.include?(language.name.downcase)
    end
    support_languages.sort! { |a, b| a[0] <=> b[0] }
  end

  private

  def self.unsupported_languages
    %w(german french italian russian none chinese)
  end
end
