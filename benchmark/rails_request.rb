#----------------------------------------------------------
# This file demonstrates Rails performance with and without
# the Timber library installed. Timber was designed with an
# obsessive focus on performance and resource usage. The
# below benchmarking test reveals this. A few notes:
# 1. Both loggers are set to log to the same device.
# 2. The log level is set to debug to maximize logging output.
# 3. Timber is run last so that we can insert the probes after.
#    This ensures Timber does not affect the environment at all.
# ---------------------------------------------------------

$:.unshift File.dirname(__FILE__)
require "support/rails"
require "benchmark"
require "logger"

ITERATIONS = 5_000
PRECISION = 8
test = Proc.new { ITERATIONS.times { Support::Rails.dispatch_rails_request("/") } }

puts "\nTesting Rails request performance. #{ITERATIONS} requests per test.\n\n"
puts "                  Real           Per request"

without_timber = Benchmark.measure("without Timber", &test)
without_timber_per = without_timber.real / ITERATIONS
puts "#{without_timber.label}    #{without_timber.real.round(PRECISION)}     #{without_timber_per.round(PRECISION)}"

# Install Timber
Timber::Config.enabled = true
Timber::Bootstrap.bootstrap!(RailsApp.config.app_middleware, ::Rails::Rack::Logger)

with_timber = Benchmark.measure("with Timber", &test)
with_timber_per = with_timber.real / ITERATIONS
puts "#{with_timber.label}       #{with_timber.real.round(PRECISION)}     #{with_timber_per.round(PRECISION)}"

puts "Difference       #{(without_timber.real - with_timber.real).round(PRECISION)}    #{(without_timber_per - with_timber_per).round(PRECISION)}"
