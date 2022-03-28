# frozen_string_literal: true
FactoryBot.define do
  factory :ead do
    title { ['Test'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  end
end
