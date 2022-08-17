# frozen_string_literal: true
require 'rails_helper'
require "rake"

describe "rake tasks for publishing and unpublishing objects" do
  describe "tdr:unpublish_objects" do
    before do
      load_rake_environment [File.expand_path("../../../../lib/tasks/publishing.rake", __FILE__)]
    end

    context "Unpublishing objects" do
      it "expects arguments" do
        stdout = run_task "tdr:unpublish_objects"
        expect(stdout).to include("example usage: rake unpublish_objects /usr/local/samvera/epigaea/unpublish_objects.txt")
      end
    end
  end

  describe "tdr:publish_objects" do
    let(:publishing_file) { Rails.root.join('spec', 'fixtures', 'files', 'objects_for_publishing.txt').to_s }

    before do
      load_rake_environment [File.expand_path("../../../../lib/tasks/publishing.rake", __FILE__)]
    end

    context "Publishing objects" do
      it "expects arguments" do
        stdout = run_task "tdr:publish_objects"
        expect(stdout).to include("example usage: rake publish_objects /usr/local/samvera/epigaea/publish_objects.txt")
      end

      it "loads a pid file" do
        stdout = run_task("tdr:publish_objects", publishing_file)
        expect(stdout).to include("Loading File")
      end
    end
  end
end
