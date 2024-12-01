# frozen_string_literal: true

RSpec.describe ExercismFetcher do
  describe ".root" do
    it "returns the root directory of the project" do
      expected_root = File.dirname(File.dirname(__FILE__))
      expect(described_class.root).to eq(expected_root)
    end
  end

  it "has a version number" do
    expect(ExercismFetcher::VERSION).to eq("0.1.0")
    expect(ExercismFetcher::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
