module Timber
  KEY_NAME = :_timber_ignoring.freeze
  # Ignores any log lines written
  #
  # Timber.ignore do
  #   # code
  # end
  def self.ignore(&block)
    Thread.current[KEY_NAME] = true
    yield
  ensure
    Thread.current[KEY_NAME] = false
  end

  def self.ignoring?
    Thread.current[KEY_NAME] == true
  end
end
