# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Cop::Styles::CommitTrailerCollaboratorCapitalization do
  subject(:cop) { described_class.new commit: commit }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Cop::Commits::Saved.new(sha: "abc", shell: shell),
                  trailer_lines: trailer_lines,
                  trailer_index: 2
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_trailer_collaborator_capitalization)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Trailer Collaborator Capitalization")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error
      )
    end
  end

  describe "#valid?" do
    context "with no matching key" do
      let(:trailer_lines) { ["Unknown: value"] }

      it "answers true" do
        expect(cop.valid?).to eq(true)
      end
    end

    context "with valid capitalization" do
      let(:trailer_lines) { ["Co-Authored-By: Test Example <test@example.com>"] }

      it "answers true" do
        expect(cop.valid?).to eq(true)
      end
    end

    context "with invalid capitalization" do
      let(:trailer_lines) { ["Co-Authored-By: test <test@example.com>"] }

      it "answers false" do
        expect(cop.valid?).to eq(false)
      end
    end

    context "with missing name" do
      let(:trailer_lines) { ["Co-Authored-By: <example.com>"] }

      it "answers true" do
        expect(cop.valid?).to eq(true)
      end
    end
  end

  describe "#issue" do
    let(:issue) { cop.issue }

    context "when valid" do
      let(:trailer_lines) { ["Co-Authored-By: Test Example <test@example.com>"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:trailer_lines) { ["Co-Authored-By: Test example <test@example.com>"] }

      it "answers issue" do
        expect(issue).to eq(
          hint: "Name must be capitalized.",
          lines: [
            {
              content: "Co-Authored-By: Test example <test@example.com>",
              number: 4
            }
          ]
        )
      end
    end
  end
end
