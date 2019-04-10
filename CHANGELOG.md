# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.1] - 2019-04-10

### Fixed

  - Fixed a bug where `Timber.with_context` was calling a non-existent method. [#205](https://github.com/timberio/timber-ruby/pull/205)

## [3.0.0] - 2019-03-28

### Changed

  - Timber's Rails integration has been moved to the optional `timber_rails` gem: https://github.com/timberio/timber-ruby-rails
  - Timber's Rack integration has been moved to the optional `timber_rack` gem: https://github.com/timberio/timber-ruby-rack
  - Custom events are no longer nested under the `custom.event` key, events are now merged into the root document.
  - Custom contexts are no longer nested under the `context.custom` key, contexts are not part of the top-level `context` document.
  - The Timber JSON schema (`$shema` key) was dropped since the Timber.io service no longer requires a strict schema (structured data in any shape is accepted).
  - `Timber::LogDevices::HTTP#initialize` now takes a second `source_id` parameter. Timber's new API keys are no longer Timber source specific and therefore require a `source_id` to be specificed. Ex: `Timber::LogDevices::HTTP.new('api_key', 'source_id')`.

## [2.6.2] - 2018-10-17

### Fixed

  - Fixes an issue where logging without specifying data would raise an error
  - Fix nested hash in parameters not showing up in logs

## [2.6.1] - 2017-11-28

### Fixed

  - Fixes an issue where a reference to the current custom context map was being capture during log line creation and then later self-modifying to make the context invalid.

## [2.6.0] - 2017-11-28

### Fixed

  - Encoding and rewind issues for file upload parameters have been resolved. Timber
    improved attribute normalization across all contexts and events, ignoring binary
    values like this in general.
  - Fixes `::ActionDispatch::ExceptionWrapper` version detection preventing the `undefined method clean for #<Hash:->` error when an exception is raised in a Rack request.

## [2.5.1] - 2017-10-27

### Fixed

  - Ensure the new `content_length` field for HTTP request and response events are an integer.

## [2.5.0] - 2017-10-27

### Changed

  - Remove social promotions during the installation process
  - The default log device for development has been changed to a file (log/development.log)
    to follow Rails defaults.

### Fixed

  - Adds an override for ActiveSupport::Buffered logger. This is a legacy class that was dropped
    in Rails >= 4. It lacked #formatter accessor methods, which was a bug that was never resolved.

### Added

  - Capture `content_length` for both HTTP request and HTTP response events. This field is
    available in the log's metadata. The response event now includes the content length in the
    actual log message. The request message remains unchanged.

## [2.4.0] - 2017-10-23

### Added

  - Adds the new `host` field into the `http` context, bumping the log event JSON schema to `3.2.0`.

## [2.3.4] - 2017-10-12

### Fixed

  - Fix bug calling `Timber::Util::Request::REQUEST_ID_KEY_NAME12` to use the proper constant name.

## [2.3.3] - 2017-10-02

### Changed

  - Raises the limit on the `params_json` field for the `ControllerCallEvent` to `32768` bytes.
  - Bump log event JSON schema version to `3.1.3`.

## [2.3.2] - 2017-09-27

### Fixed

  - Drop ASCII-8BIT (binary) data before encoding to JSON. This resolves encoding errors during
    this process.

## [2.3.1] - 2017-09-26

### Fixed

  - Forcibly fallback to SSLv23 if SSLv3 fails. SSLv3 is only used for outdated OpenSSL versions.

## [2.3.0] - 2017-09-26

### Added

  - Added the ability to pass additional loggers when instantiating a `::Timber::Logger`.

## [2.2.3] - 2017-09-18

### Fixed

  - Update the installer to be platform aware, recommending the appropriate delivery method
    for the application's platform.


## [2.2.2] - 2017-09-14

### Fixed

  - Remove Railtie ordering clause based on devise omniauth initializer. This is no longer
    necessary since we do not integrate with Omniauth anymore.

## [2.2.1] - 2017-09-13

### Changed

  - Omniauth integration was removed since it only captures user context during the Authentication
    phase. Omniauth does not persist sessions. As such, the integration is extremely low value
    and could cause unintended issues.

## [2.2.0] - 2017-09-13

### Changed

  - The default HTTP log device queue type was switched to a
    `Timber::LogDevices::HTTP::FlushableDroppingSizedQueue` instead of a `::SizedQueue`. In the
    event of extremely high volume logging, and delivery cannot keep up, Timber will drop messages
    instead of applying back pressure.


[Unreleased]: https://github.com/timberio/timber-ruby/compare/v3.0.1...HEAD
[3.0.1]: https://github.com/timberio/timber-ruby/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/timberio/timber-ruby/compare/v2.6.1...v3.0.0
[2.6.1]: https://github.com/timberio/timber-ruby/compare/v2.6.0...v2.6.1
[2.6.0]: https://github.com/timberio/timber-ruby/compare/v2.5.1...v2.6.0
[2.5.1]: https://github.com/timberio/timber-ruby/compare/v2.5.0...v2.5.1
[2.5.0]: https://github.com/timberio/timber-ruby/compare/v2.4.0...v2.5.0
[2.4.0]: https://github.com/timberio/timber-ruby/compare/v2.3.4...v2.4.0
[2.3.4]: https://github.com/timberio/timber-ruby/compare/v2.3.3...v2.3.4
[2.3.3]: https://github.com/timberio/timber-ruby/compare/v2.3.2...v2.3.3
[2.3.2]: https://github.com/timberio/timber-ruby/compare/v2.3.1...v2.3.2
[2.3.1]: https://github.com/timberio/timber-ruby/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/timberio/timber-ruby/compare/v2.2.2...v2.3.0
[2.2.2]: https://github.com/timberio/timber-ruby/compare/v2.2.2...v2.2.3
[2.2.2]: https://github.com/timberio/timber-ruby/compare/v2.2.1...v2.2.2
[2.2.1]: https://github.com/timberio/timber-ruby/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/timberio/timber-ruby/compare/v2.1.10...v2.2.0
