class BouncesController < ApplicationController

  def create
    data = JSON.parse(request.raw_post)

    notification_type = data["notificationType"]
    if notification_type == "Bounce"
      bounce_type = data["bounce"]["bounceType"]
      bounce_sub_type = data["bounce"]["bounceSubType"]
      email = data["bounce"]["bouncedRecipients"][0]["emailAddress"]

      unsubscribe email, "#{notification_type}/#{bounce_type}/#{bounce_sub_type}"
    elsif notification_type == "Complaint"
      complaint_type = data["complaint"]["complaintFeedbackType"]
      email = data["complaint"]["complainedRecipients"][0]["emailAddress"]
      cause = "#{notification_type}"
      cause << "/#{complaint_type}" if complaint_type

      unsubscribe email, cause
    end

    if data["Type"] == "SubscriptionConfirmation"
      AWS::SNS::Client.new.confirm_subscription(:topic_arn => data["TopicArn"], :token => data["Token"], :authenticate_on_unsubscribe => "true")
    end

    render({:nothing => true})
  end


  private
  def record_bounced_data
    bounce = BouncedEmail.new
    bounce.raw_content = request.raw_post
    bounce.save!
  end

  def unsubscribe email, cause
    record_bounced_data
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
