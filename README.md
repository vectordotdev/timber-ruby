# 🌲 Timber - Great Ruby Logging Made Easy

[![ISC License](https://img.shields.io/badge/license-ISC-ff69b4.svg)](LICENSE.md)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/timberio/timber-ruby)
[![Build Status](https://travis-ci.org/timberio/timber-ruby.svg?branch=master)](https://travis-ci.org/timberio/timber-ruby)

## Overview

Timber for Ruby is a drop-in solution for your noisy Ruby logs, turning them into insanely useful
events with context. It pairs with the [Timber console](#the-timber-console) to help you solve problems *faster* and produce higher quality apps. Never feel left in the dark wondering if your app is performing well for your users.

1. [**Easy setup** - `bundle exec timber install`](#installation)
2. [**Seamlessly integrates with popular libraries and frameworks**](#integrations)
3. [**Do amazing things with your Ruby logs**](#do-amazing-things-with-your-logs)


## Installation

1. In your `Gemfile`, add the `timber` gem:

    ```ruby
    gem 'timber', '~> 2.1'
    ```

2. In your `shell`, run `bundle install`

3. In your `shell`, run `bundle exec timber install`


## How it works

Timber works by
[unobtrusively structuring your logs through augmentation](https://timber.io/docs/concepts/structuring-through-augmentation),
which is a fancy way of saying Timber _appends_ structured data to your original log messages
instead of replacing them all together. This makes your logs enjoyable to read (and use!) while
[still offering rich structured data when you need it](https://timber.io/docs/app/console/view-metadata-and-context).
It does this automatically by replacing your logger and
[integrating with popular frameworks and libraries](#integrations). When paired with the
[Timber console](#the-timber-console) it creates a highly productive custom tailored logging
experience conducive for Ruby app development.


## Usage

<details><summary><strong>Basic logging</strong></summary><p>

Use the `Timber::Logger` just like you would `::Logger`:

```ruby
logger.debug("Debug message")
logger.info("Info message")
logger.warn("Warn message")
logger.error("Error message")
logger.fatal("Fatal message")
```

We encourage standard / traditional log messages for non-meaningful events. And because Timber
[augments](https://timber.io/docs/concepts/structuring-through-augmentation) your logs with
metadata, you don't have to worry about making every log structured!

---

</p></details>

<details><summary><strong>Logging events (structured data)</strong></summary><p>

Logging events allows you to log structured data without sacrificing readability or worrying about
structured data name or type conflicts. Keep in mind, Timber defines common events in the
[`Timber::Events`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Events) namespace,
which are automatically logged for you through our [integrations](#integrations). You should not
have to maually log events defined there except in special circumstances.

### How to use it

```ruby
logger.warn "Payment rejected", payment_rejected: {customer_id: "abcd1234", amount: 100, reason: "Card expired"}
```

1. [Search it](https://timber.io/docs/app/console/searching) with queries like: `type:payment_rejected` or `payment_rejected.amount:>100`
2. [Alert on it](https://timber.io/docs/app/console/alerts) with threshold based alerts
3. [Graph & visualize it](https://timber.io/docs/app/console/graphing)
4. [View this event's data and context](https://timber.io/docs/app/console/view-metdata-and-context)
5. ...read more in our [docs](https://timber.io/docs/languages/ruby/usage/custom-events)

---

</p></details>

<details><summary><strong>Setting context</strong></summary><p>

Context is amazingly powerful, think of it like join data for your logs. It represents the
environment when the log was written, allowing you to relate logs so you can easily segment them.
It's how Timber is able to accomplish features like
[tailing users](https://timber.io/docs/app/console/tail-a-user) and
[tracing HTTP requests](https://timber.io/docs/app/console/trace-http-requests).
Keep in mind, Timber defines common contexts in the
[`Timber::Contexts`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Contexts) namespace,
which are automatically set for you through our [integrations](#integrations). You should not
have to maually set these contexts except in special circumstances.

### How to use it

```ruby
logger.with_context(job: {id: 123}) do
  logger.info("Background job execution started")
  # ... code here
  logger.info("Background job execution completed")
end
```

1. [Search it](https://timber.io/docs/app/console/searching) with queries like: `job.id:123`
2. [View this context when viewing a log's metadata](https://timber.io/docs/app/console/view-metdata-and-context)
3. ...read more in our [docs](https://timber.io/docs/languages/ruby/usage/custom-context)

---

</p></details>

<details><summary><strong>Metrics & Timings</strong></summary><p>

Aggregates destroy details, events tell stories. With Timber, logging metrics and timings is simply
[logging an event](https://timber.io/docs/languages/ruby/usage/custom-events). Timber is based on
modern big-data principles and can aggregate inordinately large data sets in seconds. Logging
events (raw data as it exists), gives you the flexibility in the future to segment and aggregate
your data any way you see fit. This is superior to choosing specific paradigms before hand, when
you are unsure how you'll need to use your data in the future.

### How to use it

Below is a contrived example of timing a background job:

```ruby
timer = Timber::Timer.start
# ... code to time ...
logger.info("Processed background job", background_job: {time_ms: timer})
```

And of course, `time_ms` can also take a `Float` or `Fixnum`:

```ruby
logger.info("Processed background job", background_job: {time_ms: 45.6})
```

Lastly, metrics aren't limited to timings. You can capture any metric you want:

```ruby
logger.info("Credit card charged", credit_card_charge: {amount: 123.23})
```

1. [Search it](https://timber.io/docs/app/console/searching) with queries like: `background_job.time_ms:>500`
2. [Alert on it](https://timber.io/docs/app/console/alerts) with threshold based alerts
3. [View this log's metadata in the console](https://timber.io/docs/app/console/view-metdata-and-context)
4. ...read more in our [docs](https://timber.io/docs/languages/ruby/usage/metrics-and-timings)


</p></details>


## Configuration

Below are a few popular configuration options, for a comprehensive list, see
[Timber::Config](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config).

<details><summary><strong>Logrageify. Silence noisy logs.</strong></summary><p>

Timber allows you to silence noisy logs that aren't of value to you, just like
[lograge](https://github.com/roidrage/lograge). As such, we've provided a convenience configuration
option for anyone transitioning from lograge.

### How to use it

```ruby
# config/initializers/timber.rb

config = Timber::Config.instance
config.logrageify!()
```

### How it works

It turns this:

```
Started GET "/" for 127.0.0.1 at 2012-03-10 14:28:14 +0100
Processing by HomeController#index as HTML
  Rendered text template within layouts/application (0.0ms)
  Rendered layouts/_assets.html.erb (2.0ms)
  Rendered layouts/_top.html.erb (2.6ms)
  Rendered layouts/_about.html.erb (0.3ms)
  Rendered layouts/_google_analytics.html.erb (0.4ms)
Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
```

Into this:

```
Get "/" sent 200 OK in 79ms @metadata {...}
```

Internally this is equivalent to:

```ruby
# config/initializers/timber.rb

config = Timber::Config.instance
config.integrations.action_controller.silence = true
config.integrations.action_view.silence = true
config.integrations.active_record.silence = true
config.integrations.rack.http_events.collapse_into_single_event = true
```

### Pro-tip: Keep controller call logs (recommended)

Feel free to deviate and customize which logs you silence. We recommend a slight deviation
from lograge with the following settings:

```ruby
# config/initializers/timber.rb

config = Timber::Config.instance
config.integrations.action_view.silence = true
config.integrations.active_record.silence = true
config.integrations.rack.http_events.collapse_into_single_event = true
```

This does _not_ silence the controller call log event. This is because Timber captures the
parameters passed to the controller, which are generally valuable when debugging.

For a full list of integration settings, see
[Timber::Config::Integrations](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config/Integrations)

---

</p></details>

<details><summary><strong>Silence specific requests (LB health checks, etc)</strong></summary><p>

Silencing noisy requests can be helpful for silencing load balance health checks, bot scanning,
or activity that generally is not meaningful to you.

### How to use it

The following will silence all `[GET] /_health` requests:

```ruby
# config/initializers/timber.rb

config = Timber::Config.instance
config.integrations.rack.http_events.silence_request = lambda do |rack_env, rack_request|
  rack_request.path == "/_health"
end
```

We require a block because it gives you complete control over how you want to silence requests.
The first parameter being the traditional Rack env hash, the second being a
[Rack Request](http://www.rubydoc.info/gems/rack/Rack/Request) object.

---

</p></details>

<details><summary><strong>Capture custom user context</strong></summary><p>

By default Timber automatically captures user context for most of the popular authentication
libraries (Devise, Omniauth, and Clearance). See
[Timber::Integrations::Rack::UserContext](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Integrations/Rack/UserContext)
for a complete list.

### How to use it

In cases where you Timber doesn't support your strategy, or you want to customize it further,
you can do so like:

```ruby
# config/initializers/timber.rb

config = Timber::Config.instance
config.integrations.rack.user_context.custom_user_hash = lambda do |rack_env|
  user = rack_env['warden'].user
  if user
    {
      id: user.id, # unique identifier for the user, can be an integer or string,
      name: user.name, # identifiable name for the user,
      email: user.email, # user's email address
    }
  else
    nil
  end
end
```

*All* of the user hash keys are optional, but you must provide at least one.

---

</p></details>

<details><summary><strong>Capture release / deploy context</strong></summary><p>

[Timber::Contexts::Release](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Contexts/Release)
tracks the current application release and version.

### How to use it

If you're on Heroku, simply enable the
[dyno metadata](https://devcenter.heroku.com/articles/dyno-metadata) feature. If you are not,
set the following environment variables and this context will be added automatically:

1. `RELEASE_COMMIT` - Ex: `2c3a0b24069af49b3de35b8e8c26765c1dba9ff0`
2. `RELEASE_CREATED_AT` - Ex: `2015-04-02T18:00:42Z`
3. `RELEASE_VERSION` - Ex: `v2.3.1`

All variables are optional, but at least one must be present.

---

</p></details>


## Integrations

[Timber for Ruby](https://github.com/timberio/timber-ruby) extends beyond your basic logging
functionality and integrates with popular libraries and frameworks. This makes structured quality
logging effortless. Below is a list of integrations we offer and the various events and contexts
they create.

1. [**Rails**](https://timber.io/docs/languages/ruby/integrations/rails)
2. [**Rack**](https://timber.io/docs/languages/ruby/integrations/rack)
3. [**Heroku**](https://timber.io/docs/languages/ruby/integrations/heroku)
4. [**Devise**](https://timber.io/docs/languages/ruby/integrations/devise)
5. [**Clearance**](https://timber.io/docs/languages/ruby/integrations/clearnace)
6. [**Omniauth**](https://timber.io/docs/languages/ruby/integrations/omniauth)
7. [**Warden**](https://timber.io/docs/languages/ruby/integrations/devise)
8. ...more coming soon! Make a request by [opening an issue](https://github.com/timberio/timber-ruby/issues/new)


## Do amazing things with your logs

What does all of this mean? Being more productive, solving problems faster, and _actually_ enjoying using your logs for application insight:

1. [**Live tail users on your app**](https://timber.io/docs/app/console/tail-a-user)
2. [**Trace HTTP requests**](https://timber.io/docs/app/console/trace-http-requests)
3. [**Inspect HTTP request parameters**](https://timber.io/docs/app/console/inspect-http-requests)
4. [**Powerful searching**](https://timber.io/docs/app/console/searching)
5. [**Threshold based alerting**](https://timber.io/docs/app/alerts)
6. ...and more! Checkout our [the Timber application docs](https://timber.io/docs/app)


## The Timber Console

[![Timber Console](http://files.timber.io/images/readme-interface7.gif)](https://timber.io/docs/app)

[Learn more about our app.](https://timber.io/docs/app)

## Your Moment of Zen

<p align="center" style="background: #221f40;">
<a href="https://timber.io"><img src="http://files.timber.io/images/readme-log-truth.png" height="947" /></a>
</p>
