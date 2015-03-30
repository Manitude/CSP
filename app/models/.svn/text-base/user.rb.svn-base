class User

  attr_accessor :user_name, :groups, :account_id, :time_zone

  SERIALIZED = ['@user_name', '@groups', '@account_id', '@time_zone'].freeze
  def _dump(level=0)
    hash = Hash.new
    SERIALIZED.each do |sym|
      hash[sym] = instance_variable_get(sym)
    end
    Marshal.dump(hash)
  end

  class << self
    def _load(arg)
      o = new(nil)
      h = Marshal.load(arg)
      SERIALIZED.each {|s| o.instance_variable_set(s, h[s]) if h[s]}
      o
    end
  end

  def initialize(user_name)
    self.user_name = user_name
  end

  def account
    if @account.blank?
      @account = Account.find_by_id(self.account_id)
      @account.time_zone = self.time_zone
    end
    @account
  end

  def self.bypass_authentication?
    AdGroup.settings[:bypass_authentication]
  end

  def self.spoof_authentication?
    AdGroup.settings[:spoof_authentication]
  end

  def self.authenticate(user_name, password)
    user = nil
    if bypass_authentication?
      user = self.new(user_name)
      user.groups = AdGroup.ldap_type("coach_manager").to_a
      user.find_or_create_account

    elsif spoof_authentication?
      account = Account.find_by_user_name(user_name)
      if account && AdGroup.settings[:spoof_password] == password
        user = self.new(user_name)
        user.groups = AdGroup.ldap_type(account.type.to_s.underscore).to_a
        user.account_id = account.id
      end

    elsif (ldap_entry = ldap_api.authenticate(:user_name => user_name, :password => password))
      ldap_groups = find_groups(ldap_entry)
      if !ldap_groups.blank?
        user = self.new(user_name)
        user.groups = ldap_groups
        user.find_or_create_account(ldap_entry)
      end
    end
    user
  end

  def find_or_create_account(ldap_entry = Net::LDAP::Entry.new)
    account = Account.find_or_initialize_by_user_name(self.user_name)
    account.attributes = ldap_attributes(ldap_entry) if account.new_record?
    account.type = AdGroup.account_type(groups[0])
    account.save(:validate => false)
    self.account_id = account.id
  end

  def to_s
    "User: #{self.user_name}, Groups: [#{self.groups.join(', ') if self.groups}], Time Zone: #{self.time_zone ? self.time_zone : 'Eastern Time (US & Canada)'}"
  end

  def is_coach?
    groups.include?(AdGroup.coach)
  end

  def is_manager?
    groups.include?(AdGroup.coach_manager)
  end

  def is_admin?
    groups.include?(AdGroup.admin)
  end

  def is_tier1_support_user?
    groups.include?(AdGroup.support_user)
  end

  def is_tier1_support_lead?
    groups.include?(AdGroup.support_lead)
  end

  def is_community_moderator?
    groups.include?(AdGroup.community_moderator)
  end

  def is_led_user?
    groups.include?(AdGroup.led_user)
  end

  def is_tier1_support_harrisonburg_user?
    groups.include?(AdGroup.support_harrisonburg_user)
  end

  def is_tier1_support_concierge_user?
    groups.include?(AdGroup.support_concierge_user)
  end

  private

  def self.ldap_api
    RosettaStone::LDAPUserAuthentication::ActiveDirectoryUser
  end
  
  def self.find_groups(ldap_entry)
    ldap_groups = ldap_api.build_parent_group_tree_for(ldap_entry)
    ldap_groups = ldap_groups.sort_by{|ldap_group| ldap_group.whencreated[0].to_time}.reverse
    ldap_groups = ldap_groups.collect{ |entry| entry.name[0] }.uniq
    valid_groups = ldap_groups & AdGroup.all_names
    #since csp has single role for a user, keeping the main role only. Remove the slice method when multiple role is being implemented.
    valid_groups.slice(0,1)
  end

  def ldap_attributes(entry)
    {
      :full_name      => entry['name'].to_s,
      :preferred_name => entry['givenname'].to_s,
      :rs_email       => (!(entry['mailnickname'].blank?) ? (entry['mailnickname'].to_s + '@rosettastone.com') : (entry['name'][0].to_s + '@rosettastone.com')),
      :native_language => "en-US"
    }
  end

end
