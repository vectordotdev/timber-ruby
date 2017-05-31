require "timber/cli/api"
require "timber/cli/installers/root"
require "timber/cli/io/messages"
require "timber/cli/os_helper"

module Timber
  class CLI
    module Installers
      def self.run(api_key, io)
        io.puts IO::Messages.header, :green
        io.puts IO::Messages.separator, :green
        io.puts IO::Messages.contact, :green
        io.puts IO::Messages.separator, :green
        io.puts ""

        if !api_key
          io.puts IO::Messages.no_api_key_provided

          case io.ask_yes_no("Open the Timber app in your brower now?")
          when :yes
            OSHelper.open(IO::Messages::APP_URL)
          end

        else
          api = API.new(api_key)
          api.event!(:started)

          io.api = api

          app = api.application!

          Root.new(io, api).run(app)
        end
      end
    end
  end
end