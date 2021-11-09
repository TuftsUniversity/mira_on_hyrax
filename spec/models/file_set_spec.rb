require 'rails_helper'

RSpec.describe FileSet do
  it { is_expected.to be_a Tufts::Curation::FileSet }
  it { is_expected.to respond_to(:downloadable) }
end
