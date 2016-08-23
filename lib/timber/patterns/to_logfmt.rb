module Timber
  module Patterns
    module ToLogfmt
      def to_logfmt
        @to_logfmt ||= Macros::LogfmtEncoder.encode(as_json).freeze
      end
    end
  end
end