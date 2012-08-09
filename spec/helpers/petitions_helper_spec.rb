require 'spec_helper'

describe PetitionsHelper do
  let(:browser) { mock }
  before { helper.stub!(:browser).and_return browser }

  describe '#open_graph_for' do 
    let(:petition) { create(:petition) }
    let(:hash) { '42.aCKy3f' }
    let(:config) { 
      { facebook: { 
          site_name: 'My Super Petitions', 
          app_id: 12345 
        } 
      } 
    }
    
    before(:each) do
      helper.stub!(:spin!)
      helper.stub!(:social_media_config).and_return config
      MemberHasher.stub!(:member_for).with(hash).and_return anything
    end    

    subject { helper.open_graph_for(petition, hash) }
    it { should include('og:type' => 'watchdognet:petition') }
    it { should include('og:title' => petition.title) }
    it { should include('og:description' => strip_tags(petition.description)) }
    it { should include('og:image' => Rails.configuration.social_media[:facebook][:image]) }
    it { should include('og:site_name' => 'My Super Petitions') }
    it { should include('fb:app_id' => 12345) }
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

  describe '#facebook_sharing_option' do

    context 'for an ie7 user' do
      before { browser.stub!(:ie7?).and_return true }
      
      it 'should be popup' do
        helper.facebook_sharing_option.should == 'facebook_popup'
      end
    end

    context 'for a regular browser user' do
      let(:exp) { 'facebook sharing options' }
      let(:goal) { :referred_member }
      let(:options) { ['facebook_like', 'facebook_popup'] }
      before { browser.stub!(:ie7?).and_return false }

      it 'should spin for an option' do
        helper.should_receive(:spin!).with(exp, goal, options)
        helper.facebook_sharing_option
      end

      it 'should cache spin result' do
        helper.should_receive(:spin!).once.
        with(exp, goal, options).and_return anything
        2.times { helper.facebook_sharing_option }
      end
    end
  end

  describe '#after_share_view' do
    
    before do 
      helper.stub!(:browser).and_return browser
      [:mobile?, :android?, :ie?].each { |m| browser.stub! m }
    end

    shared_examples 'modal' do
      specify { helper.after_share_view.should == 'modal' }
    end

    context 'for a mobile user' do
      before { browser.stub!(:mobile?).and_return true }
      it_behaves_like 'modal'
    end

    context 'for an ie user' do
      before { browser.stub!(:ie?).and_return true }
      it_behaves_like 'modal'
    end

    context 'for an android user' do
      before { browser.stub!(:android?).and_return true }
      it_behaves_like 'modal'
    end

    context 'for a regular browser user' do
      let(:exp) { 'after share view' }
      let(:goal) { :share }
      let(:options) { ['modal', 'hero'] }

      it 'should spin for an option' do
        helper.should_receive(:spin!).with(exp, goal, options)
        helper.after_share_view
      end

      it 'should cache spin result' do
        helper.should_receive(:spin!).once.
        with(exp, goal, options).and_return anything
        2.times { helper.after_share_view }
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

  describe '#progress_option' do
    let(:exp) { 'test different messaging on progress bar' }
    let(:goal) { :signature }
    let(:options) { ['foo', 'bar'] }
    let(:config) { { 'foo' => {}, 'bar' => {} } }

    before { helper.stub!(:progress_options_config).and_return config }

    it 'should spin for an option' do
      helper.should_receive(:spin!).with(exp, goal, options)
      helper.progress_option
    end

    it 'should cache spin result' do
      helper.should_receive(:spin!).once.
      with(exp, goal, options).and_return anything
      2.times { helper.progress_option }
    end
  end

  describe '#progress' do
    let(:config) {{
      'foo' => { :class => 'highlight', :text => 'Sign it dude!' }, 
      'bar' => { :class => 'downfade', :text => 'Please, sign!' }
    }}

    before { helper.stub!(:progress_options_config).and_return config }
      
    context 'for successful spin' do
      before { helper.stub!(:progress_option).and_return 'bar' }
      specify { helper.progress[:class].should == 'downfade' }
      specify { helper.progress[:text].should == 'Please, sign!' }
    end

    context 'for failed spin' do
      before { helper.stub!(:progress_option).and_return false }
      specify { helper.progress[:class].should be_empty }
      specify { helper.progress[:text].should be_empty }
    end
  end

end
