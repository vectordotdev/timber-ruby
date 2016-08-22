module Timber
  module LogDevices
    class HerokuLogplex < IO
      module HybridFormatter
        private
          def encoded_context(log_line)
            log_line.context_snapshot.to_logfmt(
              :except => [Contexts::Servers::HerokuSpecific]
            )
          end
      end
    end
  end
end