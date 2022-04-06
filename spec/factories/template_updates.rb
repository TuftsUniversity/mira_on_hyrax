# frozen_string_literal: true
FactoryBot.define do
  factory :template_update do
    behavior      { TemplateUpdate::OVERWRITE }
    ids           { ['abc', '123'] }
    template_name { 'Moomin Template' }
  end
end
