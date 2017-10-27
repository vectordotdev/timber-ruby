require "timber/cli/file_helper"

module Timber
  class CLI
    class ConfigFile
      attr_reader :path, :file_helper

      def initialize(path, file_helper)
        @path = path
        @file_helper = file_helper
      end

      def create!
        file_helper.write(path, content)
      end

      def exists?
        File.exists?(path)
      end

      def logrageify!
        append!("config.logrageify!")
      end

      def silence_template_renders!
        append!("config.integrations.action_view.silence = Rails.env.production?")
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
# For common configuration options see:
# https://timber.io/docs/languages/ruby/configuration
#
# For a full list of configuration options see:
# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config

CONTENT
        end
    end
  end
end