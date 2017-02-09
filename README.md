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

:point_right: **Timber is in beta testing, if interested in joining, please email us at [beta@timber.io](mailto:beta@timber.io)**

---

* **[What is Timber?](#what-is-timber)**
* **[What does Timber structure for me?](#what-events-does-timber-structure-for-me)**
* **[Usage](#usage)**
* **[Installation](#installation)**
* **[Setup](#installation)**
* **[Send your logs](#send-your-logs)**


## What is Timber?

Logs are amazingly useful...when they're structured. And unless you're a logging company,
designing, implementing, and maintaining a structured logging strategy can be a major time sink.

Timber gives you this *today*, allowing you to spend time on your app, not logging. Specifically,
Timber is a thoughtful, carefully crafted, fully-managed, *structured* logging strategy that...

1. Automatically structures your framework and 3rd party logs ([see below](#what-events-does-timber-structure-for-me)).
2. Provides a [framework for logging custom events](#what-about-custom-events).
3. Does not lock you in with a special API or closed data. Just better logging.
4. Defines a [normalized log schema](https://github.com/timberio/log-event-json-schema) across *all* of your apps. Implemented by [our libraries](https://github.com/timberio).
5. Offers a [beautiful modern console](https://timber.io) designed specifically for this data. Pre-configured and tuned out of the box.
6. Gives you *6 months of retention*, by default.
7. Does not charge you for the extra structured data we're encouraging here, only the core log message.
8. Encrypts your data in transit and at rest.
9. Offers 11 9s of durability.
10. ...and so much more!

To learn more, checkout out [timber.io](https://timber.io) or the
["why we started Timber"](http://moss-ibex2.cloudvent.net/blog/why-were-building-timber/)
blog post.


## What does Timber structure for me?

Out of the box you get everything in the [`Timber.Events`](lib/timber/events) namespace:

1. [Controller Call Event](lib/timber/events/controller_call.rb)
2. [Exception Event](lib/timber/events/exception.rb)
3. [HTTP Client Request Event (net/http outgoing)](lib/timber/events/http_client_request.rb)
4. [HTTP Client Response Event (resposne from net/http outgoing)](lib/timber/events/http_client_response.rb)
5. [HTTP Server Request Event (incoming client request)](lib/timber/events/http_server_request.rb)
6. [HTTP Server Response Event (response to incoming client request)](lib/timber/events/http_server_response.rb)
7. [SQL Query Event](lib/timber/events/sql_query.ex)
8. [Template Render Event](lib/timber/events/template_render.rb)
9. ...more coming soon, [file an issue](https://github.com/timberio/timber-ruby/issues) to request.

We also add context to every log, everything in the [`Timber.Contexts`](lib/timber/contexts)
namespace. Context is like join data for your logs. Have you ever wished you could search for all
logs written with in a specific request ID? Context achieves that:

1. [HTTP Context](lib/timber/contexts/http.rb)
2. [Organization Context](lib/timber/contexts/organization.rb)
3. [Process Context](lib/timber/contexts/process.rb)
4. [Server Context](lib/timber/contexts/server.rb)
5. [Runtime Context](lib/timber/contexts/runtime.rb)
5. [User Context](lib/timber/contexts/user.rb)
6. ...more coming soon, [file an issue](https://github.com/timberio/timber-ruby/issues) to request.


## Usage

<details><summary><strong>Basic logging</strong></summary><p>

No client, no special API, just use `Logger` as normal:

```elixir
logger.info("My log message")
```

</p></details>

<details><summary><strong>Custom events</strong></summary><p>

1. Log a hash (simplest)

  The simplest way to send an event and kick the tires:

  ```ruby
  Logger.warn message: "Payment rejected", type: :payment_rejected,
  data: {customer_id: "abcd1234", amount: 100, reason: "Card expired"}
  ```

2. Log a struct (recommended)

  Defining structs for your important events just feels oh so good :) It creates a strong contract
  with down stream consumers and gives you compile time guarantees.

  ```ruby
  PaymentRejectedEvent = Struct.new(:customer_id, :amount, :reason) do
    def message; "Payment rejected for #{customer_id}"; end
    def type; :payment_rejected; end
  end
  Logger.warn PaymentRejectedEvent.new("abcd1234", 100, "Card expired")
  ```

* For more advanced examples see [`Timber::Logger`](lib/timber.logger.rb).
* Also, notice there are no special APIs, no risk of code-debt, and no lock-in. It's just better
  logging.

</p></details>

<details><summary><strong>Custom contexts</strong></summary><p>

Context is additional data shared across log lines. Think of it like join data. For example, the
`http.request_id` is included in the context, allowing you to view all log lines related to that
request ID. Not just the lines that contain the value.

1. Add a Hash (simplest)

  The simplest way to add context is:

  ```ruby
  Timber::CurrentContext.with({type: :build, data: {version: "1.0.0"}}) do
    logger.info("This message will include the wrapped context")
  end
  ```

  This adds context data keyspaced by `build` within Timber.

2. Add a struct (recommended)

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


## Send your logs

<details><summary><strong>Heroku (log drains)</strong></summary><p>

1. *Add* the Timber logger in `config/environments/production.rb`:

  ```ruby
  # config/environments/production.rb (or staging, etc)
  config.logger = Timber::Logger.new(STDOUT)
  ```

2. *Add* the Heroku log drain:

  The recommended strategy for Heroku is to setup a
  [log drain](https://devcenter.heroku.com/articles/log-drains). To get your Timber log drain URL:

  **--> [Add your app to Timber](https://app.timber.io)**

  *:information_desk_person: Note: for high volume apps Heroku log drains will drop messages. This
  is true for any Heroku app, in which case we recommend the Network method below.*

---

</p></details>

<details><summary><strong>All other platforms (Network / HTTP)</strong></summary><p>

1. *Add* the Timber logger in `config/environments/production.rb`:

  ```ruby
  # config/environments/production.rb (or staging, etc)
  log_device = Timber::LogDevices::HTTP.new(ENV['TIMBER_LOGS_KEY'])
  config.logger = Timber::Logger.new(log_device)
  ```

2. Obtain your Timber API :key: by **[adding your app in Timber](https://app.timber.io)**.
   Afterwards simply assign it to the `TIMBER_LOGS_KEY` environment variable.

* Note: we use the `Network` transport so that we can upgrade protocols in the future if we
  deem it more efficient. For example, TCP. If you want to use strictly HTTP, simply replace
  `Timber.Transports.Network` with `Timber.Transports.HTTP`.

---

</p></details>

<details><summary><strong>Advanced setup (syslog, file tailing agent, etc)</strong></summary><p>

Checkout our [docs](https://timber.io/docs) for a comprehensive list of install instructions.

</p></details>


---

<p align="center" style="background: #140f2a;">
<a href="http://github.com/timberio/timber-ruby"><img src="http://files.timber.io/images/ruby-library-readme-log-truth.png" height="947" /></a>
</p>