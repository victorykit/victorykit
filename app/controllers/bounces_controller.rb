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
        bounce_type = dsn["bounce"]["bounceType"]
        bounce_sub_type = dsn["bounce"]["bounceSubType"]
        email = dsn["bounce"]["bouncedRecipients"][0]["emailAddress"]

        unless bounce_type == "Transient"
          unsubscribe email, "#{notification_type}/#{bounce_type}/#{bounce_sub_type}"
        end
      elsif notification_type == "Complaint"
        record_dsn
        complaint_type = dsn["complaint"]["complaintFeedbackType"]
        email = dsn["complaint"]["complainedRecipients"][0]["emailAddress"]
        cause = "#{notification_type}"
        cause << "/#{complaint_type}" if complaint_type

        unless complaint_type == "not-spam"
          unsubscribe email, cause
        end
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
