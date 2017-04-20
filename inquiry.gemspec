# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "inquiry/version"

Gem::Specification.new do |spec|
  spec.name          = "inquiry"
  spec.version       = Inquiry::VERSION
  spec.authors       = ["Nathan Wallace"]
  spec.email         = ["nathan@nosuchthingastwo.com"]

  spec.summary       = %q{Declaratively configure search inputs for queries with ActiveRecord}
  spec.description   = %q{Declaratively configure search inputs for queries with ActiveRecord}
  spec.homepage      = "https://github.com/nwallace/inquiry"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activerecord", ">= 3.2.0"
  spec.add_dependency "will_paginate", ">= 3.0.0"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "sqlite3", "~> 1.3.11"
  spec.add_development_dependency "standalone_migrations", "~> 4.0.3"
  spec.add_development_dependency "database_cleaner", "~> 1.5.1"
end
