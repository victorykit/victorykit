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
          process_bounce dsn
        rescue => error
          Rails.logger.error "Exception while handling a bounce message: #{error}"
        end
      elsif notification_type == "Complaint"
        record_dsn
        begin
          process_complaint dsn
        rescue => error
          Rails.logger.error "Exception while handling a complaint message: #{error}"
        end
      end

  end

  def process_bounce bounce
    bounce_type = bounce["bounce"]["bounceType"]
    bounce_sub_type = bounce["bounce"]["bounceSubType"]
    email = bounce["bounce"]["bouncedRecipients"][0]["emailAddress"]
    unless bounce_type == "Transient"
      unsubscribe email, "Bounce/#{bounce_type}/#{bounce_sub_type}"
    end
  end

  def process_complaint complaint
    complaint_type = complaint["complaint"]["complaintFeedbackType"]
    email = complaint["complaint"]["complainedRecipients"][0]["emailAddress"]
    cause = "Complaint"
    cause << "/#{complaint_type}" if complaint_type

    unless complaint_type == "not-spam"
      unsubscribe email, cause
    end
  end

  def record_dsn
    bounce = BouncedEmail.new
    bounce.raw_content = request.raw_post
    bounce.save!
  end

  def unsubscribe email, cause
    member = Member.find_by_email email
    if member
      unsubscribe = Unsubscribe.new
      unsubscribe.cause = cause
      unsubscribe.email = member.email
      unsubscribe.member = member
      unsubscribe.save!
    end
  end

end
