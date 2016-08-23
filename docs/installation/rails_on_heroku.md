# Rails on Heroku Installation Instructions

If your Rails app is on Heroku, you'll want to take advantage of the Heroku logplex. This allows you to efficiently write your logs to STDOUT while Heroku handles transport of your logs to Timber.

## 1. Install the gem

Add timber to your Gemfile:

```
gem 'timber-ruby'
```

## 2. Add the logger to your environment files:

```ruby
# config/environments/production.rb (or staging, etc)
config.logger = Timber::Logger.new(Timber::LogDevices::HerokuLogplex.new))
```

For advanced options, such as formatting, see the [Timber::LogDevices::HerokuLogplex docs](http://www.rubydoc.info/github/timberio/timber-ruby/master/Timber/LogDevices/HerokuLogplex).

## 3. Setup your log drain

```console
$ heroku drains:add https://<your-timber-api-key>@api.timber.io/heroku/logplex_frames \
  --app=<my-app-name>
```

* Replace `<your-timber-api-key>` with your actual key. You can obtain it [here](https://timber.io).
* Replace `<my-app-name>` with your heroku app name.