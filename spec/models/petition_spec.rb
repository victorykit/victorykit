describe Petition do
  subject(:petition) { build :petition }

  it { should have_many :referrals }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :owner_id }
  it { should allow_mass_assignment_of(:location).as(:admin) }

  its(:title) { should_not start_or_end_with_whitespace }
  its(:experiments) { should_not be_nil }

  describe 'not_deleted' do
    it 'returns petitions that have not been deleted' do
      petition1 = create(:petition, :deleted => false)
      petition2 = create(:petition, :deleted => nil)
      Petition.not_deleted.should include(petition1)
      Petition.not_deleted.should include(petition2)
      Petition.not_deleted.size.should == 2
    end

    it 'does not return deleted petitions' do
      petition = create(:petition, :deleted => true)
      Petition.not_deleted.should be_empty
    end
  end

  describe 'recently_featured' do
    it 'returns petitions that have have been recently featured' do
      petition1 = create(:petition, :to_send => true, :featured_on => 1.day.ago)
      petition2 = create(:petition, :to_send => true, :featured_on => 2.days.ago)
      Petition.recently_featured.should eq [petition1, petition2]
    end

    it 'does not return petitions that were not recently featured' do
      petition = create(:petition, :to_send => true, :featured_on => 10.days.ago)
      Petition.recently_featured.should be_empty
    end

    it 'does not return petitions if none were featured' do
      petition = create(:petition, :to_send => false)
      Petition.recently_featured.should be_empty
    end
  end

  describe '.emailable_petition_ids' do
    let!(:featured_petition) { create(:petition, to_send: true, deleted: false) }
    let!(:deleted_petition) { create(:petition, to_send: false, deleted: true) }
    let!(:deleted_featured_petition) { create(:petition, to_send: true, deleted: true) }
    subject { Petition.emailable_petition_ids }
    it { should == [featured_petition.id] }
  end

  describe '#image_urls' do
    let(:image) { build :petition_image, :url => 'www.img.com' }
    before { petition.petition_images << image }
    its(:image_urls) { should == ['www.img.com'] }
  end

  describe '#summary_texts' do
    let(:summary) { build :petition_summary, :short_summary => 'dinossaur' }
    before { petition.petition_summaries << summary }
    its(:summary_texts) { should == ['dinossaur'] }
  end

  context 'descriptions' do
    before { petition.description = descr }

    context 'with html' do
      let(:descr) { 'I<br>haz&nbsp;&quot;stuff&quot;' }
      its(:plain_text_description) { should == "I\nhaz \"stuff\"" }
      its(:default_description_for_sharing){ should == 'Ihaz&nbsp;&quot;stuff&quot;' }
    end

    context 'with quotes' do
      let(:descr) { "'\"quotes" }
      its(:plain_text_description) { should == "'\"quotes" }
      its(:default_description_for_sharing) { should == '&apos;&quot;quotes' }
    end

    context 'with links' do
      let(:descr) { 'a <a href="http://w.com">link</a>' }
      its(:plain_text_description) { should == 'a link ( http://w.com )' }
      its(:default_description_for_sharing) { should == 'a link' }
    end

    describe '#description_lsub' do
      context 'between br tags' do
        let(:descr) { 'a<br><br>LINK<br><br>paragraph' }
        specify do
          petition.description_lsub('subs').should=='a<br><br>subs<br><br>paragraph'
        end
        specify do
          petition.description_lsub('').should == 'a<br><br>paragraph'
        end
      end

      context 'inside p tag' do
        let(:descr) { '<p>a</p><p>LINK</p><p>paragraph</p>' }
        specify { petition.description_lsub('subs').should == '<p>a</p><p>subs</p><p>paragraph</p>' }
        specify { petition.description_lsub('').should == '<p>a</p><p>paragraph</p>' }
      end
    end
  end

  context 'localizing' do
    before { petition.location = location }

    let(:mexican) { stub(last_location: 'non-us/MX') }
    let(:canadian) { stub(last_location: 'non-us/CA') }
    let(:newyorker) { stub(last_location: 'us/NY') }
    let(:californian) { stub(last_location: 'us/CA') }
    let(:delocalized) { stub(last_location: '') }

    context 'everyone' do
      let(:location) { 'all' }
      its(:location_type) { should == 'all' }
      its(:location_details) { should == '' }

      it { should cover mexican }
      it { should cover canadian }
      it { should cover newyorker }
      it { should cover californian }
      it { should cover delocalized }
    end

    context 'americans' do
      let(:location) { 'us' }
      its(:location_type) { should == 'us' }
      its(:location_details) { should == '' }

      it { should cover newyorker }
      it { should cover californian }
      it { should_not cover mexican }
      it { should_not cover canadian }
      it { should_not cover delocalized }
   end

    context 'newyorkers' do
      let(:location) { 'us/NY' }
      its(:location_type) { should == 'us' }
      its(:location_details) { should == 'NY' }

      it { should cover newyorker }
      it { should_not cover californian }
      it { should_not cover mexican }
      it { should_not cover canadian }
      it { should_not cover delocalized }
    end

    context 'newyorkers and californians' do
      let(:location) { 'us/CA,us/NY' }
      its(:location_type) { should == 'us' }
      its(:location_details) { should == 'CA,NY' }

      it { should cover newyorker }
      it { should cover californian }
      it { should_not cover mexican }
      it { should_not cover canadian }
      it { should_not cover delocalized }
    end

    context 'not americans' do
      let(:location) { 'non-us' }
      its(:location_type) { should == 'non-us' }
      its(:location_details) { should == '' }

      it { should cover mexican }
      it { should cover canadian }
      it { should_not cover newyorker }
      it { should_not cover californian }
      it { should_not cover delocalized }
    end

    context 'canadians' do
      let(:location) { 'non-us/CA' }
      its(:location_type) { should == 'non-us' }
      its(:location_details) { should == 'CA' }

      it { should cover canadian }
      it { should_not cover mexican }
      it { should_not cover newyorker }
      it { should_not cover californian }
      it { should_not cover delocalized }
    end

    context 'mexicans and canadians' do
      let(:location) { 'non-us/CA,non-us/MX' }
      its(:location_type) { should == 'non-us' }
      its(:location_details) { should == 'CA,MX' }

      it { should cover mexican }
      it { should cover canadian }
      it { should_not cover newyorker }
      it { should_not cover californian }
      it { should_not cover delocalized }
    end
  end

  describe '.find_interesting_petitions_for' do
    subject { Petition }

    let(:sent) { build :petition, :id => 1 }
    let(:signed) { build :petition, :id => 2 }
    let(:nocoverage) { build :petition, :id => 3 }
    let(:interesting) { build :petition, :id => 4 }
    let(:member) { build :member }

    before do
      nocoverage.stub(:cover?).with(member).and_return false
      interesting.stub(:cover?).with(member).and_return true

      member.stub(:previous_petition_ids).and_return [sent.id, signed.id]

      subject.stub(:emailable_petition_ids).
        and_return [sent, signed, nocoverage, interesting].map(&:id)

      subject.stub_chain(:select, :where).
        and_return [nocoverage, interesting]
    end

    specify { subject.find_interesting_petitions_for(member).should == [interesting] }
  end

  describe 'sigcount' do
    context 'should show signature count' do
      let(:signature1) { create(:signature, petition: subject, email: "test@test.com") }
      let(:signature2) { create(:signature, petition: subject, email: "different@test.com") }

      before do
        subject.signatures.push signature1
        subject.signatures.push signature2
      end

      its(:sigcount) { should == 2 }
    end

    context 'should count signatures with unique email addresses only' do
      let(:signature1) { create(:signature, petition: subject, email: "test@test.com") }
      let(:signature2) { create(:signature, petition: subject, email: "test@test.com") }

      before do
        subject.signatures.push signature1
        subject.signatures.push signature2
      end

      its(:sigcount) { should == 1 }
    end
  end

end
