require "singleton"

module Timber
  # A simple class that drops our JSON blobs to a file
  # where our agent can pick them up and transfer them
  # to the Timber service
  #
  # TODO: What happens on a crash? Tempfile are erased
  # on boot.
  # TODO: Avoid opening and closing the file multiple times.
  # Perhaps we can open the file and close on sigterm?
  class LogYard
    TEMPFILE_NAME = "timber_log_yard"

    include Singleton

    class << self
      def drop(*args, &block)
        instance.drop(*args, &block)
      end
    end

    def drop(message)
      open(timber_temp_file.path, 'a') do |f|
        f.puts message
      end
    end

    private
      def temp_file
        @temp_file ||= Tempfile.new(TEMPFILE_NAME).tap do |t|
          t.close
        end
      end
  end
end
