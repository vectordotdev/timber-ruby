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
require 'terminal-table'

ITERATIONS = 10
PRECISION = 8
test = Proc.new { ITERATIONS.times { Support::Rails.dispatch_rails_request("/") } }

# Set a default logger
Support::Rails.set_logger(StringIO.new)

# Control
control = Benchmark.measure("Control", &test)
control_per = control.real / ITERATIONS

# Reset logger and insert probes
Support::Rails.set_logger(StringIO.new)
Timber::Config.enabled = true
Timber::Bootstrap.bootstrap!(RailsApp.config.app_middleware, ::Rails::Rack::Logger)

# Probes only
probes_only = Benchmark.measure("Timber probes only", &test)
probes_only_per = probes_only.real / ITERATIONS
probes_only_diff = probes_only_per - control_per

# Install Timber
Support::Rails.set_timber_logger

# With timber logger
with_timber = Benchmark.measure("Timber probes and logging", &test)
with_timber_per = with_timber.real / ITERATIONS
with_timber_diff = with_timber_per - probes_only_per

title = "Timber benchmarking. #{ITERATIONS} requests per test. Times are \"real\" CPU time."
table = Terminal::Table.new(:title => title) do |t|
  t << [nil, "Total", "Per request avg", "Per request diff"]
  t.add_separator
  t << [control.label, control.real.round(PRECISION), control_per.round(PRECISION), nil]
  t << [probes_only.label, probes_only.real.round(PRECISION), probes_only_per.round(PRECISION), probes_only_diff.round(PRECISION)]
  t << [with_timber.label, with_timber.real.round(PRECISION), with_timber_per.round(PRECISION), with_timber_diff.round(PRECISION)]
end
puts table