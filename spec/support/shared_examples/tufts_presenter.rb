# frozen_string_literal: true
shared_examples 'a Tufts presenter' do
  subject(:presenter) { described_class.new(double, double) }
  describe "with custom attributes that are delegated to Solr and" do
    it { is_expected.to delegate_method(:geographic_name).to(:solr_document) }
    it { is_expected.to delegate_method(:displays_in).to(:solr_document) }
    it { is_expected.to delegate_method(:alternative_title).to(:solr_document) }
    it { is_expected.to delegate_method(:abstract).to(:solr_document) }
    it { is_expected.to delegate_method(:table_of_contents).to(:solr_document) }
    it { is_expected.to delegate_method(:primary_date).to(:solr_document) }
    it { is_expected.to delegate_method(:date_accepted).to(:solr_document) }
    it { is_expected.to delegate_method(:date_available).to(:solr_document) }
    it { is_expected.to delegate_method(:date_copyrighted).to(:solr_document) }
    it { is_expected.to delegate_method(:date_issued).to(:solr_document) }
    it { is_expected.to delegate_method(:resource_type).to(:solr_document) }
    it { is_expected.to delegate_method(:bibliographic_citation).to(:solr_document) }
    it { is_expected.to delegate_method(:rights_holder).to(:solr_document) }
    it { is_expected.to delegate_method(:format_label).to(:solr_document) }
    it { is_expected.to delegate_method(:replaces).to(:solr_document) }
    it { is_expected.to delegate_method(:is_replaced_by).to(:solr_document) }
    it { is_expected.to delegate_method(:has_part).to(:solr_document) }
    it { is_expected.to delegate_method(:extent).to(:solr_document) }
    it { is_expected.to delegate_method(:personal_name).to(:solr_document) }
    it { is_expected.to delegate_method(:corporate_name).to(:solr_document) }
    it { is_expected.to delegate_method(:genre).to(:solr_document) }
    it { is_expected.to delegate_method(:provenance).to(:solr_document) }
    it { is_expected.to delegate_method(:temporal).to(:solr_document) }
    it { is_expected.to delegate_method(:funder).to(:solr_document) }
  end

  describe "with admin attributes that are delegated to Solr" do
    it { is_expected.to delegate_method(:steward).to(:solr_document) }
    it { is_expected.to delegate_method(:internal_note).to(:solr_document) }
    it { is_expected.to delegate_method(:audience).to(:solr_document) }
    it { is_expected.to delegate_method(:end_date).to(:solr_document) }
    it { is_expected.to delegate_method(:accrual_policy).to(:solr_document) }
    it { is_expected.to delegate_method(:rights_note).to(:solr_document) }
    it { is_expected.to delegate_method(:tufts_license).to(:solr_document) }
    it { is_expected.to delegate_method(:retention_period).to(:solr_document) }
    it { is_expected.to delegate_method(:admin_start_date).to(:solr_document) }
    it { is_expected.to delegate_method(:qr_status).to(:solr_document) }
    it { is_expected.to delegate_method(:rejection_reason).to(:solr_document) }
    it { is_expected.to delegate_method(:qr_note).to(:solr_document) }
    it { is_expected.to delegate_method(:creator_department).to(:solr_document) }
    it { is_expected.to delegate_method(:legacy_pid).to(:solr_document) }
    it { is_expected.to delegate_method(:createdby).to(:solr_document) }
    it { is_expected.to delegate_method(:is_part_of).to(:solr_document) }
  end
end
