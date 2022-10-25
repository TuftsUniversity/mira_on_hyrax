# frozen_string_literal: true
shared_examples 'has technical metadata attributes' do
  it 'has identifier' do
    work.identifier = ['Test ID']
    expect(work.resource.dump(:ttl))
      .to match(/identifier/)
  end

  it 'has language' do
    work.language = ['English']
    expect(work.resource.dump(:ttl))
      .to match(/language/)
  end

  it 'has date_modified' do
    work.date_modified = '12/17/22'
    expect(work.resource.dump(:ttl))
      .to match(/modified/)
  end
end
