# frozen_string_literal: true

require "json"
require "open3"
require "fileutils"

module ExercismFetcher
  class DataFetcher
    def initialize
      check_gh_installation
    end

    def fetch_languages
      stdout, stderr, status = Open3.capture3(
        "gh repo list exercism -L 1000 --json name,description"
      )
      raise Error, "Failed to fetch repositories: #{stderr}" unless status.success?

      repos = JSON.parse(stdout)
      repos.filter_map do |repo|
        next unless repo["description"]&.match?(/Exercism exercises in/i)

        repo["name"].downcase
      end
    end

    def fetch_exercises(language)
      exercises = []
      %w[concept practice].each do |type|
        dir_content = fetch_directory_content(language, type)
        exercises += dir_content.reject { |exercise| exercise.start_with?(".") }
                                .map { |exercise| { name: exercise, type: type } }
      end
      exercises
    end

    def write_language_json(language, exercises, output_dir)
      FileUtils.mkdir_p(output_dir)
      File.write(
        File.join(output_dir, "#{language}.json"),
        JSON.pretty_generate(exercises)
      )
    end

    private

    def check_gh_installation
      _, _, status = Open3.capture3("gh --version")
      raise Error, "GitHub CLI (gh) is not installed. Please install it first." unless status.success?
    end

    def fetch_directory_content(language, type)
      path = "exercises/#{type}"
      stdout, _, status = Open3.capture3(
        "gh api /repos/exercism/#{language}/contents/#{path} --jq '.[].name'"
      )

      return [] unless status.success?

      stdout.split("\n")
    rescue StandardError
      []
    end
  end
end
