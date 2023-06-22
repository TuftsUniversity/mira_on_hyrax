# frozen_string_literal: true
require 'ffaker'

FactoryBot.define do
  factory :pdf do
    id { Noid::Rails::Service.new.mint }
    title { [FFaker::Book.title] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    displays_in { ['nowhere'] }
    rights_statement { ['http://bostonhistory.org/photorequest.html'] }
    date_created { ['1500'] }
    transient do
      user { nil }
    end

    factory :published_pdf do
      after(:create) do |work, evaluator|
        Tufts::WorkflowStatus
          .publish(work: work,
                   current_user: evaluator.user,
                   comment: 'Published by :published_pdf factory in `after_create` hook.')
      end
    end
  end

  factory :populated_pdf, class: Pdf do
    title { [FFaker::Book.title] }
    subject { [FFaker::Lorem.word, FFaker::Lorem.word] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    displays_in { ['nowhere'] }
    rights_statement { ['http://bostonhistory.org/photorequest.html'] }
    date_created { ['1999'] }
    publisher { [FFaker::Company.name, FFaker::Company.name] }
    description { [FFaker::HipsterIpsum.paragraph] }
    abstract { [FFaker::HipsterIpsum.paragraph] }
    creator { [FFaker::Name.name, FFaker::Name.name] }
    corporate_name { [FFaker::Company.name] }
    contributor { [FFaker::Name.name] }
  end

  factory :embargoed_work_with_files, class: Pdf do
    transient do
      embargo_date { Date.tomorrow.to_s }
      current_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      future_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      user { FactoryBot.create(:user) } # find_or_create ???
    end

    title { [FFaker::Book.title] }
    subject { [FFaker::Lorem.word, FFaker::Lorem.word] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    displays_in { ['nowhere'] }
    rights_statement { ['http://bostonhistory.org/photorequest.html'] }
    date_created { ['1999'] }
    publisher { [FFaker::Company.name, FFaker::Company.name] }
    description { [FFaker::HipsterIpsum.paragraph] }
    abstract { [FFaker::HipsterIpsum.paragraph] }
    creator { [FFaker::Name.name, FFaker::Name.name] }
    corporate_name { [FFaker::Company.name] }
    contributor { [FFaker::Name.name] }
    after(:build) { |work, evaluator| work.apply_embargo(evaluator.embargo_date, evaluator.current_state, evaluator.future_state) }
    after(:create) { |work, evaluator| 2.times { work.ordered_members << FactoryBot.create(:file_set, user: evaluator.user) } }
  end
end
