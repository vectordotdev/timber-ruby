# Timber

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://files.timber.io/images/ruby-library-readme-header.gif" height="469" /></a>
</p>

[![CircleCI](https://circleci.com/gh/timberio/timber-ruby.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/timberio/timber-ruby/tree/master)
[![Coverage Status](https://coveralls.io/repos/github/timberio/timber-ruby/badge.svg?branch=master)](https://coveralls.io/github/timberio/timber-ruby?branch=master)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)
[![View docs](https://img.shields.io/badge/docs-viewdocs-blue.svg?style=flat-square "Viewdocs")](http://www.rubydoc.info/github/timberio/timber-ruby)


**Timber is in beta testing. If interested, please email beta@timber.io**


1. [What is timber?](#what-is-timber)
2. [How it works](#how-it-works)
3. [Why timber?](#why-timber)
4. [Logging Custom Events](#logging-custom-events)
5. [The Timber Console / Pricing](#the-timber-console--pricing)
6. [Install](#install)


## What is Timber?

Using your logs shouldn't be a time consuming, frustrating process! If you were like us, it goes
something like this:

> I need to centralize my logs, where should I send them? Which provider should I use?
> Wow, this is expensive. Why is searching so difficult and time consuming?
> Would structuring my logs help? Which format should I use? Will they still be human readable?
> What if the structure changes? What about logs from 3rd party libraries? Ahhh!!!

Timber solves this by providing a complete, managed, end-to-end logging solution that marries
a beautiful, *fast*, console with libraries that automatically structure and enrich your logs.


## How it works

The Timber ruby library takes care of all of the log structuring madness. For example,
it turns this Rails log line:

```
Completed 200 OK in 117ms (Views: 85.2ms | ActiveRecord: 25.3ms)
```

Into this:

```javascript
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
    "user": {  // <---- http://i.giphy.com/EldfH1VJdbrwY.gif
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

Notice we preserve the original log message. When viewing this event in the
[Timber Console](https://timber.io), you'll see the simple, human readable line with the
ability to view, and use, the attached structured data! Also, notice how rich the event is.
Beecause we're inside your application, we can capture data beyond what's in the log line.

(for a full list see [`Timber::Events`](lib/timber/events))


## Why Timber?

Glad you asked! :)

1. Human readable logs *and* rich structured data. You don't have to choose.
2. Data beyond what's in the log line itself making your logs exceptionally useful.
3. Normalized log data. Timber enforces a strict schema, meaning your log data, across all apps
   and languages will be normalized.
4. Absolutely no lock-in or risk of code debt. No fancy API, no proprietary data format locked
   away in our servers, Timber is just good ol' loggin'.
5. Fully managed, all the way from the log messages to the console you use. No fragile parsing
   rules or complicated interfaces.


## Logging Custom Events

> Another service? More lock-in? :*(

Nope! Logging custom events is Just Logging™. Check it out:

```ruby
# Simple string (original Logger interface remains untouched)
Logger.warn "Payment rejected for customer abcd1234, reason: Card expired"

# Structured hash
Logger.warn message: "Payment rejected", type: :payment_rejected,
  data: {customer_id: "abcd1234", amount: 100, reason: "Card expired"}

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

> What good is structured log data if you can't search and visualize it?

The [Timber Console](https://timber.io) is *fast*, modern, and beautiful console designed
specifically for this library.

A few example queries:

  1. `context.user.email:ben@johnson.com` - Tail a specific user!
  2. `context.http.request_id:1234` - View *all* logs for a given HTTP request!
  3. `event.http_reponse.time_ms>3000` - Easily find outliers and have the proper context to resolve them!
  4. `level:warn` - Log levels in your logs. Imagine that!

> This is all gravy, but wouldn't the extra data get expensive?

If you opt to use the [Timber Console](https://timber.io), we only charge for
the size of the `message`, `dt`, and `event.custom` attributes. Everything else is
stored at no cost to you. [Say wha?!](http://i.giphy.com/l0HlL2vlfpWI0meJi.gif). This ensures
pricing remains predictable. We charge per GB sent to us and retained. No user limits,
no weird feature matrixes, just data. Finally, the data is yours, in a simple
non-proprietary JSON format that you can export to S3, Redshift, or any of our other integrations.

For more details checkout out [timber.io](https://timber.io).

## Install

**Timber is in beta testing. If interested, please email beta@timber.io**

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

---

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://files.timber.io/images/ruby-library-readme-log-truth.png" height="947" /></a>
</p>
