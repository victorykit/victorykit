class PixelTrackingController < ApplicationController

  def show
    send_file Rails.root.join("public","tracking_pixel.gif"), type: 'image/gif', disposition: "inline" 
  end
end
