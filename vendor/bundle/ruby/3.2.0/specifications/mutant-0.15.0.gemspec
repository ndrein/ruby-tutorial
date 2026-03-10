# -*- encoding: utf-8 -*-
# stub: mutant 0.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mutant".freeze
  s.version = "0.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/mbj/mutant" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Markus Schirp".freeze]
  s.date = "1980-01-02"
  s.description = "Mutation Testing for Ruby.".freeze
  s.email = ["mbj@schirp-dso.com".freeze]
  s.executables = ["mutant".freeze, "mutant-ruby".freeze]
  s.extra_rdoc_files = ["LICENSE".freeze]
  s.files = ["LICENSE".freeze, "bin/mutant".freeze, "bin/mutant-ruby".freeze]
  s.homepage = "https://github.com/mbj/mutant".freeze
  s.licenses = ["Nonstandard".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<diff-lcs>.freeze, [">= 1.6", "< 3"])
  s.add_runtime_dependency(%q<irb>.freeze, ["~> 1.15"])
  s.add_runtime_dependency(%q<parser>.freeze, ["~> 3.3.10"])
  s.add_runtime_dependency(%q<regexp_parser>.freeze, ["~> 2.10"])
  s.add_runtime_dependency(%q<sorbet-runtime>.freeze, ["~> 0.6.0"])
  s.add_runtime_dependency(%q<unparser>.freeze, ["~> 0.8.2"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.10", "< 5"])
  s.add_development_dependency(%q<rspec-core>.freeze, [">= 3.10", "< 5"])
  s.add_development_dependency(%q<rspec-its>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.7"])
end
