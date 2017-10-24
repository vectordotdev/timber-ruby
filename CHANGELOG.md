# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

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


[Unreleased]: https://github.com/timberio/timber-ruby/compare/v2.4.0...HEAD
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
