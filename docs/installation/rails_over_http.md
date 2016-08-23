# Rails Over HTTP Installation Instructions

The quickest and easiesy way to get up and running with Timber. No agent to install, deploy and go!

## 1. Install the gem

Add timber to your Gemfile:

```
gem 'timber-ruby'
```

## 2. Add the logger to your environment files:

```ruby
# config/environments/production.rb (or staging, etc)
config.logger = Timber::Logger.new(Timber::LogDevices::HTTP.new(ENV['TIMBER_KEY'])))
```

* You can obtain your Timber API key [here](https://timber.io).
* If you set `ENV['TIMBER_KEY']`, you do not have to pass it as an argument.
* The `Timber::Logger.new` function handles instantiating the Rails logger properly for your Rails version, including wrapping the logger in `ActiveSupport::TaggedLogger.new`.