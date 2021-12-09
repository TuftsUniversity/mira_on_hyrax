FactoryBot.define do
  factory :batch do
    association :batchable, factory: :template_update
    user { create(:user) }
    ids { ['abc', '123'] }
  end
end
