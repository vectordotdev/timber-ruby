# Timber

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://files.timber.io/images/ruby-library-readme-header.gif" height="469" /></a>
</p>

[![CircleCI](https://circleci.com/gh/timberio/timber-ruby.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/timberio/timber-ruby/tree/master)
[![Coverage Status](https://coveralls.io/repos/github/timberio/timber-ruby/badge.svg?branch=master)](https://coveralls.io/github/timberio/timber-ruby?branch=master)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)
[![View docs](https://img.shields.io/badge/docs-viewdocs-blue.svg?style=flat-square "Viewdocs")](http://www.rubydoc.info/github/timberio/timber-ruby)


1. [What is timber?](#what-is-timber)
2. [Why timber?](#why-timber)
3. [How does it work?](#how-does-it-work)
4. [Logging Custom Events](#logging-custom-events)
5. [The Timber Console / Pricing](#the-timber-console-pricing)
6. [Install](#install)


## What is Timber?

Glad you asked! :) Timber takes a different approach to logging, in that it automatically
enriches and structures your logs without altering the essence of your original log messages.
Giving you the best of both worlds: human readable logs *and* rich structured data.

And it does so with absolutely no lock-in or risk of code debt. It's just good ol' loggin'™!
For example:

1. The resulting log format, by deafult, is a simple, non-proprietary, JSON structure.
   (see [How does it work?](#how-does-it-work) for an example).
2. The [`Timber::Logger`](lib/timber/events) class extends `Logger`, and will never change or
   extend the public API. Allowing you to switch back to your previous `Logger` seamlessly.
3. Where you send your logs is entirely up to you, but we hope you'll check out
   [timber.io](https://timber.io). We've built a beautiful, modern, and fast console specifically
   for the strutured data captured here.


## Why Timber?

Timber’s philosophy is that application insight should be open and owned by you. It should not
require a myriad of services to accomplish. And there is no better vehicle than logging:

1. The log is immutable and complete. [It is the truth](http://files.timber.io/images/log-is-the-truth.png) :)
2. It’s a shared practice that has been around since the dawn of computers.
3. It’s baked into every language, library, and framework. Even your own apps!
4. The data is open, accessible, and entirely owned by you. Yay!

The problem is that logs are unstructured, noisy, and hard to use. `grep` can only take you so
far! Timber solves this by properly structuring your logs, making them easy to search and
visualize -- allowing you to sanely realize the power of your logs.


## How does it work?

Timber automatically structures your logs by taking advantage of public APIs.

For example, by subscribing to `ActiveSupport::Notifications`, Timber can automatically turn this:

```
Completed 200 OK in 117ms (Views: 85.2ms | ActiveRecord: 25.3ms)
```

Into this:

```json
{
  "dt": "2016-12-01T02:23:12.236543Z",
  "level": "info",
  "message": "Completed 200 OK in 117ms (Views: 85.2ms | ActiveRecord: 25.3ms)",
  "context": {
    "http": {
      "method": "GET",
      "path": "/checkout",
      "remote_addr": "123.456.789.10",
      "request_id": "abcd1234"
    },
    "user": {
      "id": 2,
      "name": "Ben Johnson",
      "email": "ben@johnson.com"
    }
  },
  "event": {
    "http_response": {
      "status": 200,
      "time_ms": 117
    }
  }
}
```

It does the same for `http requests`, `sql queries`, `exceptions`, `template renderings`,
and any other event your framework logs. (for a full list see [`Timber::Events`](lib/timber/events))


## Logging Custom Events

> Another service? More lock-in? :*(

Nope! Logging custom events is Just Logging™. Check it out:

```ruby
# Simple string (original Logger interface remains untouched)
Logger.warn "Payment rejected for customer abcd1234, reason: Card expired"

# Structured hash
Logger.warn message: "Payment rejected", type: :payment_rejected,
  data: %{customer_id: "abcd1234", amount: 100, reason: "Card expired"}

# Using a Struct
PaymentRejectedEvent = Struct.new(:customer_id, :amount, :reason) do
  def message; "Payment rejected for #{customer_id}"; end
  def type; :payment_rejected; end
end
Logger.warn PaymentRejectedEvent.new("abcd1234", 100, "Card expired")
```

(for more examples, see [the `Timber::Logger` docs](lib/timber/logger.rb))

No mention of Timber anywhere!


## The Timber Console / Pricing

> This is all gravy, but wouldn't the extra data get expensive?

If you opt use the [Timber Console](https://timber.io), we only charge for
the size of the `message`, `dt`, and `event.custom` attributes. Everything else is
stored at no cost to you. [Say wha?!](http://i.giphy.com/l0HlL2vlfpWI0meJi.gif). This ensures
pricing remains predictable. We charge per GB sent to us and retained. No user limits,
no weird feature matrixes, just data. Finally, the data is yours, in a simple
non-proprietary JSON format that you can export to S3, Redshift, or any of our other integrations.

For more details checkout out [timber.io](https://timber.io).

## Install

### 1. Install the gem:

```ruby
# Gemfile
gem 'timber'
```

### 2. Install the logger:

#### Heroku:

```ruby
# config/environments/production.rb (or staging, etc)
config.logger = Timber::Logger.new(STDOUT)
```

The command to add your log drain will be displayed in the [Timber app](https://app.timber.io)
after you add your application.

#### Non-Heroku:

```ruby
# config/environments/production.rb (or staging, etc)
log_device = Timber::LogDevices::HTTP.new(ENV['TIMBER_KEY']) # key can be obtained by signing up at https://timber.io
config.logger = Timber::Logger.new(log_device)
```

Your Timber application key will be displayed in the [Timber app](https://app.timber.io)
after you add your application.


*Other transport methods coming soon!*


#### Rails TaggedLogging?

No probs! Use it as normal, Timber will even pull out the tags and include them in the `context`.

```ruby
config.logger = ActiveSupport::TaggedLogging.new(Timber::Logger.new(STDOUT))
```

**Warning**: Tags lack meaningful descriptions, they are a poor mans context. Not to worry though!
Timber provides a simple system for adding custom context that you can optionally use. Checkout
[the `Timber::CurrentContext` docs](lib/timber/current_context.rb) for examples.

---

That's it! Log to your heart's content.

For documentation on logging structured events, and other features,
checkout [the docs](http://thedocs.com/). For more information on Timber visit [timber.io](https://timber.io).
