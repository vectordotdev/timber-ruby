# :evergreen_tree: Timber - Master your Ruby apps with structured logging

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://files.timber.io/images/ruby-library-readme-header.gif" height="469" /></a>
</p>

[![ISC License](https://img.shields.io/badge/license-ISC-ff69b4.svg)](LICENSE.md)
[![CircleCI](https://circleci.com/gh/timberio/timber-ruby.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/timberio/timber-ruby/tree/master)
[![Coverage Status](https://coveralls.io/repos/github/timberio/timber-ruby/badge.svg?branch=master)](https://coveralls.io/github/timberio/timber-ruby?branch=master)
[![Code Climate](https://codeclimate.com/github/timberio/timber-ruby/badges/gpa.svg)](https://codeclimate.com/github/timberio/timber-ruby)
[![View docs](https://img.shields.io/badge/docs-viewdocs-blue.svg?style=flat-square "Viewdocs")](http://www.rubydoc.info/github/timberio/timber-ruby)


---

:point_right: **Timber is in beta testing, if interested in joining, please email us at
[beta@timber.io](mailto:beta@timber.io)**

---

Timber is a complete, fully-managed, logging strategy that you can set up in minutes. It makes
your application logs useful by taking a different, gentler, smarter approach to structured logging.

To learn more, checkout out [timber.io](https://timber.io) or the
["why we built Timber"](http://moss-ibex2.cloudvent.net/blog/why-were-building-timber/)
blog post.


## Overview

<details><summary><strong>How is Timber different?</strong></summary><p>

1. Timber structures your logs from *within* your application using libraries (like this one);
   a fundamental difference from parsing that has [So. Many. Benefits.](http://moss-ibex2.cloudvent.net/blog/why-were-building-timber/)
2. Timber does not alter the original log message. It structures your logs by *augmenting* them
   with metadata. That is, it preserves the original log message and attaches structured data to
   it. This means you get both: structured data *and* human readable logs.
3. All log events adhere to a [normalized, shared, schema](https://github.com/timberio/log-event-json-schema).
   Meaning you can interact with your logs consistently across apps of any language: queries,
   graphs, alerts, and other downstream consumers. They all operate on the same schema.
4. Timber poses no risk of lock-in or code-debt. There is no special client, no special API; Timber
   adheres strictly to the default `::Logger` interface. On the surface, it's just logging.
   And if you choose to stop using Timber, you can do so without having to alter your code.
5. Timber manages the entire logging pipeline. From log creation (libraries like this one) to a
   [beautiful modern console](https://timber.io) designed specifically for this data.
   The whole process is designed to work in harmony.
6. Lastly, Timber offers 6 months of retention by default, at sane prices. The data is encrypted
   in-transit and at-rest, and we guarantee 11 9s of durability. :open_mouth:

---

</p></details>

<details><summary><strong>What does this Timber library do?</strong></summary><p>

1. Automatically captures and structures your framework and 3rd party logs (see next question).
2. Provides a [framework for logging custom structured events](#what-about-custom-events).
3. Offers transport strategies to [send your logs](#send-your-logs) to the Timber service.

---

</p></details>

<details><summary><strong>What events does Timber capture & structure for me?</strong></summary><p>

Out of the box you get everything in the [`Timber::Events`](lib/timber/events) namespace:

1. [Controller Call Event](lib/timber/events/controller_call.rb)
2. [Exception Event](lib/timber/events/exception.rb)
3. [HTTP Client Request Event (net/http outgoing)](lib/timber/events/http_client_request.rb)
4. [HTTP Client Response Event (resposne from net/http outgoing)](lib/timber/events/http_client_response.rb)
5. [HTTP Server Request Event (incoming client request)](lib/timber/events/http_server_request.rb)
6. [HTTP Server Response Event (response to incoming client request)](lib/timber/events/http_server_response.rb)
7. [SQL Query Event](lib/timber/events/sql_query.rb)
8. [Template Render Event](lib/timber/events/template_render.rb)
9. ...more coming soon, [file an issue](https://github.com/timberio/timber-ruby/issues) to request.

We also add context to every log, everything in the [`Timber::Contexts`](lib/timber/contexts)
namespace. Context is structured data representing the current environment when the log line was
written. It is included in every log line. Think of it like join data for your logs:

1. [HTTP Context](lib/timber/contexts/http.rb)
2. [Organization Context](lib/timber/contexts/organization.rb)
3. [Process Context](lib/timber/contexts/process.rb)
4. [Server Context](lib/timber/contexts/server.rb)
5. [Runtime Context](lib/timber/contexts/runtime.rb)
5. [User Context](lib/timber/contexts/user.rb)
6. ...more coming soon, [file an issue](https://github.com/timberio/timber-ruby/issues) to request.

---

</p></details>

<details><summary><strong>What about my current log statements?</strong></summary><p>

They'll continue to work as expected. Timber adheres strictly to the default `::Logger` interface
and will never deviate in *any* way.

In fact, traditional log statements for non-meaningful events, debug statements, etc, are
encouraged. In cases where the data is meaningful, consider [logging a custom event](#usage).

</p></details>

## Usage

<details><summary><strong>Basic logging</strong></summary><p>

Use `Logger` as normal:

```elixir
logger.info("My log message")
```

Timber will never deviate from the public `::Logger` interface in *any* way.

---

</p></details>

<details><summary><strong>Custom events</strong></summary><p>

1. Log a structured Hash (simplest)

  ```ruby
  Logger.warn message: "Payment rejected", type: :payment_rejected,
    data: {customer_id: "abcd1234", amount: 100, reason: "Card expired"}
  ```

2. Log a Struct (recommended)

  Defining structs for your important events just feels oh so good :) It creates a strong contract
  with down stream consumers and gives you compile time guarantees.

  ```ruby
  PaymentRejectedEvent = Struct.new(:customer_id, :amount, :reason) do
    def message; "Payment rejected for #{customer_id}"; end
    def type; :payment_rejected; end
  end
  Logger.warn PaymentRejectedEvent.new("abcd1234", 100, "Card expired")
  ```

* `:type` is how Timber classifies the event, it creates a namespace for the data you send.
* For more advanced examples see [`Timber::Logger`](lib/timber.logger.rb).
* Also, notice there is no mention of Timber in the above code. Just plain old logging.

#### What about regular Hashes, JSON, or logfmt?

Go for it! Timber will parse the data server side, but we *highly* recommend the above examples.
Providing a `:type` allows timber to classify the event, create a namespace for the data you
send, and make it easier to search, graph, alert, etc.

```ruby
logger.info({key: "value"})
logger.info('{"key": "value"}')
logger.info('key=value')
```

---

</p></details>

<details><summary><strong>Custom contexts</strong></summary><p>

Context is structured data representing the current environment when the log line was written.
It is included in every log line. Think of it like join data for your logs. For example, the
`http.request_id` field is included in the context, allowing you to find all log lines related
to that request ID, if desired. This is in contrast to *only* showing log lines that contain this
value.

1. Add a Hash (simplest)

  ```ruby
  Timber::CurrentContext.with({type: :build, data: {version: "1.0.0"}}) do
    logger.info("This message will include the wrapped context")
  end
  ```

  This adds data to the context keyspaced by `build`.

2. Add a Struct (recommended)

  Just like events, we recommend defining your custom contexts. It makes a stronger contract
  with downstream consumers.

  ```ruby
  BuildContext = Struct.new(:version) do
    def type; :build; end
  end
  build_context = BuildContext.new("1.0.0")
  Timber::CurrentContext.with(build_context) do
    logger.info("This message will include the wrapped context")
  end
  ```

</p></details>


## Installation

```ruby
# Gemfile
gem 'timber'
```


## Setup

<details><summary><strong>Rails >= 3.0</strong></summary><p>

*Replace* any existing `config.logger=` calls in `config/environments/production.rb`:

```ruby
# config/environments/production.rb (or staging, etc)

config.logger = ActiveSupport::TaggedLogging.new(Timber::Logger.new(STDOUT))
```

* Prefer examples? Checkout our [Ruby / Rails example app](https://github.com/timberio/ruby-rails-example-app).

---

</p></details>

<details><summary><strong>Other</strong></summary><p>

1. *Insert* the Timber probes:

  This should be executed *immediately after* you have required your dependencies.

  ```ruby
  Timber::Probes.insert!
  ```

2. *Add* the Rack middlewares:

  This should be included where you build your `Rack` application. Usually `config.ru`:

  ```ruby
  # Most likely config.ru

  Timber::RackMiddlewares.middlewares.each do |m|
    use m
  end
  ```

2. *Instantiate* the Timber logger:

  This should be *globally* available to your application:

  ```ruby
  logger = Timber::Logger.new(STDOUT)
  ```

</p></details>


## Send your logs

<details><summary><strong>Heroku (log drains)</strong></summary><p>

The recommended strategy for Heroku is to setup a
[log drain](https://devcenter.heroku.com/articles/log-drains). To get your Timber log drain URL:

**--> [Add your app to Timber](https://app.timber.io)**

---

</p></details>

<details><summary><strong>All other platforms (Network / HTTP)</strong></summary><p>

1. *Use* the Timber Network logger backend in `config/environments/production.rb`:

  ```ruby
  # config/environments/production.rb (or staging, etc)
  network_log_device = Timber::LogDevices::Network.new(ENV['TIMBER_LOGS_KEY'])
  config.logger = Timber::Logger.new(network_log_device) # <-- Use network_log_device instead of STDOUT
  ```

2. Obtain your Timber API :key: by **[adding your app in Timber](https://app.timber.io)**.
   Afterwards simply assign it to the `TIMBER_LOGS_KEY` environment variable.

---

Need help? Head over to [] us on intercom or email [support@timber.io](mailto:support@timber.io)

---

</p></details>

<details><summary><strong>Advanced setup (syslog, file tailing agent, etc)</strong></summary><p>

Checkout our [docs](https://timber.io/docs) for a comprehensive list of install instructions.

</p></details>


---

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://files.timber.io/images/ruby-library-readme-log-truth.png" height="947" /></a>
</p>