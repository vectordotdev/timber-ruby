module Timber
  class CLI
    module FileHelper
      def self.verify(path)
        if !File.exists?(path)
          puts ""
          puts "Uh oh! It looks like we couldn't locate the #{path} file. "
          puts "Please enter the correct path:"
          puts

          new_path = gets
          find(new_path)
        else
          path
        end
      end
    end
  end
end