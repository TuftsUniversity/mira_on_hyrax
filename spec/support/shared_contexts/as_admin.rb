# frozen_string_literal: true
RSpec.shared_context 'as admin' do
  let(:user) { FactoryBot.create(:admin) }
  before     { sign_in user }
end
