# MotionVj

This gem uploads [motion](http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome) videos to Dropbox.

## Installation

Install the gem and make the executable available:

    $ gem install motion_vj

## Usage

Once installed, a Dropbox token is needed to start. Run `motionvj --get-token` and follow the instructions.

For more details, run `motionvj --help`:

```
Usage: motionvj [options]
Required:
    -c, --config-file [CONFIG_FILE]  Path to the configuration file
Optional:
    -t, --get-token                  Get the Dropbox token
Common:
    -h, --help                       Show this message
    -v, --version                    Show version
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/repinel/motion_vj. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

