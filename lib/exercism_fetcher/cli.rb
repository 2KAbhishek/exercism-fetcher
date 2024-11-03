# frozen_string_literal: true

require "thor"

module ExercismFetcher
  # CLI for fetcher
  class CLI < Thor
    desc "fetch", "Fetch Exercism exercises"
    method_option :language, type: :string, desc: "Specific language to fetch"
    method_option :output, type: :string, default: "exercism_data", desc: "Output directory"

    def fetch
      fetcher = DataFetcher.new

      languages = if options[:language]
                    [options[:language].downcase]
                  else
                    fetcher.fetch_languages
                  end

      languages.sort.each do |language|
        exercises = fetcher.fetch_exercises(language)
        next if exercises.empty?

        fetcher.write_language_json(language, exercises, options[:output])
        puts "✓ Fetched exercises for #{language}"
      end
    rescue Error => e
      puts "Error: #{e.message}"
      exit 1
    end

    default_task :fetch
  end
end
