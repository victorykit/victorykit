describe PetitionsHelper do
  let(:browser) { mock }
  before { helper.stub!(:browser).and_return browser }

  describe '#open_graph_for' do
    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:signer_code) { create(:referral, member: member, petition: petition) }
    let(:config) {{
      facebook: {
        site_name: 'My Super Petitions',
        app_id: 12345
      }
    }}

    before(:each) do
      helper.stub!(:spin!)
      helper.stub!(:social_media_config).and_return config
    end

    subject { helper.open_graph_for(petition, signer_code) }
    it { should include('og:type' => "#{helper.facebook_namespace}:petition") }
    it { should include('og:title' => petition.title) }
    it { should include('og:description' => strip_tags(petition.description)) }
    it "should have an image drawn from the list of possible Facebook images" do
      Rails.configuration.social_media[:facebook][:images].should include subject['og:image']
    end
    it { should include('og:site_name' => 'My Super Petitions') }
  end

  describe '#open_graph_for where alternate title exists' do
    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:signer_code) { create(:referral, member: member, petition: petition) }
    let(:alt_title) { create(:petition_title, petition: petition, title_type: PetitionTitle::TitleType::FACEBOOK)}

    context "member hash is valid" do
      subject { helper.open_graph_for(petition, signer_code) }
      it { should include('og:title' => alt_title.title)}
    end
  end

  describe '#choose_form_based_on_browser' do

    context 'for an ie user' do
      before do
        helper.browser.stub!(:ie?).and_return true
        helper.browser.stub!(:user_agent).and_return 'MSIE'
      end

      specify{ helper.choose_form_based_on_browser.should == 'ie_form' }
    end

    context 'for a regular browser user' do
      before do
        helper.browser.stub!(:ie?).and_return false
        helper.browser.stub!(:user_agent).and_return anything
      end

      specify{ helper.choose_form_based_on_browser.should == 'form' }
    end

    context 'for a fake ie user' do
      before do
        helper.browser.stub!(:ie?).and_return true
        helper.browser.stub!(:user_agent).and_return 'chromeframe'
      end

      specify{ helper.choose_form_based_on_browser.should == 'form' }
    end
  end

  describe '#facebook_button' do

    shared_examples 'facebook button hash' do
      before do
        helper.stub(:facebook_sharing_option).and_return option
      end

      subject { helper.facebook_button }

      it{ should include(button_class: button_class) }
      it{ should include(button_text: button_text) }
    end

    context 'when facebook sharing option is blank' do
      let(:option) { '' }
      let(:button_class) { 'fb_popup_btn' }
      let(:button_text) { 'Share on Facebook' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_share"' do
      let(:option) { 'facebook_share' }
      let(:button_class) { 'fb_share' }
      let(:button_text) { 'Share on Facebook' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_popup"' do
      let(:option) { 'facebook_popup' }
      let(:button_class) { 'fb_popup_btn' }
      let(:button_text) { 'Share on Facebook' }

      it_behaves_like 'facebook button hash'
    end

    context 'when facebook sharing option is "facebook_request"' do
      let(:option) { 'facebook_request' }
      let(:button_class) { 'fb_request_btn' }
      let(:button_text) { 'Send request to friends' }

      it_behaves_like 'facebook button hash'
    end

  end

  describe '#after_share_view' do

    context 'for a regular browser user on a petition with over 10k signatures' do
      let(:exp) { 'after share view 8' }
      let(:goal) { :share }
      let(:options) { [
        "button_is_most_effective_tool-progress_bar",
        "almost_finished_only_one_thing_left_to_do",
        "almost_there_only_one_thing_left_to_do-bottom_arrow",
        "almost_there_only_one_thing_left_to_do-85_bottom_arrow"
      ]
   }

      it 'should spin for an option' do
        helper.should_receive(:measure!).with(exp, goal, options)
        helper.after_share_view(10001)
      end
    end

    context 'for a regular browser user on a petition with under 10k signatures' do
      let(:exp) { 'after share view under 10k' }
      let(:goal) { :share }
      let(:options) { [
        "button_is_most_effective_tool-progress_bar",
        "almost_finished_only_one_thing_left_to_do",
        "almost_there_only_one_thing_left_to_do-bottom_arrow",
        "almost_there_only_one_thing_left_to_do-85_bottom_arrow",
        "can_you_help_us_reach_10k",
        "button_is_most_effective_to_10k",
        "button_is_going_to_get_us_to_10k"
     ]
   }

      it 'should spin for an option' do
        helper.should_receive(:measure!).with(exp, goal, options)
        helper.after_share_view(1001)
      end
    end

  end

  describe '#counter_size' do
    it 'should be greater than the number of signatures' do
      helper.counter_size(0).should == 5
      helper.counter_size(5).should == 10
      helper.counter_size(100000).should == 1000000
    end
  end

end
