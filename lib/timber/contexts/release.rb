require "timber/config"
require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # The release context tracks application releases / versions / deploys.
    # To automatically set this context, see {.from_env}.
    class Release < Context
      @keyspace = :release

      class << self
        # Builds a release context based on environment variables. Simply add the
        # `RELEASE_COMMIT`, `RELEASE_CREATED_AT`, or the `RELEASE_VERSION` env vars
        # to get this context automatially. All are optional, but at least one
        # must be present.
        #
        # If you're on Heroku, simply enable dyno metadata to get this automatically:
        # https://devcenter.heroku.com/articles/dyno-metadata
        def from_env
          commit_hash = ENV['RELEASE_COMMIT'] || ENV['HEROKU_SLUG_COMMIT']
          created_at = ENV['RELEASE_CREATED_AT'] || ENV['HEROKU_RELEASE_CREATED_AT']
          version = ENV['RELEASE_VERSION'] || ENV['HEROKU_RELEASE_VERSION']

          if commit_hash || created_at || version
            Timber::Config.instance.debug { "Release env vars detected, adding to context" }
            new(commit_hash: commit_hash, created_at: created_at, version: version)
          else
            Timber::Config.instance.debug { "Release env vars _not_ detected" }
            nil
          end
        end
      end

      attr_reader :commit_hash, :created_at, :version

      def initialize(attributes)
        @commit_hash = attributes[:commit_hash]
        @created_at = attributes[:created_at]
        @version = attributes[:version]
      end

      # Builds a hash representation of containing simply objects, suitable for serialization.
      def as_json(_options = {})
        {commit_hash: commit_hash, created_at: created_at, version: version}
      end
    end
  end
end