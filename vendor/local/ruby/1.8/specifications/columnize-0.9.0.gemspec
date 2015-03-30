# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{columnize}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rocky Bernstein"]
  s.date = %q{2014-12-05}
  s.description = %q{
In showing a long lists, sometimes one would prefer to see the value
arranged aligned in columns. Some examples include listing methods
of an object or debugger commands.
See Examples in the rdoc documentation for examples.
}
  s.email = %q{rockyb@rubyforge.net}
  s.extra_rdoc_files = ["README.md", "lib/columnize.rb", "COPYING", "THANKS"]
  s.files = [".gitignore", ".travis.yml", "AUTHORS", "COPYING", "ChangeLog", "Gemfile", "Gemfile.lock", "Makefile", "NEWS", "README.md", "Rakefile", "THANKS", "columnize.gemspec", "lib/Makefile", "lib/columnize.rb", "lib/columnize/Makefile", "lib/columnize/columnize.rb", "lib/columnize/opts.rb", "lib/columnize/version.rb", "test/test-columnize-array.rb", "test/test-columnize.rb", "test/test-columnizer.rb", "test/test-hashparm.rb", "test/test-issue3.rb", "test/test-min_rows_and_colwidths.rb"]
  s.homepage = %q{https://github.com/rocky/columnize}
  s.licenses = ["Ruby", "GPL2"]
  s.rdoc_options = ["--main", "README", "--title", "Columnize 0.9.0 Documentation"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubyforge_project = %q{columnize}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Module to format an Array as an Array of String aligned in columns}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 10.1.0"])
    else
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 10.1.0"])
    end
  else
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 10.1.0"])
  end
end
