# frozen_string_literal: true
shared_examples 'and has descriptive metadata attributes' do
  it 'has contributor' do
    work.contributor = ['Rovner, LIsa, film director, screenwriter']
    expect(work.resource.dump(:ttl))
      .to match(/contributor/)
  end

  it 'has creator' do
    work.creator = ['Dennett, D. C. (Daniel Clement)']
    expect(work.resource.dump(:ttl))
      .to match(/creator/)
  end

  it 'has date_modified' do
    work.date_modified = '12/17/22'
    expect(work.resource.dump(:ttl))
      .to match(/modified/)
  end

  it 'has date_uploaded' do
    work.date_uploaded = '10/28/21'
    expect(work.resource.dump(:ttl))
      .to match(/dateSubmitted/)
  end

  it 'has dc_access_rights' do
    work.dc_access_rights = ['True']
    expect(work.resource.dump(:ttl))
      .to match(/accessRights/)
  end

  it 'has subject' do
    work.subject = ['Physics']
    expect(work.resource.dump(:ttl))
      .to match(/subject/)
  end

  it 'has publisher' do
    work.publisher = ['Penguin']
    expect(work.resource.dump(:ttl))
      .to match(/publisher/)
  end

  it 'has oclc' do
    work.oclc = ['677375104']
    expect(work.resource.dump(:ttl))
      .to match(/oclc/)
  end
  
  it 'has isbn' do
    work.isbn = ['9780790506395']
    expect(work.resource.dump(:ttl))
      .to match(/isbn/)
  end

  it 'has doi' do
    work.doi = '387415'
    expect(work.resource.dump(:ttl))
      .to match(/doi/)
  end

  it 'has description' do
    work.description = ['A drawing of New Jersey governor James Florio with an incinerator in the background.']
    expect(work.resource.dump(:ttl))
      .to match(/description/)
  end

  it 'has displays_in' do
    work.displays_in = ['nowhere', 'trove']
    expect(work.resource.dump(:ttl))
      .to match(/dl\.tufts\.edu\/terms\#displays_in/)
  end

  it 'has geographic_names' do
    work.geographic_name = ['China']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/spatial/)
  end

  it 'has geog_names' do
    work.geog_name = ['China']
    expect(work.resource.dump(:ttl))
      .to match(/dl\.tufts\.edu\/terms\#geog_name/)
  end

  it 'has held by' do
    work.held_by = ['United States']
    expect(work.resource.dump(:ttl))
      .to match(/bibframe\.org\/vocab\/heldBy/)
  end

  it 'has alternative title' do
    work.alternative_title = ['An alternative title']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/alternative/)
  end

  it 'has abstract' do
    work.abstract = ['A descriptive abstract']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/abstract/)
  end

  it 'has table of contents' do
    work.table_of_contents = ['Chapter 1']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/tableOfContents/)
  end

  it 'has primary date' do
    work.primary_date = ['12/31/99']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/elements\/1.1\/date/)
  end

  it 'has date accepted' do
    work.date_accepted = ['01/01/00']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/dateAccepted/)
  end

  it 'has date available' do
    work.date_available = ['01/02/00']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/available/)
  end

  it 'has date copyrighted' do
    work.date_copyrighted = ['01/03/00']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/dateCopyrighted/)
  end

  it 'has date issued' do
    work.date_issued = ['01/04/00']
    expect(work.resource.dump(:ttl))
      .to match(/ebu\.ch\/metadata\/ontologies\/ebucore\/ebucore#dateIssued/)
  end

  it 'has a resource type' do
    work.resource_type = ['Collection']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/type/)
  end

  it 'has a bilographic citation' do
    work.bibliographic_citation = ['Collection']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/bibliographicCitation/)
  end

  it 'has rights_holder' do
    work.rights_holder = ['Someone']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/rightsHolder/)
  end

  it 'has format label' do
    work.format_label = ['a format label']
    expect(work.resource.dump(:ttl))
      .to match(/loc\.gov\/premis\/rdf\/v1#hasFormatName/)
  end

  it 'has replaces' do
    work.replaces = ['a replacement']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/replaces/)
  end

  it 'has "is replaced by"' do
    work.is_replaced_by = ['Something that is replaced by']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/isReplacedBy/)
  end

  it 'has "has part"' do
    work.has_part = ['a part']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/hasPart/)
  end

  it 'has extent' do
    work.extent = ['12x12']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/extent/)
  end

  it 'has personal name' do
    work.personal_name = ['Someone']
    expect(work.resource.dump(:ttl))
      .to match(/loc\.gov\/mads\/rdf\/v1#PersonalName/)
  end

  it 'has corporate name' do
    work.corporate_name = ['Something']
    expect(work.resource.dump(:ttl))
      .to match(/loc\.gov\/mads\/rdf\/v1#CorporateName/)
  end

  it 'has genre' do
    work.genre = ['a genre']
    expect(work.resource.dump(:ttl))
      .to match(/loc\.gov\/mads\/rdf\/v1#GenreForm/)
  end

  it 'has provenance' do
    work.provenance = ['Someone']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/provenance/)
  end

  it 'has temporal' do
    work.temporal = ['20th century']
    expect(work.resource.dump(:ttl))
      .to match(/purl\.org\/dc\/terms\/temporal/)
  end

  it 'has dissertation type' do
    work.dissertation_type = 'undergraduate'
    expect(work.resource.dump(:ttl))
      .to match(/id\.loc\.gov\/ontologies\/bibframe/)
  end

  it 'has funder' do
    work.funder = ['Viewers Like You']
    expect(work.resource.dump(:ttl))
      .to match(/id\.loc\.gov\/vocabulary\/relators/)
  end
end
