# What is travis-lint

`travis-lint` is a tool that checks your `.travis.yml` file for possible issues, deprecations and so on.

[![Continuous Integration status](https://secure.travis-ci.org/travis-ci/travis-lint.png)](http://travis-ci.org/travis-ci/travis-lint)


## Installation

    gem install travis-lint


## Usage

    travis-lint # inside a dir with .travis.yml
    travis-lint ./.travis.yml
    travis-lint ~/your/project/.travis.yml


## Development

Install dependencies with

    bundle install

then run tests with

    bundle exec rspec spec

Once you are done with your changes, push a branch and submit a pull request.


## License & Copyright

Copyright 2012 (c) Travis CI Development Team.

Released under the MIT license.
