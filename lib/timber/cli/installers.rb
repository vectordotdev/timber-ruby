# encoding: utf-8

require "timber/cli/api"
require "timber/cli/installers/root"
require "timber/cli/io/messages"
require "timber/cli/os_helper"

module Timber
  class CLI
    module Installers
      def self.run(api_key, io)
        api = API.new(api_key)
        api.event(:started)

        begin
          io.puts IO::Messages.header, :green
          io.puts IO::Messages.separator, :green
          io.puts IO::Messages.contact, :green
          io.puts IO::Messages.separator, :green
          io.puts ""

          # if OSHelper.has_git?
          #   if OSHelper.git_master? || !OSHelper.git_clean_working_tree?
          #     io.puts "Before we begin, this installer will make a few simple code changes."
          #     io.puts ""

          #     case io.ask_yes_no("Would you like to exit and start over on a clean git branch?")
          #     when :yes
          #       command = "git checkout -b install-timber"
          #       copied = OSHelper.copy_to_clipboard(command)

          #       io.puts ""
          #       io.puts "Good idea. Here's a simple git command to make things easier:"
          #       io.puts ""
          #       io.puts "    #{IO::ANSI.colorize(command, :blue)}"

          #       if copied
          #         io.puts "    #{IO::Messages.copied_to_clipboard}"
          #       end

          #       io.puts ""
          #       io.puts "Once you've switched branches, run the installer command again."
          #       io.puts ""
          #       return
          #     end
          #   end
          # end

          if !api_key
            api.event(:no_api_key)

            app_url = IO::Messages::APP_URL

            io.puts "Hey there! Welcome to Timber. In order to proceed, you'll need an API key."
            io.puts "You can grab one by registering at #{IO::ANSI.colorize(app_url, :blue)}."
            io.puts ""
            io.puts "It takes less than a minute, with one click Google and Github registration."
            io.puts ""

            if OSHelper.can_open?
              case io.ask_yes_no("Open #{app_url}?")
              when :yes
                io.puts ""
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
            io.puts "    #{IO::ANSI.colorize("bundle exec timber install my-api-key", :blue)}"
            io.puts ""
            io.puts "See you soon! 🎈"
            io.puts ""
          else
            api.event(:api_key_provided)
            io.api = api

            app = api.application!

            Root.new(io, api).run(app)
          end
        rescue Exception => e
          api.event(:exception, message: e.message, stacktrace: e.backtrace)
          raise e
        end
      end
    end
  end
end
