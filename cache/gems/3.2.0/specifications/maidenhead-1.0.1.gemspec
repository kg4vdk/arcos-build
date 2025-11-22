# -*- encoding: utf-8 -*-
# stub: maidenhead 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "maidenhead".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Graff".freeze]
  s.date = "2014-03-27"
  s.description = "Convert between latitude/longitude and Maidenhead Locator System strings".freeze
  s.email = "explorer@flame.org".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE.txt".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/skandragon/maidenhead".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Maidenhead Locator System conversion".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.7"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<jeweler>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<guard>.freeze, [">= 0"])
  s.add_development_dependency(%q<guard-minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubysl>.freeze, [">= 0"])
end
