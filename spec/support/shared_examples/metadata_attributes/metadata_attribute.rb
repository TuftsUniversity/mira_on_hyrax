# frozen_string_literal: true
shared_examples 'a work with Tufts metadata attributes' do
  it_behaves_like 'and has admin metadata attributes'
  it_behaves_like 'and has descriptive metadata attributes'
  it_behaves_like 'and has technical metadata attributes'
  it_behaves_like 'a work with custom Tufts validations'
  it_behaves_like 'a record with ordered fields'
  it_behaves_like 'a work with facetable years'
end
