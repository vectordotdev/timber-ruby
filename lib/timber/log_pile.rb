module Timber
  # A simple class that drops our JSON blobs to a file
  # where our agent can pick them up and transfer them
  # to the Timber service
  #
  # TODO: What happens on a crash? Tempfile are erased
  # on boot.
  # TODO: Avoid opening and closing the file multiple times.
  # Perhaps we can open the file and close on sigterm?
  class LogPile
    TEMPFILE_NAME = "timber_log_pile".freeze

    include Patterns::DelegatedSingleton

    def drop(log_line)
      open(temp_file.path, "a") do |f|
        f.puts log_line.to_json
      end
    end

    def contents(&block)
      contents = []
      File.open(temp_file.path, "r") do |f|
        f.each_line do |line|
          contents << JSON.parse!(line)
        end
      end
      contents
    end

    private
      def temp_file
        @temp_file ||= Tempfile.new(TEMPFILE_NAME).tap do |t|
          t.close
        end
      end
  end
end
