# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tufts::TranscriptUtils do
  context "update_index" do
    after do
      File.exist?("index_fix_index.txt") && File.delete("index_fix_index.txt")
    end

    before do
      FactoryBot.create(:tufts_MS123_audio)
      FactoryBot.create(:tufts_video)
    end

    it "saves its last index as an offset" do
      described_class.update_index(0, 10)
      expect(File.exist?("index_fix_index.txt")).to equal(true)
    end

    # rubocop:disable RSpec/ExampleLength
    it "loops over mutliple attempts" do
      old_video = grab_video_object
      old_audio = grab_audio_object
      described_class.update_index(0, 10)
      video = grab_video_object
      audio = grab_audio_object
      check_object_updated(old_video, video)
      check_object_updated(old_audio, audio)
    end

    it "updates the index for videos" do
      old_video = grab_video_object
      described_class.update_index(0, 10)
      video = grab_video_object
      check_object_updated(old_video, video)
    end

    it "updates the index for audio" do
      old_audio = grab_audio_object
      described_class.update_index(0, 10)
      audio = grab_audio_object
      check_object_updated(old_audio, audio)
    end

    def check_object_updated(old_object, object)
      expect(object["id"]).to eq(old_object["id"])
      expect(object["timestamp"]).not_to eq(old_object["timestamp"])
    end

    def grab_video_object
      ActiveFedora.solr.conn.get('select', params: { fq: 'has_model_ssim:Video', defType: 'edismax' })["response"]["docs"][0]
    end

    def grab_audio_object
      ActiveFedora.solr.conn.get('select', params: { fq: 'has_model_ssim:Audio', defType: 'edismax' })["response"]["docs"][0]
    end
  end
end
