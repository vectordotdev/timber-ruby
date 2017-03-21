require "optparse"
require "yaml"
require "timber"


require "timber/cli/api"
require "timber/cli/application"
require "timber/cli/io_helper"
require "timber/cli/messages"

require "timber/cli/install"

module Timber
  # @private
  class CLI
    AVAILABLE_COMMANDS = %w(install).freeze

    class << self
      attr_accessor :options

      def run(argv = ARGV)
        @options = {}
        global = global_option_parser
        commands = command_option_parser
        global.order!(argv)
        command = argv.shift
        if command
          if AVAILABLE_COMMANDS.include?(command)
            commands[command].parse!(argv)
            case command.to_sym
            when :install
              Timber::CLI::Install.run(argv.shift)
            end
          else
            puts "Command '#{command}' does not exist, run timber -h to "\
              "see the help"
            exit(1)
          end
        else
          # Print help
          puts global
          exit(0)
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

      def command_option_parser
        {
          "install" => OptionParser.new
        }
      end
    end
  end
end