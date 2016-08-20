# Timber.io - Ruby Gem - Powerful Ruby Logging

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://res.cloudinary.com/timber/image/upload/c_scale,w_537/v1464797600/how-it-works_sfgfjp.gif" /></a>
</p>

[![CircleCI](https://circleci.com/gh/timberio/timber-ruby.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/timberio/timber-ruby/tree/master)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)

**Note: Timber is in alpha testing, if interested in joining, please visit http://timber.io**


[Timber](http://timber.io) is a different kind of logging platform; it goes beyond traditional logging by enriching your logs with context. Turning them into rich structured events without altering the essence of logging. See for yourself at [timber.io](http://timber.io).

## Install

Grab your API key by signing up at [timber.io](http://timber.io). If you place your API key in the `TIMBER_KEY` environment variable you do not have to specify it below.

Add timber to your Gemfile:

```
gem 'timber-ruby'
```

### Rails >= 3.2.1

In your environment configuration files (ex: `config/environments/production.rb`) set your logger as:

```ruby
config.logger = ::ActiveSupport::TaggedLogging.new(::ActiveSupport::Logger.new(Timber::LogDevices::HTTP.new(ENV['TIMBER_KEY']))) # Passing the ENV['TIMBER_KEY'] is optional, showing it for explicitness
```

### Rails <= 3.2.0

In your environment configuration files (ex: `config/environments/production.rb`) set your logger as:

```ruby
config.logger = ::ActiveSupport::Logger.new(Timber::LogDevices::HTTP.new(ENV['TIMBER_KEY'])) # Passing the ENV['TIMBER_KEY'] is optional, showing it for explicitness
```

### Heroku

If you wish to use Heroku's [log drains feature](https://devcenter.heroku.com/articles/log-drains), you can use the `IO` log device.

Instead of `Timber::LogDevices::HTTP.new(ENV['TIMBER_KEY'])` use `Timber::LogDevices::IO.new`.

Then run

```
$ heroku drains:add https://<application-id>:<api-key>@api.timber.io/heroku/logplex_frames
```