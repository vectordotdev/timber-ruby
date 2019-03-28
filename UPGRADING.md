# Upgrading

## 2.x to 3.x

### Overview

We're excited to announce the 3.X line of Timber for Ruby! We've been making big
strides with Timber as a whole and 3.X represents a lot of big improvements:

- A lighter code base
- Better performance
- A simpler, better install process and strategy
- New docs: https://docs.timber.io/setup/languages/ruby
- New integration libraries focused on the specific library they're integrating with

  - https://github.com/timberio/timber-ruby-rack
  - https://github.com/timberio/timber-ruby-rails

Outside of that, 3.0 does not introduce any API changes, and is forward compatbile
in that regard. This means actions like setting context and logging structured data
will continue to work as expected.

### Rails

If you're on Rails, the upgrade process is simple. Simply add the `timber-rails`
gem to your `Gemfile`:

```
gem 'timber-rails', '~> 1.0'
```

That's it! Everything is taken care of you via a Rails initializer.

More info: https://docs.timber.io/setup/languages/ruby/integrations/rack

### Non-rails

If you're not on rails, and you're using `Rack`, you'll want to install the
`timber-rack` gem by adding it to your `Gemfile`:

```
gem 'timber-rack', '~> 1.0'
```

That's it! The middleware class names are still the same and should not
require any altering.

More info: https://docs.timber.io/setup/languages/ruby/integrations/rack
