# Testing

## Prerequisites

`Docker` and `ruby` need to be installed on the local machine.

## Running Tests

After cloning the repository the testing environment should be set up on the
local machine:

```
$ bundle install --path .bundle
$ bundle exec rake
$ bundle exec rake spec
$ bundle exec rake lint
$ bundle exec rake rubocop
$ bundle exec rake beaker
$ BEAKER_set=debian10 bundle exec rake beaker
$ BEAKER_destroy=no BEAKER_set=debian10 bundle exec rake beaker
```

### Troubleshooting

Sometime the nokogiri Gem causes some issues with Bundle.

```
$ apt-get install libxml2-dev libxslt-dev pkg-config ruby2.3-dev
$ gem install nokogiri # as root
$ bundle config build.nokogiri --use-system-libraries
```

With running `rake` the whole testsuite is triggered, this
includes:

  * puppet syntax validation
  * code-style enforcement (with `puppet-lint`)
  * unit-tests (with `rspec-puppet`)
  * acceptance-tests (with `beaker-rspec`)

## Coding Standards

* All variables are defined in the base manifest (init.pp)
* Two spaces indent
* No more than 140 characters per line
* Every module uses a data/common.yaml for default values
* There should be default values for **non** security relevant variables
