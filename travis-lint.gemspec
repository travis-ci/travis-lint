# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "travis/lint/version"

Gem::Specification.new do |s|
  s.name        = "travis-lint"
  s.version     = Travis::Lint::Version.to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael S. Klishin", "Travis CI Development Team"]
  s.email       = ["michaelklishin@me.com", "michael@novemberain.com"]
  s.homepage    = "http://github.com/travis-ci"
  s.summary     = %q{Checks your .travis.yml for possible issues, deprecations and so on}
  s.description = %q{travis-lint is a tool that check your .travis.yml for possible issues, deprecations and so on. Recommended for all travis-ci.org users.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency("hashr", [">= 0.0.19"])

  s.add_development_dependency("rspec", ["~> 2.8.0"])
end
