# 🌲 Timber - Simple Ruby Structured Logging

[![ISC License](https://img.shields.io/badge/license-ISC-ff69b4.svg)](LICENSE.md)
[![Build Status](https://travis-ci.org/timberio/timber-ruby.svg?branch=master)](https://travis-ci.org/timberio/timber-ruby)
[![Build Status](https://travis-ci.org/timberio/timber-ruby.svg?branch=master)](https://travis-ci.org/timberio/timber-ruby)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)
[![View docs](https://img.shields.io/badge/docs-viewdocs-blue.svg?style=flat-square "Viewdocs")](http://www.rubydoc.info/github/timberio/timber-ruby)

* [Timber website](https://timber.io)
* [Timber docs](https://timber.io/docs)
* [Library docs](http://www.rubydoc.info/github/timberio/timber-ruby)
* [Support](mailto:support@timber.io)


## Overview

Timber solves ruby structured logging so you don't have to. Go from raw text logs to rich
structured events in seconds. Spend more time focusing on your app and less time
focusing on logging.

1. **Easy setup.** - `bundle exec timber install`, [get setup in seconds](#installation).

2. **Automatically structures yours logs.** - Third-party and in-app logs are all structured
   in a consistent format. See [how it works](#how-it-works) below.

3. **Seamlessly integrates with popular libraries and frameworks.** - Rails, Rack, Devise,
   Omniauth, etc. [Automatically captures user context, HTTP context, and event data.](#third-party-integrations)

4. **Pairs with a modern console.** - Designed specifically for this librariy, hosted, instantly
   usable, zero configuration. [Checkout the docs](https://timber.io/docs/app/overview/).


## Installation

1. In `Gemfile`, add the `timber` gem:

    ```ruby
    gem 'timber', '~> 2.0'
    ```

2. In your `shell`, run `bundle install`

3. In your `shell`, run `bundle exec timber install`


## How it works

Let's start with an example. Timber turns this:

```
Sent 200 in 45.2ms
```

Into a rich [`http_server_response` event](https://timber.io/docs/ruby/events-and-context/http-server-response-event/).

```
Sent 200 in 45.2ms @metadata {"dt": "2017-02-02T01:33:21.154345Z", "level": "info", "context": {"http": {"method": "GET", "path": "/path", "remote_addr": "192.32.23.12", "request_id": "abcd1234"}, "system": {"hostname": "1.server.com", "pid": "254354"}, "user": {"id": 1, "name": "Ben Johnson", "email": "bens@email.com"}}, "event": {"http_server_response": {"status": 200, "time_ms": 45.2}}}
```

Notice that instead of completely replacing your log messages,
Timber _augments_ your logs with structured metadata. Turning turns them into
[rich events with context](https://timber.io/docs/ruby/events-and-context) without sacrificing
readability. And you have [complete control over which data is captured](#configuration).

This is all accomplished by using the
[Timber::Logger](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Logger):

```ruby
logger = Timber::Logger.new(STDOUT)
logger.info("Sent 200 in 45.2ms")
```

Here's a better look at the metadata:

```json
{
  "dt": "2017-02-02T01:33:21.154345Z",
  "level": "info",
  "context": {
    "http": {
      "method": "GET",
      "path": "/path",
      "remote_addr": "192.32.23.12",
      "request_id": "abcd1234"
    },
    "system": {
      "hostname": "1.server.com",
      "pid": "254354"
    },
    "user": {
      "id": 1,
      "name": "Ben Johnson",
      "email": "bens@email.com"
    },
  },
  "event": {
    "http_server_response": {
      "status": 200,
      "time_ms": 45.2
    }
  }
}
```

This structure isn't arbitrary either, it follows the
[simple log event JSON schema](https://github.com/timberio/log-event-json-schema), which
formalizes the data structure, creates a contract with downstream consumers, and
improves stability.

So what can you do with this data?

1. [**Tail a user** - `user.id:1`](https://timber.io/docs/app/tutorials/tail-a-user/)
2. [**Trace a request** - `http.request_id:abcd1234`](https://timber.io/docs/app/tutorials/view-in-request-context/)
3. **Narrow by host** - `system.hostname:1.server.com`
4. **View slow responses** - `http_server_response.time_ms:>=1000`
5. **Filter by log level** - `level:error`
6. **Quickly find exceptions** - `is:exception`

For a complete overview, see the [Timber for Ruby docs](https://timber.io/docs/ruby/overview/).


## Third-party integrations

1. **Rails**: Structures ([HTTP requests](https://timber.io/docs/ruby/events-and-context/http-server-request-event/), [HTTP respones](https://timber.io/docs/ruby/events-and-context/http-server-response-event/), [controller calls](https://timber.io/docs/ruby/events-and-context/controller-call-event/), [template renders](https://timber.io/docs/ruby/events-and-context/template-render-event/), and [sql queries](https://timber.io/docs/ruby/events-and-context/sql-query-event/)).
2. **Rack**: Structures [exceptions](https://timber.io/docs/ruby/events-and-context/exception-event/), captures [HTTP context](https://timber.io/docs/ruby/events-and-context/http-context/), captures [user context](https://timber.io/docs/ruby/events-and-context/user-context/), captures [session context](https://timber.io/docs/ruby/events-and-context/session-context/).
3. **Devise, Omniauth, Clearance**: captures [user context](https://timber.io/docs/ruby/events-and-context/user-context/)
5. **Heroku**: Captures [release context](https://timber.io/docs/ruby/events-and-context/release-context/) via [Heroku dyno metadata](https://devcenter.heroku.com/articles/dyno-metadata).

...and more. Timber will continue to evolve and support more libraries.


## Usage

<details><summary><strong>Basic logging</strong></summary><p>

Use the `Timber::Logger` just like you would `::Logger`:

```ruby
logger = Timber::Logger.new(STDOUT)
logger.info("My log message") # use warn, error, debug, etc.

# => My log message @metadata {"level": "info", "context": {...}}
```

---

</p></details>

<details><summary><strong>Custom events</strong></summary><p>

Custom events allow you to extend beyond events already defined in
the [`Timber::Events`](lib/timber/events) namespace.

```ruby
logger = Timber::Logger.new(STDOUT)
logger.warn "Payment rejected", payment_rejected: {customer_id: "abcd1234", amount: 100, reason: "Card expired"}

# => Payment rejected @metadata {"level": "warn", "event": {"payment_rejected": {"customer_id": "abcd1234", "amount": 100, "reason": "Card expired"}}, "context": {...}}
```

* Notice the `:payment_rejected` root key. Timber will classify this event as such.
* In the [Timber console](https://app.timber.io) use the query: `type:payment_rejected` or `payment_rejected.amount:>100`.
* See more details on our [custom events docs page](https://timber.io/docs/ruby/custom-events/)

---

</p></details>

<details><summary><strong>Custom contexts</strong></summary><p>

Context is additional data shared across log lines. Think of it like log join data.
This is how a query like `context.user.id:1` can show you all logs generated by that user.
Custom contexts allow you to extend beyond contexts already defined in
the [`Timber::Contexts`](lib/timber/contexts) namespace.

```ruby
logger = Timber::Logger.new(STDOUT)
logger.with_context(build: {version: "1.0.0"}) do
  logger.info("My log message")
end

# => My log message @metadata {"level": "info", "context": {"build": {"version": "1.0.0"}}}
```

* Notice the `:build` root key. Timber will classify this context as such.
* In the [Timber console](https://app.timber.io) use queries like: `build.version:1.0.0`
* See more details on our [custom contexts docs page](https://timber.io/docs/ruby/custom-contexts/)

---

</p></details>

<details><summary><strong>Metrics & Timings</strong></summary><p>

Aggregates destroy details, and with Timber capturing metrics and timings is just logging events.
Timber is built on modern big-data principles, it can calculate aggregates across terrabytes of
data in seconds. Don't reduce the quality of your data because the system processing
your data is limited.

Here's a timing example. Notice how Timber automatically calculates the time and adds the timing
to the message.

```ruby
logger = Timber::Logger.new(STDOUT)
timer = Timber::Timer.start
# ... code to time ...
logger.info("Processed background job", background_job: {time_ms: timer})

# => Processed background job in 54.2ms @metadata {"level": "info", "event": {"background_job": {"time_ms": 54.2}}}
```

Or capture any metric you want:

```ruby
logger = Timber::Logger.new(STDOUT)
logger.info("Credit card charged", credit_card_charge: {amount: 123.23})

# => Credit card charged @metadata {"level": "info", "event": {"credit_card_charge": {"amount": 123.23}}}
```

In Timber you can easily sum, average, min, and max the `amount` attribute across any interval
you desire.

</p></details>


## Configuration

Below are a few popular configuration options, for a comprehensive list, see
[Timber::Config](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config).

<details><summary><strong>Logrageify. Silence noisy logs (sql query, template renders)</strong></summary><p>

Timber allows you to silence noisy logs that aren't of value to you, just like
[lograge](https://github.com/roidrage/lograge). In fact, we've provided a convenience method
for anyone transitioning from lograge:

```ruby
# config/initializers/timber.rb

config = Timber::Config.instance
config.logrageify!()
```

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
parameters passed to the controller, which is very valuable when debugging.

For a full list of integrations and settings, see
[Timber::Integrations](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Integrations)

---

</p></details>

<details><summary><strong>Silence specific requests (LB health checks, etc)</strong></summary><p>

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

<details><summary><strong>Change log formats</strong></summary><p>

Simply set the formatter like you would with any other logger:

```ruby
# This is set in your various environment files
logger = Timber::Logger.new(STDOUT)
logger.formatter = Timber::Logger::JSONFormatter.new
```

Your options are:

1. [`Timber::Logger::AugmentedFormatter`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Logger/AugmentedFormatter) -
   (default) A human readable format that _appends_ metadata to the original log line. The Timber
   service can parse this data appropriately.
   Ex: `My log message @metadata {"level":"info","dt":"2017-01-01T01:02:23.234321Z"}`

2. [`Timber::Logger::JSONFormatter`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Logger/JSONFormatter) -
   Ex: `{"level":"info","message":"My log message","dt":"2017-01-01T01:02:23.234321Z"}`

3. [`Timber::Logger::MessageOnlyFormatter`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Logger/MessageOnlyFormatter) -
   For use in development / test. Prints logs as strings with no metadata attached.
   Ex: `My log message`

---

</p></details>

<details><summary><strong>Capture custom user context</strong></summary><p>

By default Timber automatically captures user context for most of the popular authentication
libraries (Devise, Omniauth, and Clearance). See
[Timber::Integrations::Rack::UserContext](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Integrations/Rack/UserContext)
for a complete list.

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
tracks the current application release and version. If you're on Heroku, simply enable the
[dyno metadata](https://devcenter.heroku.com/articles/dyno-metadata) feature. If you are not,
set the following environment variables and this context will be added automatically:

1. `RELEASE_COMMIT` - Ex: `2c3a0b24069af49b3de35b8e8c26765c1dba9ff0`
2. `RELEASE_CREATED_AT` - Ex: `2015-04-02T18:00:42Z`
3. `RELEASE_VERSION` - Ex: `v2.3.1`

All variables are optional, but at least one must be present.

---

</p></details>


## Jibber-Jabber

<details><summary><strong>Which events and contexts does Timber capture for me?</strong></summary><p>

Out of the box you get everything in the
[`Timber::Events`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Events) namespace.

We also add context to every log, everything in the
[`Timber::Contexts`](http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Contexts)
namespace. Context is structured data representing the current environment when the log line
was written. It is included in every log line. Think of it like join data for your logs. It's
how Timber is able to accomplished tailing users (`context.user.id:1`).

Lastly, you can checkout how we capture these events in
[`Timber::Integrations`](lib/timber/integrations).

---

</p></details>

<details><summary><strong>Won't this increase the size of my log data?</strong></summary><p>

Yes. In terms of size, it's no different than adding tags to your logs or any other useful
data. A few things to point out though:

1. Timber generally _reduces_ the amount of logs your app generates by providing options to
   consolidate request / response logs, template logs, and even silence logs that are not
   of value to you. (see [configuration](#configuration) for examples).
2. Your log provider should be compressing your data and charging you accordingly. Log data
   is notoriously repetitive, and the context Timber generates is repetitive as well.
   Because of compression we've seen somes apps only incur a 10% increase in data size.

Finally, log what is useful to you. Quality over quantity certainly applies to logging.

---

</p></details>

<details><summary><strong>What about my current log statements?</strong></summary><p>

They'll continue to work as expected. Timber adheres to the default `::Logger` interface.
Your previous logger calls will work as they always do. Just swap in `Timber::Logger` and
you're good to go.

In fact, traditional log statements for non-meaningful events, debug statements, etc, are
encouraged. In cases where the data is meaningful, consider [logging a custom event](#usage).

---

</p></details>

---

<p align="center" style="background: #221f40;">
<a href="http://github.com/timberio/timber-elixir"><img src="http://files.timber.io/images/ruby-library-readme-log-truth.png" height="947" /></a>
</p>