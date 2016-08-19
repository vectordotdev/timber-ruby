module Timber
  module Probes
    class Server < Probe
      class << self
        attr_accessor :inserted
      end

      def insert!
        return true if self.class.inserted == true
        context = Contexts::Server.new
        # Note we don't use a block here, this is because
        # the context is persistent.
        CurrentContext.add(context)
        self.class.inserted = true
      end
    end
  end
end
