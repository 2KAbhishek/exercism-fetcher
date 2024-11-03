# frozen_string_literal: true

require "spec_helper"

RSpec.describe ExercismFetcher::CLI do
  let(:cli) { described_class.new }
  let(:fetcher) { instance_double(ExercismFetcher::Fetcher) }

  before do
    allow(ExercismFetcher::Fetcher).to receive(:new).and_return(fetcher)
  end

  describe "#fetch" do
    context "with specific language" do
      it "fetches exercises for the specified language" do
        allow(fetcher).to receive(:fetch_exercises)
          .with("ruby")
          .and_return([{ name: "basics", type: "concept" }])
        allow(fetcher).to receive(:write_language_json)

        cli.options = { language: "ruby", output: "test_output" }
        expect { cli.fetch }.not_to raise_error
      end
    end

    context "without specific language" do
      before do
        allow(fetcher).to receive(:fetch_languages).and_return(%w[xyz_lang ruby])
        allow(fetcher).to receive(:fetch_exercises)
          .with("ruby")
          .and_return([{ name: "basics", type: "concept" }])
        allow(fetcher).to receive(:fetch_exercises)
          .with("xyz_lang")
          .and_return([])
        allow(fetcher).to receive(:write_language_json)
      end

      it "fetches exercises for all languages" do
        expect { cli.fetch }.not_to raise_error
      end

      it "sorts languages before fetching exercises" do
        cli.fetch
        expect(fetcher).to have_received(:fetch_exercises).with("ruby").ordered
        expect(fetcher).to have_received(:fetch_exercises).with("xyz_lang").ordered
      end

      it "writes json only for languages that contain exercises" do
        cli.fetch
        expect(fetcher).to have_received(:write_language_json).once
      end
    end
  end
end
