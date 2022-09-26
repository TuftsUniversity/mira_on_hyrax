# frozen_string_literal: true
require 'rails_helper'
require "rake"

describe "tufts:embargo_expirations", type: :rake do
  before do
    load_rake_environment [File.expand_path("../../../../lib/tasks/embargo_notifications.rake", __FILE__)]
  end

  context "emargo expiration task" do
    # let(:arg1) {"foo"}
    # let(:arg2) {"baz"}

    it "runs without throwing an exception" do
      expect { Rake::Task["tufts:embargo_expiration"].invoke }.not_to raise_exception
    end
  end
end
