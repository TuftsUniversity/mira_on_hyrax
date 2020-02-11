# frozen_string_literal: true

FactoryGirl.define do
  factory :file_set do
    transient do
      user { create(:user) }
      content { nil }
    end
    after(:build) do |fs, evaluator|
      fs.apply_depositor_metadata evaluator.user.user_key
    end

    after(:create) do |file, evaluator|
      Hydra::Works::UploadFileToFileSet.call(file, evaluator.content) if evaluator.content
    end

    trait :public do
      read_groups { ["public"] }
    end

    trait :registered do
      read_groups { ["registered"] }
    end

    trait :with_public_embargo do
      after(:build) do |file, evaluator|
        file.embargo = FactoryGirl.create(:public_embargo, embargo_release_date: evaluator.embargo_release_date)
      end
    end

    factory :file_with_work do
      after(:build) do |file, _evaluator|
        file.title = ['testfile']
      end
      after(:create) do |file, evaluator|
        Hydra::Works::UploadFileToFileSet.call(file, evaluator.content) if evaluator.content
        create(:work, user: evaluator.user).members << file
      end
    end
  end
end