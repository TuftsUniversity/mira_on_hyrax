# frozen_string_literal: true
require 'rails_helper'
require "rake"

describe "rake tasks for metadata remediation" do
  describe "tdr:blank_out_field" do
    before do
      load_rake_environment [File.expand_path("../../../../lib/tasks/metadata_remediation.rake", __FILE__)]
    end

    context "blanking out fields" do
      let(:blank_out_file) { Rails.root.join('spec', 'fixtures', 'files', 'blank_out_file.txt').to_s }

      it "requires valid pids" do
        stdout = run_task("tdr:blank_out_field", blank_out_file)
        expect(stdout).to include("WARN: Can't find somepid, skipping..")
      end
    end
  end
end
