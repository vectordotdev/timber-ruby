# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "timber/version"

Gem::Specification.new do |s|
  s.name        = "timber"
  s.version     = Timber::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Timber Technologies, Inc."]
  s.email       = ["hi@timber.io"]
  s.homepage    = "https://github.com/timberio/timber-ruby"
  s.summary     = "Log Better. Solve Problems Faster. https://timber.io"

  s.required_ruby_version     = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('msgpack', '~> 1.0')

  s.add_development_dependency('bundler-audit', '>= 0')
  s.add_development_dependency('rails_stdout_logging', '>= 0')
  s.add_development_dependency('rake', '>= 0')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('rspec-its', '>= 0')
  s.add_development_dependency('timecop', '>= 0')

  if RUBY_PLATFORM == "java"
    s.add_development_dependency('activerecord-jdbcsqlite3-adapter', '>= 0')
  else
    s.add_development_dependency('sqlite3', '>= 0')
  end

  if RUBY_VERSION
    ruby_version = Gem::Version.new(RUBY_VERSION)

    if ruby_version < Gem::Version.new("2.0.0")
      s.add_development_dependency('public_suffix', '~> 1.4.6')
      s.add_development_dependency('term-ansicolor', '~> 1.3.2')
      s.add_development_dependency('tins', '~> 1.5.0')
      s.add_development_dependency('webmock', '~> 2.2.0')
    else
      s.add_development_dependency('webmock', '~> 2.3')
    end
  else
    s.add_development_dependency('webmock', '~> 2.3')
  end
end
