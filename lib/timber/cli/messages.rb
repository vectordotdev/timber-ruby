module Timber
  class CLI
    module Messages
      extend self

      APP_URL = "https://app.timber.io"
      DOCS_URL = "https://timber.io/docs"
      REPO_URL = "https://github.com/timberio/timber-ruby"
      SUPPORT_EMAIL = "support@timber.io"
      TWITTER_HANDLE = "@timberdotio"
      WEBSITE_URL = "https://timber.io"

      def edit_app_url(app)
        "#{APP_URL}"
      end

      def application_details(app)
message = <<-MESSAGE
Woot! Your API 🔑 is valid. Here are you application details:"

Name:      #{app.name}"
Framework: #{app.framework_type}"
Platform:  #{app.platform_type}"
MESSAGE
message.rstrip
end

      def contact
message = <<-MESSAGE
Website:       #{WEBSITE_URL}
Documentation: #{DOCS_URL}
Support:       #{SUPPORT_EMAIL}
MESSAGE
message.rstrip
      end

      def finish
message = <<-MESSAGE
Done! Commit these changes and deploy. 🚀

* Timber URL: https://app.timber.io
* Get ✨ 250mb✨ for tweeting your experience to #{TWITTER_HANDLE}
* Get ✨ 100mb✨ for starring our repo: #{REPO_URL}
* Get ✨ 50mb✨ for following #{TWITTER_HANDLE} on twitter

(Your account will be credited within 2-3 business days.
 If you do not notice a credit please contact us: #{@support_email})
MESSAGE
message.rstrip
end
      def header
message = <<-MESSAGE
🌲 Timber.io Ruby Installer

 ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^
/|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
/|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
/|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
MESSAGE
message.rstrip
      end

      def heroku_install(app)
message = <<-MESSAGE
Now we need to send your logs to the Timber service.

Please run this command in a separate terminal and return back here when complete:

    heroku drains:add #{app.heroku_drain_url}
MESSAGE
message.rstrip
      end

      def separator
        "--------------------------------------------------------------------------------"
      end

      def spinner(iteration)
        case (iteration % 3)
        when 0
          "/"
        when 1
          "-"
        when 2
          "\\"
        end
      end

      def success
        "✓ Success!"
      end

      def task_complete
        success
      end

      def task_start(message)
        "\r#{message}......"
      end
    end
  end
end