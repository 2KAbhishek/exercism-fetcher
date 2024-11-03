# frozen_string_literal: true

require_relative "exercism_fetcher/version"
require_relative "exercism_fetcher/fetcher"
require_relative "exercism_fetcher/cli"

# Main module
module ExercismFetcher
  class Error < StandardError; end

  def self.root
    File.dirname __dir__
  end
end
