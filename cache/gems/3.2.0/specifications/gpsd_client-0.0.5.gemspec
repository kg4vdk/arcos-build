# -*- encoding: utf-8 -*-
# stub: gpsd_client 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "gpsd_client".freeze
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["rccursach".freeze]
  s.bindir = "exe".freeze
  s.date = "2016-07-10"
  s.description = "A simple GPSd client intended for use on the Raspberry Pi.".freeze
  s.email = ["rccursach@gmail.com".freeze]
  s.homepage = "https://github.com/rccursach/gpsd_client".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Ruby gem for GPSD.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.8"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  s.add_development_dependency(%q<rspec-core>.freeze, ["~> 3.2.1"])
  s.add_development_dependency(%q<rspec-expectations>.freeze, ["~> 3.2.1"])
end
