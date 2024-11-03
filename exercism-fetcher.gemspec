# frozen_string_literal: true

require_relative "lib/exercism_fetcher/version"

Gem::Specification.new do |spec|
  spec.name = "exercism-fetcher"
  spec.authors = ["Abhishek Keshri"]
  spec.email = ["iam2kabhishek@gmail.com"]
  spec.version = ExercismFetcher::VERSION

  spec.required_ruby_version = ">= 2.6.0"
  spec.summary = "Fetch Exercism exercise data from GitHub"
  spec.description = "A command-line tool to fetch and organize Exercism exercise data from GitHub repositories"
  spec.homepage = "https://github.com/2KAbhishek/exercism-fetcher"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "thor", "~> 1.2"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
