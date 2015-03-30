if Rails.test?
  require 'javascript_lint'
  require 'test/unit'
  Test::Unit::TestCase.send(:include, RosettaStone::JavascriptLint::TestAssertions)

  # default configuration

  # search paths for JS/HTML files
  RosettaStone::JavascriptLint.javascript_directories = [
    File.join(Rails.root, 'public', 'javascripts'),
    File.join(Rails.root, 'test', 'javascript'),
  ]

  # strings or regexes of files to exclude from validation
  # the convention is to add to or override these values in config/initializers/javascript_lint_configuration.rb 
  RosettaStone::JavascriptLint.files_to_exclude = [
    'prototype.js',
    'effects.js',
    'controls.js',
    'dragdrop.js',
    'test/javascript/assets/unittest.js', # wasn't worth trying to fix
  ] + %w(cache cataphractus chuckwalla threadsnake vendor).map do |javascript_subdirectory|
    %r[public/javascripts/#{javascript_subdirectory}/.*\.(js|html)]
  end
end
