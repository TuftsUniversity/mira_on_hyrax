# frozen_string_literal: true
shared_examples 'a form with Tufts metadata attributes' do
  # rubocop:disable RSpec/ExampleLength
  context 'and the form' do
    it 'has the required fields' do
      expect(form.required_fields).to eq([:title, :displays_in])
    end

    it 'has Tufts terms' do
      expect(form.terms).to include(:abstract, :accrual_policy, :admin_start_date,
                                    :alternative_title, :audience, :corporate_name,
                                    :createdby, :creator_department, :date_accepted,
                                    :date_available, :date_copyrighted, :date_issued,
                                    :displays_in, :dissertation_type, :downloadable,
                                    :embargo_note, :end_date, :extent, :format_label,
                                    :funder, :genre, :geographic_name, :geog_name,
                                    :has_part, :held_by, :internal_note, :is_part_of,
                                    :is_replaced_by, :legacy_pid, :personal_name,
                                    :primary_date, :provenance, :qr_note, :qr_status,
                                    :rejection_reason, :replaces, :retention_period,
                                    :rights_holder, :rights_note, :steward,
                                    :table_of_contents, :temporal, :tufts_license)
    end
  end
end
