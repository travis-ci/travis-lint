Gem::Specification.new 'travis-lint', '2.0.0' do |s|
  s.author        = 'Travis CI GmbH'
  s.email         = 'support@travis-ci.com'
  s.homepage      = 'https://travis-ci.com'
  s.summary       = 'Checks your .travis.yml for possible issues, deprecations and so on'
  s.description   = 'DEPRECATED: Use `travis lint` (from travis gem) instead'
  s.files         = ['bin/travis-lint']
  s.executables   = ['travis-lint']
  s.license       = 'MIT'
end
