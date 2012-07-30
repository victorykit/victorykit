require 'smoke_spec_helper'

describe 'petition facebook image in opengraph metadata' do
  xit "should use the petition's image if available" do
    image_path = "imagepath"
    petition = create_a_featured_petition({image: image_path })
    go_to petition_path(petition)
    element(css: 'meta[property="og:image"]').attribute('content').should == image_path
  end

  it "should use the default image if no alternative specified" do
    default_image_path = Rails.configuration.social_media[:facebook][:image]
    petition = create_a_featured_petition
    go_to petition_path(petition)
    element(css: 'meta[property="og:image"]').attribute('content').should == default_image_path
  end
end