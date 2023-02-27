# frozen_string_literal: true
FactoryBot.define do
  factory :tufts_MS123_audio, class: Audio do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { '1234jt5bg' }
    transcript_id { '1234jt5tr' }
    title { ['Interview with Horace Works'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    description { ['Interview conducted by Kenneth J. Cleary.'] }

    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['Fileset for audio'], id: '1234jt5fs')
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['Fileset for transcript'], id: '1234jt5tr')
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      audio_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'files', 'MS123.001.001.00002.mp3')))
      original_file = work.file_sets[0].build_original_file

      original_file.mime_type = 'audio/mpeg'   # If this were an actual object created in Mira, this would be the archival .wav file,
      original_file.content = audio_test_file  # instead of the .mp3, but the code in audio_presenter.rb only cares that it isn't text/xml.
      work.file_sets[0].visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work.file_sets[0].save

      transcript_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'files', 'MS123.001.001.00002.tei.xml')))
      original_file = work.file_sets[1].build_original_file
      original_file.mime_type = 'text/xml'
      original_file.content = transcript_test_file
      work.file_sets[1].visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work.file_sets[1].save

      work.file_sets[0].save
      work.save
    end
  end
end
