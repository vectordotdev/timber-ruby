require "bundler/gem_tasks"
require "timber"

def puts_with_level(message, level = :info)
  case level
  when :info
    puts("\e[31m#{message}\e[0m")
  when :error
    puts("\e[31m#{message}\e[0m")
  when :success
    puts("\e[32m#{message}\e[0m")
  else
    puts(message)
  end
end

task :test_the_pipes, [:api_key] do |t, args|
  support_email = "support@timber.io"
  # Do not modify below this line. It's important to keep the `Timber::Logger`
  # because it provides an API for logging structured data and capturing context.
      header = <<-HEREDOC
  ^  ^   ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^
 /|\\/|\\ /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
 /|\\/|\\ /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
 /|\\/|\\ /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
============================================================
               TIMBER.IO - TESTING THE PIPES
============================================================
    HEREDOC

  puts header

  current_context = Timber::CurrentContext.instance.snapshot
  entry = Timber::LogEntry.new(:info, Time.now, nil, "Testing the pipes (click the inspect icon to view more details)", current_context, nil)
  http_device = Timber::LogDevices::HTTP.new(args.api_key, flush_continuously: false)
  response = http_device.deliver_one(entry)
  if response.is_a?(Exception)
      message = <<~HEREDOC
        Unable to deliver logs.
        Here's what we received from the Timber API:
        #{response.inspect}
        If you continue to have trouble please contact support:
        #{support_email}
        HEREDOC
    puts_with_level(message, :error)
  elsif response.is_a?(Net::HTTPResponse)
    if response.code.start_with? '2'
      puts_with_level("Logs successfully sent! View them at https://app.timber.io",
                      :success)
    else
      message =
        <<~HEREDOC
        Unable to deliver logs.
        We received a #{response.code} response from the Timber API:
        #{response.body.inspect}
        If you continue to have trouble please contact support:
        #{support_email}
        HEREDOC
      puts_with_level(message, :error)
    end
  end
end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'timber'
  $VERBOSE = nil

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/timber\// }
    files.each { |file| load file }
    "reloaded"
  end

  ARGV.clear
  IRB.start
end
