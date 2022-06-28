# frozen_string_literal: true
require 'rails_helper'
require "rake"

Rails.application.load_tasks

describe "tufts:embargo_expirations" do
  after do
    Rake::Task["tufts:embargo_expiration"].clear
  end

  context "emargo expiration task" do
    # let(:arg1) {"foo"}
    # let(:arg2) {"baz"}

    it "runs without throwing an exception" do
      expect { Rake::Task["tufts:embargo_expiration"].invoke }.not_to raise_exception
    end
  end
end
