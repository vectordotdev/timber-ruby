module Timber
  module Patterns
    module ToLogfmt
      def to_logfmt(*args)
        @to_logfmt ||= {}
        @to_logfmt[args] ||= Core::LogfmtEncoder.encode(as_json(*args))
      end
    end
  end
end