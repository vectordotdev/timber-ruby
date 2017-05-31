require "optparse"
require "yaml"

require "timber/cli/api"
require "timber/cli/installers"
require "timber/cli/io"
require "timber/version"

module Timber
  # @private
  class CLI
    AVAILABLE_COMMANDS = %w(install).freeze

    class << self
      attr_accessor :options

      def run(argv = ARGV)
        global = global_option_parser
        global.order!(argv)
        command = argv.shift

        case command
        when nil
          # Print help
          puts global
          exit(0)

        when "install"
          api_key = argv.shift
          io = IO.new
          Installers.run(api_key, io)

        else
          puts "Command '#{command}' does not exist, run timber -h to "\
            "see the help"
          exit(1)
        end
      end

      def global_option_parser
        OptionParser.new do |o|
          o.banner = "Usage: timber <command> [options]"

          o.on "-v", "--version", "Print version and exit" do |_arg|
            puts "Timber #{Timber::VERSION}"
            exit(0)
          end

          o.on "-h", "--help", "Show help and exit" do
            puts o
            exit(0)
          end

          o.separator ""
          o.separator "Available commands: #{AVAILABLE_COMMANDS.join(", ")}"
        end
      end
    end
  end
end