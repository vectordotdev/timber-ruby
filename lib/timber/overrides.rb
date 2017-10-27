# The order is relevant
require "timber/overrides/active_support_3_tagged_logging"
require "timber/overrides/active_support_tagged_logging"
require "timber/overrides/active_support_buffered_logger"
require "timber/overrides/lograge"
require "timber/overrides/rails_stdout_logging"

module Timber
  # @private
  module Overrides
  end
end