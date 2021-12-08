require 'ffaker'

FactoryBot.define do
  factory :pdf do
    id { Noid::Rails::Service.new.mint }
    title [FFaker::Book.title]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    displays_in ['nowhere']
    rights_statement ['http://bostonhistory.org/photorequest.html']
    date_created ['1500']
    transient do
      user nil
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
    Pdf.properties.each_value do |property|
      next if [:create_date, :date_modified, :modified_date, :date_uploaded, :has_model, :head, :tail, :ordered_descriptions, :ordered_creators].include? property.term
      if property.term == :title
        send(property.term, [FFaker::Book.title])
      elsif property.try(:multiple?)
        send(property.term, (1..4).map { FFaker::HipsterIpsum.phrase })
      else
        send(property.term, FFaker::HipsterIpsum.phrase)
      end
    end
  end
end
