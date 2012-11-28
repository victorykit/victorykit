describe Petition do
  subject(:petition) { build :petition }
 
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :owner_id }
  it { should allow_mass_assignment_of(:location).as(:admin) }
  
  its(:title) { should_not start_or_end_with_whitespace }
  its(:experiments) { should_not be_nil }

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

    context 'newyorkers ans californians' do
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

      ScheduledEmail.stub_chain(:where, :select).
        and_return [stub(petition_id: sent.id)]

      Signature.stub_chain(:where, :select).
        and_return [stub(petition_id: signed.id)]
      
      subject.stub(:emailable_petition_ids).
        and_return [sent, signed, nocoverage, interesting].map(&:id)

      subject.stub_chain(:select, :where).
        and_return [nocoverage, interesting]
    end

    specify { subject.find_interesting_petitions_for(member).should == [interesting] }
  end

end
