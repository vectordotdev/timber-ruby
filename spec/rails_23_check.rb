# We don't officially support rails 2.3.X but we do make sure installing Timber
# does not create exceptions. This allows legacy apps to use the timber gem and
# add custom events, but you will not get automatic structuring.

require "timber"

logger = Timber::Logger.new(STDOUT)
custom_event = Timber::Events::Custom.new(type: :testing, message: "This is a message", data: %{test: 1})
logger.info(custom_event)

print "No exceptions, yay!"