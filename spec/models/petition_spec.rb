describe Petition do
  subject(:petition) { build :petition }
 
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :owner_id }
  it { should allow_mass_assignment_of(:location).as(:admin) }
  
  its(:title) { should_not start_or_end_with_whitespace }
  its(:experiments) { should_not be_nil }

  context 'descriptions' do
    before { petition.description = descr } 

    context 'with html' do
      let(:descr) { 'I<br>haz&nbsp;&quot;stuff&quot;' }
      its(:plain_text_description) { should == "I\nhaz \"stuff\"" }
      its(:facebook_description_for_sharing){ should == 'Ihaz&nbsp;&quot;stuff&quot;' }
    end

    context 'with quotes' do
      let(:descr) { "'\"quotes" }
      its(:plain_text_description) { should == "'\"quotes" }
      its(:facebook_description_for_sharing) { should == '&apos;&quot;quotes' }
    end

    context 'with links' do
      let(:descr) { 'a <a href="http://w.com">link</a>' }
      its(:plain_text_description) { should == 'a link ( http://w.com )' }
      its(:facebook_description_for_sharing) { should == 'a link' }
    end

    describe '#description_lsub' do
      context '1' do
        let(:descr) { 'a<br><br>LINK<br><br>paragraph' } 
        specify { petition.description_lsub('subs').should == 'a<br><br>subs<br><br>paragraph' }
      end

      context '2' do
        let(:descr) { 'a<br><br>LINK<br><br>paragraph' } 
        specify { petition.description_lsub('').should == 'a<br><br>paragraph' }
      end

      context '3' do
        let(:descr) { '<p>a</p><p>LINK</p><p>paragraph</p>' } 
        specify { petition.description_lsub('subs').should == '<p>a</p><p>subs</p><p>paragraph</p>' } 
      end

      context '4' do
        let(:descr) { '<p>a</p><p>LINK</p><p>paragraph</p>' }
        specify { petition.description_lsub('').should == '<p>a</p><p>paragraph</p>' }
      end
    end
  end

  context 'parsing location back' do
    before { petition.location = location }

    context 'without details' do
      let(:location) { 'us' }
      its(:location_type) { should == 'us' }
      its(:location_details) { should == '' }
    end

    context 'with single detail' do
      let(:location) { 'us/CA' }
      its(:location_type) { should == 'us' }
      its(:location_details) { should == 'CA' }
    end

    context 'with multiple details' do
      let(:location) { 'us/CA,us/TX,us/NY' }
      its(:location_type) { should == 'us' }
      its(:location_details) { should == 'CA,TX,NY' }
    end

    context 'for no location' do
      let(:location) { nil }
      its(:location_type) { should == 'all' }
      its(:location_details) { should == '' }
    end
  end
  
  describe '.find_interesting_petitions_for' do
    subject { Petition }

    let(:member) { build :member }
    let(:p) { 3.times.map{ build :petition } }

    before do
      subject.stub(:find_all_by_to_send).with(true).and_return p
      [SentEmail, Signature].each_with_index do |c, i|
        c.stub(:find_all_by_member_id).with(member).and_return [stub(petition: p[i])]
      end
    end

    specify { subject.find_interesting_petitions_for(member).should == [p[2]] }
  end
end
