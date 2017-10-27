# encoding: utf-8

require "timber/cli/io/ansi"
require "timber/cli/os_helper"

module Timber
  class CLI
    class IO
      module Messages
        extend self

        APP_URL = "https://app.timber.io"
        DOCS_URL = "https://timber.io/docs"
        OBTAIN_KEY_DOCS_URL = "https://timber.io/docs/app/obtain-api-key/"
        REPO_URL = "https://github.com/timberio/timber-ruby"
        SUPPORT_EMAIL = "support@timber.io"
        TWITTER_HANDLE = "@timberdotio"
        WEBSITE_URL = "https://timber.io"
        MAX_LENGTH = 80.freeze

        def application_details(app)
          message = <<-MESSAGE
Woot! Your API 🔑  is valid: #{app.name} (#{app.environment}) on #{app.platform_type}
MESSAGE
          message.rstrip
        end

        def edit_app_url(app)
          "#{APP_URL}"
        end

        def bad_experience_message
          message = <<-MESSAGE
Bummer! That is certainly not the experience we were going for.

Could you tell us why you a bad experience?

(this will be sent directly to the Timber engineering team)
MESSAGE
          message.rstrip
        end

        def git_commands
          message = <<-MESSAGE
    #{ANSI.colorize("git add config/initializers/timber.rb", :blue)}
    #{ANSI.colorize("git commit -am 'Install the timber logger'", :blue)}
MESSAGE
          message.rstrip
        end

        def console_url(app)
          message = <<-MESSAGE
Your console URL: https://app.timber.io/organizations/timber/apps/#{app.slug}/console
MESSAGE
        end

        def contact
          message = <<-MESSAGE
Website:       #{WEBSITE_URL}
Documentation: #{DOCS_URL}
Support:       #{SUPPORT_EMAIL}
MESSAGE
          message.rstrip
        end

        def copied_to_clipboard
          IO::ANSI.colorize("(✓ copied to clipboard)", :green)
        end

        def http_environment_variables(api_key)
          command = "export TIMBER_API_KEY=\"#{api_key}\""
          copied = OSHelper.copy_to_clipboard(command)

          message = <<-MESSAGE
Great! Add this variable to your environment:

    #{ANSI.colorize(command, :blue)}

MESSAGE
          message = message.rstrip

          if copied
            message << "\n    #{copied_to_clipboard}"
          end

          message
        end

        def header
          message = <<-MESSAGE
🌲 Timber.io Ruby Installer - Great Ruby Logging Made *Easy*

 ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^
/|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
/|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
/|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
MESSAGE
          message.rstrip
        end

        def heroku_install(app)
          command = "heroku drains:add #{app.heroku_drain_url}"
          copied = OSHelper.copy_to_clipboard(command)

          message = <<-MESSAGE
First, let's setup your Heroku drain. Run this command in a separate window:

    #{ANSI.colorize(command, :blue)}
MESSAGE
          message = message.rstrip

          if copied
            message << "\n    #{copied_to_clipboard}"
          end

          message
        end

        def no_api_key_provided
          message = <<-MESSAGE
Hey there! Welcome to Timber. In order to proceed, you'll need an API key.
If you already have one, you can run this installer like:

    #{ANSI.colorize("bundle exec timber install my-api-key", :blue)}

#{obtain_key_instructions}
MESSAGE
          message.rstrip
        end

        def obtain_key_instructions
          message = <<-MESSAGE
Don't have a key? Head over to:

    #{ANSI.colorize(APP_URL, :blue)}

For a simple guide, checkout out:

    #{ANSI.colorize(OBTAIN_KEY_DOCS_URL, :blue)}

If you're stuck, contact us:

    #{ANSI.colorize(SUPPORT_EMAIL, :blue)}
MESSAGE
          message.rstrip
        end

        def separator
          "--------------------------------------------------------------------------------"
        end

        def spinner(iteration)
          rem = iteration % 3
          case rem
          when 0
            "/"
          when 1
            "-"
          when 2
            "\\"
          end
        end

        def failed
          "Failed :("
        end

        def success
          "✓ Success!"
        end

        def task_complete(message)
          remainder = MAX_LENGTH - message.length - success.length

          dots = "." * remainder
          "\r#{message}#{dots}#{success}"
        end

        def task_failed(message)
          remainder = MAX_LENGTH - message.length - failed.length

          dots = "." * remainder
          "\r#{message}#{dots}#{failed}"
        end

        def task_start(message)
          remainder = MAX_LENGTH - message.length - success.length

          "\r#{message}" + ("." * remainder)
        end

        def we_love_you_too
          "Thanks! We 💖 you too!"
        end
      end
    end
  end
end
