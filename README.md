# MotionVj

This gem uploads [motion](http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome) videos to Dropbox.

## Installation

Install the gem and make the executable available:

    $ gem install motion_vj

## Configuration

The configuration file should look like this:

```yaml
# config.yml

# To obtain the app key and secret, go to https://www.dropbox.com/developers/apps/create
db_app_key: <App key from Dropbox>
db_app_secret: <App secret from Dropbox>
# The token can be generated using `--get-token`. Please see the Usage section of the README.
db_app_token: <App token from Dropbox>
# The Dropbox directory where the files will be uploaded.
db_videos_dir: /

# The motion CLI name.
motion_cmd: motion
# Path to the PID file that will be created when running.
pid_file: /var/run/motion/motion.pid
# Directory where motion save the videos.
videos_dir: /var/run/motion/videos
# Extension of the videos that should be uploaded.
videos_extension: avi
```

You must provide it using the `--config-file` option as pointed by the [Usage](#Usage) section.

## Usage

So that `motionvj` can access a Dropbox account, a Dropbox token needs to be created. This will be a one time action, and it can be acomplished running `motionvj --get-token --config-file config.yml`, where `config.yml` is the file detailed by the [Configuration](#Configuration) section of this README. Once the token is created, it should be added to the same configuration file.

To start uploading new videos, just run `motionvj --config-file config.yml`. This should upload new videos that end with the extension indicated by the configuration file. After a file is uploaded to Dropbox, it is then deleted from the local filesystem.

For more options, run `motionvj --help`:

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

