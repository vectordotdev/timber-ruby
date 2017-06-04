require "timber/cli/file_helper"

module Timber
  class CLI
    class ConfigFile
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def create!
        FileHelper.write(path, content)
      end

      def exists?
        File.exists?(path)
      end

      def logrageify!
        append!("config.logrageify!")
      end

      private
        def append!(code)
          if !content.include?(code)
            content.gsub!(insert_hook, "#{code}\n\n#{insert_hook}")
          end

          true
        end

        def insert_hook
          @insert_hook ||= "# Add additional configuration here."
        end

        # We provide this as an instance method so that the string is only defined when needed.
        # This avoids allocating this string during normal app runtime.
        def content
          @content ||= <<-CONTENT
# Timber.io Ruby Configuration - Simple Structured Logging
#
#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^
# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
# -------------------------------------------------------------------
# Website:       https://timber.io
# Documentation: https://timber.io/docs
# Support:       support@timber.io
# -------------------------------------------------------------------

config = Timber::Config.instance

#{insert_hook}
# For a full list of configuration options and their explanations see:
# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config

CONTENT
        end
    end
  end
end