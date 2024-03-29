# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tufts::ContributeCollections, :clean do
  let(:cc) { described_class.new }

  it "has a hash of all the collections to be made, with their ids and titles" do
    expect(cc.seed_data).to be_instance_of(Hash)
  end

  context "creating all the collections" do
    before do
      described_class.create
    end
    it "creates a collection object for each item in the seed array" do
      expect(Collection.count).to eq(6)
    end
    it "populates title, call number and finding aid" do
      c = Collection.where(call_number: "PB")
      expect(c.first.title.first).to eq("Tufts Published Scholarship")
      expect(c.first.call_number.first).to eq("PB")
      expect(c.first.finding_aid.first).to eq("https://archives.tufts.edu/repositories/2/resources/100")
    end
  end

  context "putting contributed works into collections" do
    before do
      described_class.create
    end
    it "finds the right collection for a given work type" do
      faculty_scholarship_collection = cc.collection_for_work_type(FacultyScholarship)
      expect(faculty_scholarship_collection).to be_instance_of(Collection)
      expect(faculty_scholarship_collection.call_number).to eq(['PB'])
      expect(faculty_scholarship_collection.finding_aid).to eq(['https://archives.tufts.edu/repositories/2/resources/100'])
    end
    it "recovers if one of the expected collections has been deleted" do
      Collection.where(call_number: 'PB').first.delete
      faculty_scholarship_collection = cc.collection_for_work_type(FacultyScholarship)
      expect(faculty_scholarship_collection).to be_instance_of(Collection)
      expect(faculty_scholarship_collection.call_number).to eq(['PB'])
      expect(faculty_scholarship_collection.finding_aid).to eq(['https://archives.tufts.edu/repositories/2/resources/100'])
    end
  end
end
