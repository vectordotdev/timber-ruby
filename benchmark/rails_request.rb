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

def line_count(io)
  io.rewind
  io.read.split("\n").size
end
ITERATIONS = 10
PRECISION = 8
test = Proc.new { ITERATIONS.times { Support::Rails.dispatch_rails_request("/") } }

# Set a default logger
io = StringIO.new
Support::Rails.set_logger(io)

# Control
control = Benchmark.measure("Control", &test)
control_per_req = control.real / ITERATIONS
log_line_count = line_count(io)
control_per_line = control_per_req / log_line_count

# Reset logger and insert probes
io = StringIO.new
Support::Rails.set_logger(io)
Timber::Config.enabled = true
Timber::Bootstrap.bootstrap!(RailsApp.config.app_middleware, ::Rails::Rack::Logger)

# Probes only
probes_only = Benchmark.measure("Timber probes only", &test)
probes_only_per_req = probes_only.real / ITERATIONS
probes_only_per_req_diff = probes_only_per_req - control_per_req
log_line_count = line_count(io)
probes_only_per_line = probes_only_per_req / log_line_count

# Install Timber
io = StringIO.new
Support::Rails.set_timber_logger(io)

# With timber logger
with_timber = Benchmark.measure("Timber probes and logging", &test)
with_timber_per_req = with_timber.real / ITERATIONS
with_timber_per_req_diff = with_timber_per_req - probes_only_per_req
log_line_count = line_count(io)
with_timber_per_line = with_timber_per_req / log_line_count

title = "Timber benchmarking. #{ITERATIONS} requests per test. Times are \"real\" CPU time."
table = Terminal::Table.new(:title => title) do |t|
  t << [nil, "Total", "Per request avg", "Per request diff", "Per log line"]
  t.add_separator
  t << [control.label, control.real.round(PRECISION), control_per_req.round(PRECISION), nil, control_per_line.round(PRECISION)]
  t << [probes_only.label, probes_only.real.round(PRECISION), probes_only_per_req.round(PRECISION), probes_only_per_req_diff.round(PRECISION), probes_only_per_line.round(PRECISION)]
  t << [with_timber.label, with_timber.real.round(PRECISION), with_timber_per_req.round(PRECISION), with_timber_per_req_diff.round(PRECISION), with_timber_per_line.round(PRECISION)]
end
puts table