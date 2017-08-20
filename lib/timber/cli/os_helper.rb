module Timber
  class CLI
    module OSHelper
      def self.can_copy_to_clipboard?
        `which pbcopy` != ""
      rescue Exception
        false
      end

      def self.copy_to_clipboard(input)
        ::IO.popen('pbcopy', 'w') { |f| f << input }
        true
      rescue Exception
        false
      end

      def self.git_clean_working_tree?
        `git diff-index --quiet HEAD -- || echo "untracked";` == ""
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

      def self.git_master?
        `git rev-parse --abbrev-ref HEAD` == "master"
      end

      def self.has_git?
        begin
          `which git` != ""
        rescue Exception
          false
        end
      end

      def self.can_open?
        begin
          `which #{open_command}` != ""
        rescue Exception
          false
        end
      end

      # Attemps to open a URL in the user's default browser across
      # the popular operating systems.
      def self.open(link)
        `#{open_command} #{link}`
        true
      rescue Exception
        false
      end

      private
        def self.open_command
          if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
            "start"
          elsif RbConfig::CONFIG['host_os'] =~ /darwin/
            "open"
          elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
            "xdg-open"
          end
        end
    end
  end
end