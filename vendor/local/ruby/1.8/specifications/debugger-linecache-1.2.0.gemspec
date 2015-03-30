# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{debugger-linecache}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["R. Bernstein", "Mark Moseley", "Gabriel Horner"]
  s.date = %q{2013-03-11}
  s.description = %q{Linecache is a module for reading and caching lines. This may be useful for
example in a debugger where the same lines are shown many times.
}
  s.email = %q{gabriel.horner@gmail.com}
  s.extra_rdoc_files = ["README.md"]
  s.files = [".travis.yml", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE.txt", "OLD_CHANGELOG", "OLD_README", "README.md", "Rakefile", "debugger-linecache.gemspec", "lib/debugger/linecache.rb", "lib/linecache19.rb", "lib/tracelines19.rb", "test/data/begin1.rb", "test/data/begin2.rb", "test/data/begin3.rb", "test/data/block1.rb", "test/data/block2.rb", "test/data/case1.rb", "test/data/case2.rb", "test/data/case3.rb", "test/data/case4.rb", "test/data/case5.rb", "test/data/class1.rb", "test/data/comments1.rb", "test/data/def1.rb", "test/data/each1.rb", "test/data/end.rb", "test/data/for1.rb", "test/data/if1.rb", "test/data/if2.rb", "test/data/if3.rb", "test/data/if4.rb", "test/data/if5.rb", "test/data/if6.rb", "test/data/if7.rb", "test/data/match.rb", "test/data/match3.rb", "test/data/match3a.rb", "test/data/not-lit.rb", "test/lnum-diag.rb", "test/parse-show.rb", "test/rcov-bug.rb", "test/short-file", "test/test-linecache.rb", "test/test-lnum.rb", "test/test-tracelines.rb"]
  s.homepage = %q{http://github.com/cldwalker/debugger-linecache}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Read file with caching}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.9.2.2"])
    else
      s.add_dependency(%q<rake>, ["~> 0.9.2.2"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.9.2.2"])
  end
end
