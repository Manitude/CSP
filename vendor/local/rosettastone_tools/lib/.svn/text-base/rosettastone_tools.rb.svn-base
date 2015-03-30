# -*- encoding : utf-8 -*-
require 'active_support'
require 'active_support/core_ext'
require 'framework_module'

autoload :ActsAsInterface,            'rosetta_stone/acts_as_interface'
autoload :CurriculumPoint,            'rosetta_stone/curriculum_point'
autoload :ProductLanguages,           'rosetta_stone/product_languages'
autoload :SayWithTime,                'rosetta_stone/say_with_time'

module RosettaStone
  autoload :Benchmark,                'rosetta_stone/benchmark'
  autoload :CommandLineMysql,         'rosetta_stone/command_line_mysql'
  autoload :Compression,              'rosetta_stone/compression'
  autoload :Country,                  'rosetta_stone/country'
  autoload :CpuUsage,                 'rosetta_stone/cpu_usage'
  autoload :FileMutex,                'rosetta_stone/file_mutex'
  autoload :GenericExceptionNotifier, 'rosetta_stone/generic_exception_notifier'
  autoload :HashAssociation,          'rosetta_stone/hash_association'
  autoload :HashEncryption,           'rosetta_stone/hash_encryption'
  autoload :MemUsage,                 'rosetta_stone/mem_usage'
  autoload :OverridableYamlSettings,  'rosetta_stone/overridable_yaml_settings'
  autoload :PrefixedLogger,           'rosetta_stone/prefixed_logger'
  autoload :SpeechLog,                'rosetta_stone/speech_log'
  autoload :UUIDHelper,               'rosetta_stone/uuid_helper'
  autoload :Setup,                    'rosetta_stone/setup'
  autoload :FlashdataCompatibility,   'rosetta_stone/middleware/flashdata_compatibility'
  autoload :TimeWithOffset,           'rosetta_stone/time_with_offset.rb'

  module Middleware
    autoload :DisableAssetsLogger,      'rosetta_stone/middleware/disable_assets_logger'
  end
end

%w[
  active_support_json_ext
  array_ext
  benchmark_ext
  class_ext
  console_string
  date_and_time_ext
  home_run_datetime_fix
  encryption
  enumerable_ext
  hash_ext
  hash_deep_merge
  numeric_ext
  object_ext
  ordered_hash_ext
  string_ext
  stringio_ext
  system_readiness
  system_readiness/database_time_configuration
  system_readiness/eventmachine
  system_readiness/fast_xs
  system_readiness/hoptoad_connectivity
  system_readiness/libxml
  system_readiness/log_writeability
  system_readiness/mysql_bindings
  system_readiness/mysql_connectivity
  system_readiness/mysql_innodb_tweaks
  system_readiness/mysql2_configuration
  system_readiness/ruby
  system_readiness/syntax_of_yaml_files
  system_readiness/tmp_directory_writeability
  uri_ext
  version_string
  yaml_ext
  yaml_settings
].each do |lib|
  require File.join('rosetta_stone', lib)
end

require 'rosettastone_tools/engine' if defined?(Rails::Engine)
