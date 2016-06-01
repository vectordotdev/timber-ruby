module Timber
  # Ignores any log lines written
  #
  # Timber.ignore do
  #   # code
  # end
  def self.ingnore(&block)
    Thread.current[:_timber_ignoring] = true
    yield
  ensure
    Thread.current[:_timber_ignoring] = false
  end

  def self.ignoring?
    Thread.current[:_timber_ignoring] == true
  end
end
