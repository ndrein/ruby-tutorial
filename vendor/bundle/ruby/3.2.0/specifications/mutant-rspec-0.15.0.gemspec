# -*- encoding: utf-8 -*-
# stub: mutant-rspec 0.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mutant-rspec".freeze
  s.version = "0.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Markus Schirp".freeze]
  s.date = "1980-01-02"
  s.description = "Rspec integration for mutant".freeze
  s.email = ["mbj@schirp-dso.com".freeze]
  s.extra_rdoc_files = ["LICENSE".freeze]
  s.files = ["LICENSE".freeze]
  s.homepage = "https://github.com/mbj/mutant".freeze
  s.licenses = ["Nonstandard".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Rspec integration for mutant".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<mutant>.freeze, ["= 0.15.0"])
  s.add_runtime_dependency(%q<rspec-core>.freeze, [">= 3.8.0", "< 5.0.0"])
end
