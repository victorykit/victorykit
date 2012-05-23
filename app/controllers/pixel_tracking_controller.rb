require 'hasher'

class PixelTrackingController < ApplicationController

  def new
    if h = Hasher.validate(params[:n]) 
      begin
        SentEmail.update(h, :was_opened => true)
      rescue => error
        puts "Exception while trying to mark a sent email as opened: #{error}"
      end
    end
    send_file Rails.root.join("public","tracking_pixel.gif"), type: 'image/gif', disposition: "inline" 
  end
end
