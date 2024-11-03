# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe ExercismFetcher::Fetcher do
  let(:fetcher) { described_class.new }

  before do
    allow(Open3).to receive(:capture3)
      .with("gh --version")
      .and_return(["gh version 2.0.0", "", double(success?: true)])
  end

  describe "#fetch_languages" do
    it "extracts language repositories with exercise descriptions" do
      sample_response = [
        '{"name": "ruby", "description": "Exercism exercises in Ruby"}',
        '{"name": "python", "description": "Exercism exercises in Python"}',
        '{"name": "website", "description": "The Exercism website"}'
      ].join("\n")

      allow(Open3).to receive(:capture3)
        .with('gh repo list exercism -L 1000 --json name,description --jq ".[] | {name: .name, description: .description}"')
        .and_return([sample_response, "", double(success?: true)])

      expect(fetcher.fetch_languages).to eq(%w[ruby python])
    end

    it "handles invalid JSON lines gracefully" do
      sample_response = [
        '{"name": "ruby", "description": "Exercism exercises in Ruby"}',
        "invalid json line",
        '{"name": "python", "description": "Exercism exercises in Python"}'
      ].join("\n")

      allow(Open3).to receive(:capture3)
        .with('gh repo list exercism -L 1000 --json name,description --jq ".[] | {name: .name, description: .description}"')
        .and_return([sample_response, "", double(success?: true)])

      expect(fetcher.fetch_languages).to eq(%w[ruby python])
    end

    it "raises an error when gh command fails" do
      allow(Open3).to receive(:capture3)
        .with('gh repo list exercism -L 1000 --json name,description --jq ".[] | {name: .name, description: .description}"')
        .and_return(["", "Error", double(success?: false)])

      expect { fetcher.fetch_languages }.to raise_error(ExercismFetcher::Error, /Failed to fetch repositories/)
    end
  end

  describe "#fetch_exercises" do
    it "fetches exercises for both concept and practice directories" do
      allow(Open3).to receive(:capture3)
        .with("gh api /repos/exercism/ruby/contents/exercises/concept --jq '.[].name'")
        .and_return(["basics", "", double(success?: true)])

      allow(Open3).to receive(:capture3)
        .with("gh api /repos/exercism/ruby/contents/exercises/practice --jq '.[].name'")
        .and_return(["hello-world", "", double(success?: true)])

      exercises = fetcher.fetch_exercises("ruby")
      expect(exercises).to contain_exactly(
        { name: "basics", type: "concept" },
        { name: "hello-world", type: "practice" }
      )
    end

    it "does not include hidden directories" do
      allow(Open3).to receive(:capture3)
        .with("gh api /repos/exercism/ruby/contents/exercises/concept --jq '.[].name'")
        .and_return(["basics\n.keep", "", double(success?: true)])

      allow(Open3).to receive(:capture3)
        .with("gh api /repos/exercism/ruby/contents/exercises/practice --jq '.[].name'")
        .and_return([".hidden_dir", "", double(success?: true)])

      exercises = fetcher.fetch_exercises("ruby")
      expect(exercises).to contain_exactly(
        { name: "basics", type: "concept" }
      )
    end

    it "returns empty array when directory is not found" do
      allow(Open3).to receive(:capture3)
        .with("gh api /repos/exercism/ruby/contents/exercises/concept --jq '.[].name'")
        .and_return(["", "404 Not Found", double(success?: false)])

      allow(Open3).to receive(:capture3)
        .with("gh api /repos/exercism/ruby/contents/exercises/practice --jq '.[].name'")
        .and_return(["", "404 Not Found", double(success?: false)])

      exercises = fetcher.fetch_exercises("ruby")
      expect(exercises).to be_empty
    end
  end

  describe "#write_language_json" do
    it "writes exercises to a JSON file" do
      exercises = [
        { name: "basics", type: "concept" },
        { name: "hello-world", type: "practice" }
      ]

      Dir.mktmpdir do |dir|
        fetcher.write_language_json("ruby", exercises, dir)
        json_content = JSON.parse(File.read(File.join(dir, "ruby.json")), symbolize_names: true)
        expect(json_content).to eq(exercises)
      end
    end
  end
end
