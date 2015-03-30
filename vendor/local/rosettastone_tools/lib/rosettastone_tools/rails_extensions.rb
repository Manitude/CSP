%w[
  singleton_class
  rails_module_backports
  inflector_ext
  abstract_class
  validation_extensions
  laziness_lookup_attribute
  rails_logging
  active_record_ext
  action_controller_ext
  migration_numbers
  validates_uniqueness_of
  yui_integration
  encryption/mcode
  encryption/helper
  base_64_compatibility
  erb_util_ext
  swf_path_helper
  render_context
  mongrel_monkey_patches
  disable_rails_ip_spoofing_check
  has_and_belongs_to_many_describe_fix
  time_zone_compatibility
].each do |lib|
  require File.join('rosetta_stone', lib)
end

if Rails.test?
  %w[
    assert_tidy_with_overescaping_checks
    test_unit_ext
    meta_test
    combined_test_execution
    test_stop_on_error
    time_zone_test
    crossdomain_test
    changing_constant
    test_session_ext
  ].each do |test_lib|
    require File.join('rosetta_stone', 'test', test_lib)
  end
end

# not including by default; require it explicitly if you need it
#require 'rosetta_stone/time_comparison_hack'
#require 'rosetta_stone/language_sorting_collection_extension'
#require 'rosetta_stone/validateable'
#require 'rosetta_stone/platform_independent_rake'
#require 'rosetta_stone/encryption/rsa'
#require 'rosetta_stone/encryption/aes'
#require 'rosetta_stone/encryption/blowfish'
#require 'rosetta_stone/encryption/token_verification'
#require 'rosetta_stone/encryption/blowfish_token_verification'
#require 'rosetta_stone/file_mutex'
#require 'rosetta_stone/webrick_spawner'
#require 'rosetta_stone/event_dispatcher'
#require 'rosetta_stone/active_record_timestamps_never_go_backward'
#require 'rosetta_stone/hoptoad_notifier_ext'
#require 'rosetta_stone/monitoring_controller/base'
#require 'rosetta_stone/monitoring_controller/rails_session_checks'
#require 'rosetta_stone/monitoring_controller/clock_checks'
#require 'rosetta_stone/time_with_offset'
#require 'rosetta_stone/system_call_helpers'

# try to load ruby-debug:
if Rails.test? || Rails.development?
  # FIXME: the implementation of this procedure "should" probably be in two steps:
  #
  # 1. check if ruby-debug gem is installed (the gem is called ruby-debug on 1.8 and
  # ruby-debug19 on 1.9). be sure to use Gem.available? or Gem::Specification.find_by_name
  # (n.b., find_by_name raises on a failure; available? returns false) depending on
  # rubygems version.
  # 2. then try to require 'ruby-debug' (the require file name regardless of ruby
  # version), possibly rescuing from LoadError.
  #
  begin
    require 'ruby-debug'
    # if Rails initializers hadn't run yet, like would be the case if rosettastone_tools were used as a gem,
    # Rails.logger would be nil
    Rails.logger.if_hot {|logger| logger.debug("Required ruby-debug.") }
  rescue LoadError => load_error
    Rails.logger.if_hot {|logger| logger.debug("Tried to load ruby-debug but it failed: #{load_error.message}.  Ignoring.") }
  end
end
