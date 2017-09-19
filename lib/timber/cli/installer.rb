require "timber/cli/file_helper"
require "timber/cli/io/messages"

module Timber
  class CLI
    class Installer
      DEPRIORITIZED_PLATFORMS = ["linux", "other"].freeze

      attr_reader :io, :api, :file_helper

      def initialize(io, api)
        @io = io
        @api = api
        @file_helper = FileHelper.new(api)
      end

      def run(app)
        raise NotImplementedError.new
      end

      private
        def get_delivery_strategy(app)
          if DEPRIORITIZED_PLATFORMS.include?(app.platform_type)
            :http
          else
            :stdout
          end
        end

        # Determines the API key storage prference (environment variable or inline)
        def get_api_key_storage_preference
          io.puts ""
          io.puts IO::Messages.separator
          io.puts ""
          io.puts "For production/staging would you like to store your Timber API key"
          io.puts "in an environment variable? (TIMBER_API_KEY)"
          io.puts ""
          io.puts "y) Yes, store in TIMBER_API_KEY", :blue
          io.puts "n) No, just paste the API key inline", :blue
          io.puts ""

          case io.ask_yes_no("Enter your choice:", event_prompt: "Store API key in env?")
          when :yes
            io.puts ""
            io.puts IO::Messages.http_environment_variables(api.api_key)
            io.puts ""

            io.ask_to_proceed

            :environment
          when :no
            :inline
          end
        end

        # Based on the API key storage preference, we generate the proper code.
        def get_api_key_code(storage_type)
          case storage_type
          when :environment
            "ENV['TIMBER_API_KEY']"
          when :inline
            "'#{api.api_key}'"
          else
            raise ArgumentError.new("API key storage type not recognized! " \
              "#{storage_type.inspect}")
          end
        end
    end
  end
end