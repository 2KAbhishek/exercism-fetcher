# frozen_string_literal: true

require "thor"

module ExercismFetcher
  class CLI < Thor
    desc "fetch", "Fetch Exercism exercises"
    method_option :language, type: :string, desc: "Specific language to fetch"
    method_option :output, type: :string, default: "exercism_data", desc: "Output directory"

    def fetch
      fetcher = DataFetcher.new
      languages = options[:language] ? [options[:language].downcase] : fetcher.fetch_languages
      process_languages(fetcher, languages)
    rescue Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    private

    def process_languages(fetcher, languages)
      languages.sort.each do |language|
        exercises = fetcher.fetch_exercises(language)
        next if exercises.empty?

        fetcher.write_language_json(language, exercises, options[:output])
        puts "✓ Fetched exercises for #{language}"
      end
    end

    default_task :fetch
  end
end
