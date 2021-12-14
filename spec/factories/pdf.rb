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
end
