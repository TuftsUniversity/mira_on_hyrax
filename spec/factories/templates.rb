# frozen_string_literal: true
FactoryBot.define do
  factory :template, class: Tufts::Template do
    name { 'Moomin Template' }

    initialize_with { new(name: name) }
  end
end
