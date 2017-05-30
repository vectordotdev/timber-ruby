module Timber
  class CLI
    module FileHelper
      def self.append(path, contents)
        File.open(path, "a") do |f|
          f.write(contents)
        end
      end

      def self.read_or_create(path, initial_code)
        if !File.exists?(path)
          File.open(path, "w") do |f|
            f.write(initial_code)
          end
        end

        File.read(path)
      end

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