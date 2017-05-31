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
          write(path, initial_code)
        end

        File.read(path)
      end

      def self.read(path)
        File.read(path)
      end

      def self.write(path, contents)
        File.open(path, "w") do |f|
          f.write(initial_code)
        end
      end

      def self.verify(path, io)
        if !File.exists?(path)
          io.puts ""
          io.puts "Uh oh! It looks like we couldn't locate the #{path} file. "
          io.puts "Please enter the correct path:"
          io.puts

          new_path = io.gets
          verify(new_path, io)
        else
          path
        end
      end
    end
  end
end