# encoding: utf-8

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
          app_url = IO::Messages::APP_URL

          io.puts "Hey there! Welcome to Timber. In order to proceed, you'll need an API key."
          io.puts "You can grab one by registering at #{IO::ANSI.colorize(app_url, :blue)}."
          io.puts ""
          io.puts "It takes less than a minute, with one click Google and Github registration."
          io.puts ""

          if OSHelper.can_open?
            case io.ask_yes_no("Open #{app_url}?")
            when :yes
              puts ""
              io.task("Opening #{app_url}") do
                OSHelper.open(app_url)
              end
            when :no
              io.puts ""
              io.puts "No problem, navigate to the following URL:"
              io.puts ""
              io.puts "    #{IO::ANSI.colorize(app_url, :blue)}"
            end
          else
            io.puts ""
            io.puts "Please navigate to:"
            io.puts ""
            io.puts "    #{IO::ANSI.colorize(app_url, :blue)}"
          end

          io.puts ""
          io.puts "Once you obtain your API key, you can run the installer like"
          io.puts ""
          io.puts "    #{IO::ANSI.colorize("bundle exec timber my-api-key", :blue)}"
          io.puts ""
          io.puts "See you soon! 🎈"
          io.puts ""
        else
          api = API.new(api_key)
          api.event(:started)

          io.api = api

          app = api.application!

          Root.new(io, api).run(app)
        end
      end
    end
  end
end