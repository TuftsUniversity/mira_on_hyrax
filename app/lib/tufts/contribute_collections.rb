# frozen_string_literal: true
module Tufts
  # Create and maintain the Collection objects required by the Contribute controller
  class ContributeCollections
    attr_reader :seed_data

    def initialize
      @seed_data = make_seed_data_hash
    end

    def make_seed_data_hash
      seed_hash = {}
      SEED_DATA.each do |c|
        call_number = c[:call_number]
        seed_hash[call_number] = c
      end
      seed_hash
    end

    def self.create
      Tufts::ContributeCollections.new.create
    end

    def create
      default = Hyrax::CollectionType.find_or_create_default_collection_type
      # admin_set = Hyrax::CollectionType.find_or_create_admin_set_type
      @seed_data.each_key do |call_number|
        find_or_create_collection(call_number, default)
      end
    end

    # Given a collection's call number, find or create the collection.
    # If the collection has been deleted, eradicate it so the id can be
    # re-used, and re-create the collection object.
    # @param [String] call_number
    # @return [Collection]
    def find_or_create_collection(call_number, default)
      col = Collection.where(call_number: call_number)
      create_collection(call_number, default) if col.empty?
    end

    # @param [String] call_number
    # @return [Collection]
    def create_collection(call_number, default = Hyrax::CollectionType.find_or_create_default_collection_type)
      collection = Collection.new
      collection_hash = @seed_data[call_number]
      collection.title = Array(collection_hash[:title])
      collection.call_number = Array(collection_hash[:call_number])
      collection.finding_aid = Array(collection_hash[:finding_aid])
      collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      collection.collection_type = default
      collection.save
      collection
    end

    # Convenience method for use by the contribute controller
    # @param [Class] work_type
    # @return [Collection]
    # @example
    #  Tufts::ContributeCollections.collection_for_work_type(FacultyScholarship)
    def self.collection_for_work_type(work_type)
      Tufts::ContributeCollections.new.collection_for_work_type(work_type)
    end

    # For a given work type, determine which Collection contributions should go into.
    # If that collection object doesn't exist for some reason, create it.
    # @param [Class] work_type
    # @return [Collection]
    def collection_for_work_type(work_type)
      call_number = @seed_data.select { |_key, hash| hash[:work_types].include? work_type }.keys.first

      cols = Collection.where(call_number: call_number)
      if cols.empty?
        create_collection(call_number)
      else
        cols.first
      end
    end

    SEED_DATA = [
      {
        title: "Tufts Published Scholarship, 1987-2014",
        call_number: "PB",
        finding_aid: "https://archives.tufts.edu/repositories/2/resources/100",
        work_types: [GenericDeposit, GenericTischDeposit, GisPoster, UndergradSummerScholar, FacultyScholarship]
      },
      {
        title: "Fletcher School Records, 1923 -- 2016",
        call_number: "UA015",
        finding_aid: "https://archives.tufts.edu/repositories/2/resources/120",
        work_types: [CapstoneProject]
      },
      {
        title: "Cummings School of Veterinary Medicine records, 1969-2012",
        call_number: "UA041",
        finding_aid: "https://archives.tufts.edu/repositories/2/resources/4",
        work_types: [CummingsThesis]
      },
      {
        title: "Undergraduate honors theses, 1929-2015",
        call_number: "UA005",
        finding_aid: "https://archives.tufts.edu/repositories/2/resources/123",
        work_types: [HonorsThesis]
      },
      {
        title: "Public Health and Professional Degree Programs Records, 1990 -- 2011",
        call_number: "UA187",
        finding_aid: "https://archives.tufts.edu/repositories/2/resources/253",
        work_types: [PublicHealth]
      },
      {
        title: "Department of Education records, 2007-02-01-2014",
        call_number: "UA071",
        finding_aid: "https://archives.tufts.edu/repositories/2/resources/9",
        work_types: [QualifyingPaper]
      }
    ].freeze
  end
end
