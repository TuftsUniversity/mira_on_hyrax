# frozen_string_literal: true

FactoryBot.define do
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
  end
end
