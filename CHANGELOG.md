# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0] - 2017-09-13
## Changed

  - The default HTTP log device queue type was switched to a
    `Timber::LogDevices::HTTP::FlushableDroppingSizedQueue` instead of a `::SizedQueue`. In the
    event of extremely high volume logging, and delivery cannot keep up, Timber will drop messages
    instead of applying back pressure.


[Unreleased]: https://github.com/timberio/timber-ruby/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/timberio/timber-ruby/compare/v2.1.10...v2.2.0
