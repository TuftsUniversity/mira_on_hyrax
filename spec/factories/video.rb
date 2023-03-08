# frozen_string_literal: true
FactoryBot.define do
  factory :video do
    title { [FFaker::Book.title] }
    displays_in { ['nowhere'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    rights_statement { ['http://bostonhistory.org/photorequest.html'] }
  end
end

FactoryBot.define do
  factory :tufts_video, class: Video do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { 'c792gt25f' }
    transcript_id { 'c821gw16r' }
    title { ['Philosophy 167: Class 1 - Part 1'] }
    displays_in { ['nowhere'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    rights_statement { ['http://bostonhistory.org/photorequest.html'] }
    description { ['This video sets the expectations of the course, reviews the syllabus, and briefly discusses history and philosophy of science.'] }

    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['A Contained FileSet'], id: 'c791gr27p')
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['Fileset for transcript'], id: 'c821gw16r')
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      video_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'files', 'video_philosophy_167_Class_1_part_1.mp4')))

      original_file = work.file_sets[0].build_original_file

      original_file.mime_type = 'video/mp4' # If this were an actual object created in Mira, this would be the archival .mp4 file,
      original_file.content = video_test_file
      work.file_sets[0].visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work.file_sets[0].save

      transcript_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'files', 'video_philosophy_167_Class_1_part_1.xml')))
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
