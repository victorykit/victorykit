require 'spec_helper'

describe PetitionsHelper do
  describe "petition_to_open_graph" do 
    include ApplicationHelper

    let(:petition) { create(:petition)}
    let(:config) { { facebook: { site_name: "My Super Petitions", app_id: 12345 } } }
    
    before(:each) do
      helper.stub!(:spin!).and_return(nil)
      helper.stub!(:social_media_config).and_return config
    end    

    subject { helper.petition_to_open_graph(petition) }
    
    it { should include("og:type" => "watchdognet:petition")}
    it { should include("og:title" => petition.title)}
    it { should include("og:description" => strip_tags(petition.description))}
    it { should include("og:image" => Rails.configuration.social_media[:facebook][:image])}
    it { should include("og:site_name" => "My Super Petitions")}
    it { should include("fb:app_id" => 12345)}
  end

  describe "choose_form_based_on_browser" do
    attr_reader :browser

    it "tells IE users to upgrade their shit" do
      @browser = OpenStruct.new(:ie? => true, :user_agent => "MSIE")
      choose_form_based_on_browser.should == 'ie_form'
    end

    it "tolerates IE with chrome frame" do
      @browser = OpenStruct.new(:ie? => true, :user_agent => "MSIE chromeframe")
      choose_form_based_on_browser.should == 'form'
    end
  end

  describe 'facebook sharing' do
    let(:browser) { mock }
    before { helper.stub!(:browser).and_return browser }
    
    context 'for an ie7 user' do
      before { browser.stub!(:ie7?).and_return true }
      
      it 'should be popup' do
        helper.facebook_sharing_option.should == 'facebook_popup'
      end
    end

    context 'for a proper browser user' do
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

  describe 'after share view' do
    let(:browser) { mock }
    
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

end
