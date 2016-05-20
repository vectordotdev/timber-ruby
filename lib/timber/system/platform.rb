require "singleton"

module Timber
  module System
    class Platform
      include Singleton

      class << self
        def method_missing(name, *args, &block)
          instance.send(name, *args, &block)
        end
      end

      def darwin?
        return @darwin if defined?(@darwin)
        @darwin = !(platform =~ /darwin/).nil?
      end

      def darwin10plus?
        return @darwin10plus if defined?(@darwin10plus)
        @darwin10plus = !(platform =~ /darwin1\d+/).nil?
      end

      def darwin9?
        return @darwin9 if defined?(@darwin9)
        @darwin9 = !(platform =~ /darwin9/).nil?
      end

      def freebsd?
        return @freebsd if defined?(@freebsd)
        @freebsd = !(platform =~ /darwin/).nil?
      end

      def linux?
        return @linux if defined?(@linux)
        @linux = !(platform =~ /linux/).nil?
      end

      def platform
        @platform ||= if RUBY_PLATFORM =~ /java/
          %x[uname -s].downcase
        else
          RUBY_PLATFORM.downcase
        end
      end

      def solaris?
        return @solaris if defined?(@solaris)
        @solaris = !(platform =~ /solaris/).nil?
      end
    end
  end
end
