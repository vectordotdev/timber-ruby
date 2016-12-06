source 'https://rubygems.org'
gemspec

group :test do
  gem 'appraisal'
  gem 'coveralls', require: false
  gem 'json', '~> 1'
  gem 'pry'
  gem 'rails_stdout_logging'
  gem 'rake'
  gem 'rspec', '~> 3.4'
  gem 'rspec-its'
  gem 'simplecov', require: false
  gem 'sqlite3'
  gem 'terminal-table'
  gem 'timecop'

  ruby_version = Gem::Version.new("#{RUBY_VERSION}")
  if ruby_version < Gem::Version.new("2.0.0")
    gem 'public_suffix', '~> 1.4.6'
    gem 'webmock', '~> 2.2.0'
  else
    gem 'webmock'
  end

  # for coveralls
  gem 'rest-client', '~> 1.8' # >= 2.0 requires ruby 2+, we have tests for 1.9
  gem 'tins', '~> 1.6.0' # > 1.6 requires ruby 2+, we have tests for 1.9
end
