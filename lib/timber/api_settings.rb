module Timber
  # These settings are controlled by the Timber API. Violating these will result
  # in unsuccessful log delivery.
  module APISettings
    DATE_FORMAT = :iso8601.freeze # must be a method name
    MESSAGE_BYTE_SIZE_MAX = 1_000_000.freeze # 1mb
  end
end
