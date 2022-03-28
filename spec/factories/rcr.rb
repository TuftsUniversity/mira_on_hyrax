# frozen_string_literal: true
FactoryBot.define do
  factory :rcr do
    title { ['Test'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  end
end
