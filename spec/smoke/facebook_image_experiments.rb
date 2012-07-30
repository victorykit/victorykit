require 'smoke_spec_helper'
require 'member_hasher'
describe 'petition facebook image in opengraph metadata' do
  it "should use the petition's image if available" do
    member = create_member
    image_path = "http://wow.com/image.png"
    petition = create_a_featured_petition({image: image_path })
    go_to petition_path(petition) + "?r=" + MemberHasher.generate(member.id)
    element(css: 'meta[property="og:image"]').attribute('content').should == image_path
  end

  it "should use the default image if no alternative specified" do
    default_image_path = Rails.configuration.social_media[:facebook][:image]
    petition = create_a_featured_petition
    go_to petition_path(petition)
    element(css: 'meta[property="og:image"]').attribute('content').should == default_image_path
  end
end