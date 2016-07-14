module Timber
  # These settings are established by the Timber API. Changing these will result
  # in unsuccessful log delivery.
  module APISettings
    DATE_FORMAT = :iso8601.freeze # must be a method name
    DATE_FORMAT_PRECISION = 6 # millisecond digits
    MESSAGE_BYTE_SIZE_MAX = 1_000_000.freeze # 1mb

    # List of types that the Timber API accepts
    BOOLEAN_TYPE = "integer".freeze
    DATE_TYPE    = "date".freeze
    FLOAT_TYPE   = "float".freeze
    INTEGER_TYPE = "integer".freeze
    NIL_TYPE     = "nil".freeze
    STRING_TYPE  = "string".freeze
  end
end
