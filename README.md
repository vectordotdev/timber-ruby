# Timber.io - Ruby Gem - Powerful Ruby Logging

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://res.cloudinary.com/timber/image/upload/c_scale,w_537/v1464797600/how-it-works_sfgfjp.gif" /></a>
</p>

[![CircleCI](https://circleci.com/gh/timberio/timber-ruby.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/timberio/timber-ruby/tree/master)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)

**Note: Timber is in alpha testing, if interested in joining, please visit http://timber.io**


[Timber](http://timber.io) is a different kind of logging platform; it goes beyond traditional logging by enriching your logs with context. Turning them into rich structured events without altering the essence of logging. See for yourself at [timber.io](http://timber.io).

## Install

Grab your API key by signing up at [timber.io](http://timber.io).

Add timber to your Gemfile:

```
gem 'timber-ruby'
```

Rails installation. In your `config/environments/production.rb` set your logger as:

```ruby
logger = ActiveSupport::TaggedLogging.new(Timber::Logger.new(ENV['TIMBER_KEY'])) # argument is optional
logger.formatter = config.log_formatter
config.logger = logger
```

**Make sure you replace any existing definitions of `config.logger =`**

Prefer to continue logging to your original backend? Add:

```ruby
# insert above config.logger = logger
logger.extend ActiveSupoort::Logger.broadcast(Rails.logger)
```