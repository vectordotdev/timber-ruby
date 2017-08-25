module Timber
  class CLI
    class FileHelper
      attr_reader :api

      def initialize(api)
        @api = api
      end

      def append(path, contents)
        File.open(path, "a") do |f|
          f.write(contents)
        end
      end

      def exists?(path)
        File.exists?(path)
      end

      def read_or_create(path, contents)
        if !exists?(path)
          write(path, contents)
        end

        read(path)
      end

      def read(path)
        File.read(path)
      end

      def write(path, contents)
        File.open(path, "w") do |f|
          f.write(contents)
        end
      end

      def verify(path, io)
        if !exists?(path)
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