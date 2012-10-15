class BouncesController < ApplicationController

  def create
    notification = JSON.parse(request.raw_post)
    if notification["Type"] == "SubscriptionConfirmation"
      confirm_subscription notification
    else
      dsn = JSON.parse(notification["Message"])
      process_dsn dsn
    end
    render({:nothing => true})
  end


  private
  def confirm_subscription notification
    AWS::SNS::Client.new.confirm_subscription(:topic_arn => notification["TopicArn"], :token => notification["Token"], :authenticate_on_unsubscribe => "true")
  end

  def process_dsn dsn
      notification_type = dsn["notificationType"]
      if notification_type == "Bounce"
        record_dsn
        begin
          process_bounce dsn["bounce"]
        rescue => error
          notify_airbrake(error)
          Rails.logger.error "Exception while handling a bounce message: #{error}"
        end
      elsif notification_type == "Complaint"
        record_dsn
        begin
          process_complaint dsn["complaint"]
        rescue => error
          notify_airbrake(error)
          Rails.logger.error "Exception while handling a complaint message: #{error}"
        end
      end

  end

  def process_bounce bounce
    bounce_type = bounce["bounceType"]
    bounce_sub_type = bounce["bounceSubType"]
    unless bounce_type == "Transient" or bounce["bouncedRecipients"].nil?
      cause = "Bounce/#{bounce_type}/#{bounce_sub_type}"
      unsubscribe(bounce["bouncedRecipients"], cause)
    end
  end

  def process_complaint complaint
    complaint_type = complaint["complaintFeedbackType"]
    unless complaint_type == "not-spam" or complaint["complainedRecipients"].nil?
      cause = "Complaint"
      cause << "/#{complaint_type}" if complaint_type
      unsubscribe(complaint["complainedRecipients"], cause)
    end
  end

  def record_dsn
    bounce = BouncedEmail.new
    bounce.raw_content = request.raw_post
    bounce.save!
  end

  def unsubscribe(recipients, cause)
    recipients.each do |recipient|
      member = Member.find_by_email recipient["emailAddress"]
      if member
        unsubscribe = Unsubscribe.new
        unsubscribe.cause = cause
        unsubscribe.email = member.email
        unsubscribe.member = member
        unsubscribe.save!
      end
    end
  end

end
