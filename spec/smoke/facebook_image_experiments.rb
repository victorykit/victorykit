require 'smoke_spec_helper'
require 'member_hasher'

describe 'petition facebook image in opengraph metadata' do
  it "should use the petition's image if available" do
    member = create_member
    image_path = "http://wow.com/image.png"
    petition = create_a_featured_petition({image: image_path })
    go_to petition_path(petition) + "?r=" + member.to_hash
    open_graph_image.should == image_path
  end

  it "should use a default image if no alternative specified" do
    member = create_member
    petition = create_a_featured_petition
    go_to petition_path(petition) + "?r=" + member.to_hash
    default_images = Rails.configuration.social_media[:facebook][:images]
    default_images.should include open_graph_image
  end
end

def open_graph_image
  element(css: 'meta[property="og:image"]').attribute('content')
end
