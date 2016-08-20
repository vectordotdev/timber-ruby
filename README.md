# Timber.io - Ruby Gem - Powerful Ruby Logging

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://res.cloudinary.com/timber/image/upload/c_scale,w_537/v1464797600/how-it-works_sfgfjp.gif" /></a>
</p>

[![CircleCI](https://circleci.com/gh/timberio/timber-ruby.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/timberio/timber-ruby/tree/master)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)

**Note: Timber is in alpha testing, if interested in joining, please visit http://timber.io**


[Timber](http://timber.io) is a different kind of logging platform; it goes beyond traditional logging by enriching your logs with context. Turning them into rich structured events without altering the essence of logging. See for yourself at [timber.io](http://timber.io).

## Install

### 1. Get your API key

You can obtain your API key by signing up at [timber.io](http://timber.io).

*Note: Timber looks for the `TIMBER_KEY` environment variable. If set, you do not need to explicitly pass the key as shown below.*

### 2. Install the gem

Add timber to your Gemfile:

```
gem 'timber-ruby'
```

### 3. Choose a log transport strategy

Timber allows you to choose how you want to log your data. In your environment configuration files (ex: `config/environments/production.rb`) copy any of the following examples:

#### Heroku

```ruby
# config/environments/production.rb (or staging, etc)
config.logger = ::ActiveSupport::TaggedLogging.new(::ActiveSupport::Logger.new(Timber::LogDevices::HerokuLogplex.new))
```

Now add the log drain:

```
$ heroku drains:add https://<application-id>:<api-key>@api.timber.io/heroku/logplex_frames
```

*the `<application-id>` and `<api-key>` can be obtained [here](https://timber.io)*

#### HTTP

```ruby
# config/environments/production.rb (or staging, etc)
config.logger = ::ActiveSupport::TaggedLogging.new(::ActiveSupport::Logger.new(Timber::LogDevices::HTTP.new(ENV['TIMBER_KEY']))) # Passing the ENV['TIMBER_KEY'] is optional, showing it for explicitness
```

#### IO (STDOUT, STDERR, files, etc.)

The IO format will write to anything that responds to the `#write` method.

```ruby
# config/environments/production.rb (or staging, etc)
config.logger = ::ActiveSupport::TaggedLogging.new(::ActiveSupport::Logger.new(Timber::LogDevices::IO.new(STDOUT)))
```
