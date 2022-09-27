# frozen_string_literal: true
require 'rails_helper'
require "rake"

describe "tdr:fixity_checks", type: :rake do
  before do
    load_rake_environment [File.expand_path("../../../../lib/tasks/fixity_check.rake", __FILE__)]
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
