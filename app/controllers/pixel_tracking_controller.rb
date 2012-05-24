require 'hasher'

class PixelTrackingController < ApplicationController

  def new
    if h = Hasher.validate(params[:n]) 
      begin
        email = SentEmail.find_by_id(h)
        email.update_attribute(:opened_at, Time.now) if not email.opened_at
      rescue => error
        Rails.logger.error "Exception while trying to mark a sent email as opened: #{error}"
      end
    end
    send_file Rails.root.join("public","tracking_pixel.gif"), type: 'image/gif', disposition: "inline" 
  end
end
