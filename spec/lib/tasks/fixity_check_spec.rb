# frozen_string_literal: true
require 'rails_helper'
require "rake"

Rails.application.load_tasks if Rake::Task.tasks.empty?

describe "tdr:fixity_checks" do
  after do
    Rake::Task["tdr:fixity_check"].clear
  end

  context "Running fixity checks" do
    # let(:arg1) {"foo"}
    # let(:arg2) {"baz"}

    it "does a random sampling" do
      expect { Rake::Task["tdr:fixity_check"].invoke }.to output("Random sampling fixity check complete\n").to_stdout

      # assert the expected behaviour here related for foo case
    end
  end
end
