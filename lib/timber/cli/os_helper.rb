module Timber
  class CLI
    module OSHelper
      def self.copy_to_clipboard(input)
        ::IO.popen('pbcopy', 'w') { |f| f << input }
        true
      rescue Exception
        false
      end

      def self.git_commit_changes
        begin
          `git add config/initializers/timber.rb`
        rescue Exception
        end

        `git commit -am 'Install the timber logger'`
        true
      rescue Exception
        false
      end

      def self.has_git?
        begin
          `git`
          true
        rescue Exception
          false
        end
      end

      # Attemps to open a URL in the user's default browser across
      # the popular operating systems.
      def self.open(link)
        if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
          system "start #{link}"
        elsif RbConfig::CONFIG['host_os'] =~ /darwin/
          system "open #{link}"
        elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
          system "xdg-open #{link}"
        end
        true
      rescue Exception
        false
      end
    end
  end
end