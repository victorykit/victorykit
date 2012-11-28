describe BouncesController do
  describe "create" do
    def unsubscribes_the_recipient_because_of cause
      member = create :member, :email => "username@example.com"
      request.env["RAW_POST_DATA"] = data
      post :create
      Unsubscribe.last.email.should == "username@example.com"
      Unsubscribe.last.cause.should == cause
      Unsubscribe.last.member.should == member
    end

    shared_examples_for "misformated notification handler" do
      it "should not try to unsubscribe a non-existent member" do
        request.env["RAW_POST_DATA"] = data
        post :create
        Unsubscribe.last.should be_nil
      end

      it "should record the bounced email data" do
        request.env["RAW_POST_DATA"] = data
        post :create
        BouncedEmail.last.raw_content.should == data
      end
    end

    context "when confirmation request is received" do
      let(:data) {
<<json
{
  "Type" : "SubscriptionConfirmation",
  "MessageId" : "165545c9-2a5c-472c-8df2-7ff2be2b3b1b",
  "Token" : "2336412f37fb687f5d51e6e241d09c805a5a57b30d712f794cc5f6a988666d92768dd60a747ba6f3beb71854e285d6ad02428b09ceece29417f1f02d609c582afbacc99c583a916b9981dd2728f4ae6fdb82efd087cc3b7849e05798d2d2785c03b0879594eeac82c01f235d0e717736",
  "TopicArn" : "arn:aws:sns:us-east-1:123456789012:MyTopic",
  "Message" : "You have chosen to subscribe to the topic arn:aws:sns:us-east-1:123456789012:MyTopic.To confirm the subscription, visit the SubscribeURL included in this message.",
  "SubscribeURL":"https://sns.us-east-1.amazonaws.com/?Action=ConfirmSubscription&TopicArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic&Token=2fdsc",
  "Timestamp" : "2012-04-26T20:45:04.751Z",
  "SignatureVersion" : "1",
  "Signature" : "skvXQIEpH+DcEwjAPg8O9mY8dReBSwksfg2S7WKQcikcNKWLQjwu6A4VbeS0QHVCkhRS7fUQvi2egU3N858fiTDN6bkkOxYDVrY0Ad8L10Hs3zH81mtnPk5uvvolIC1CXGu43obcgFxeL3khZl8IKvO61GWB6jI9b5+gLPoBc1Q=",
  "SigningCertURL" : "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem"
}
json
      }

      it "should hit the subscribe url from json" do
        AWS::SNS::Client.any_instance.should_receive(:confirm_subscription).with(any_args())
        request.env["RAW_POST_DATA"] = data
        post :create
      end
    end

    context "when a permanent bounce is received" do
      let(:data) {
<<json
{\n  \"Type\" : \"Notification\",
\n  \"MessageId\" : \"2af9f02d-dd41-4874-96fc-f6deeff281d1\",
\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:479537524374:ses-bounces-topic\",
\n  \"Message\" : \"{\\\"notificationType\\\":\\\"Bounce\\\",\\\"bounce\\\":{\\\"bounceType\\\":\\\"Permanent\\\",\\\"reportingMTA\\\":\\\"dns; a194-82.smtp-out.amazonses.com\\\",\\\"bouncedRecipients\\\":[{\\\"emailAddress\\\":\\\"username@example.com\\\",\\\"status\\\":\\\"5.0.0\\\",\\\"action\\\":\\\"failed\\\",\\\"diagnosticCode\\\":\\\"smtp; 5.1.0 - Unknown address error 550-\\\\\\\"5.1.1 The email account that you tried to reach does not exist. Please try\\\\\\\\n5.1.1 double-checking the recipient's email address for typos or\\\\\\\\n5.1.1 unnecessary spaces. Learn more at\\\\\\\\n5.1.1 http://support.google.com/mail/bin/answer.py?answer=6596 s13si8621225qct.81\\\\\\\" (delivery attempts: 0)\\\"}],\\\"bounceSubType\\\":\\\"General\\\",\\\"timestamp\\\":\\\"2012-07-18T14:26:21.000Z\\\",\\\"feedbackId\\\":\\\"000001389a7c40ca-a7f1fba9-d0e4-11e1-b74d-0d11d9f219b5-000000\\\"},\\\"mail\\\":{\\\"timestamp\\\":\\\"2012-07-18T14:27:07.000Z\\\",\\\"source\\\":\\\"\\\\\\\"Watchdog.net\\\\\\\" <info@watchdog.net>\\\",\\\"messageId\\\":\\\"000001389a7c34ee-64c16414-0497-4a68-8595-48a0dacaae30-000000\\\",\\\"destination\\\":[\\\"shell.muchael@gmail.com\\\"]}}\",
\n  \"Timestamp\" : \"2012-07-18T14:27:10.818Z\",
\n  \"SignatureVersion\" : \"1\",
\n  \"Signature\" : \"dEJYbH0lwhtWuGbnc1oiDXoiD8EL0tHEbrG2SMLUP8WZMNE43epYZqEDkDdNJCgosM5I82OFDlt3eLpI+dxamY0L/9m1UQkwuDBCCampB4ikmFCMieFaEgUagEyaebeq41vU7kBVOogkTjQVvRuVcOYVhTz3IO72oFAaxMcOqOg=\",
\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",
\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic:3c4cbe74-5962-40f8-b753-16555a72e787\"
\n}
json
      }

      it "should unsubscribe the recipient" do
        unsubscribes_the_recipient_because_of "Bounce/Permanent/General"
      end

      it_behaves_like "misformated notification handler"
    end

    context "when a transient bounce is received" do
      let(:data) {
<<json
{\n  \"Type\" : \"Notification\",
\n  \"MessageId\" : \"2af9f02d-dd41-4874-96fc-f6deeff281d1\",
\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:479537524374:ses-bounces-topic\",
\n  \"Message\" : \"{\\\"notificationType\\\":\\\"Bounce\\\",\\\"bounce\\\":{\\\"bounceType\\\":\\\"Transient\\\",\\\"reportingMTA\\\":\\\"dns; a194-82.smtp-out.amazonses.com\\\",\\\"bouncedRecipients\\\":[{\\\"emailAddress\\\":\\\"username@example.com\\\",\\\"status\\\":\\\"5.0.0\\\",\\\"action\\\":\\\"failed\\\",\\\"diagnosticCode\\\":\\\"smtp; 5.1.0 - Unknown address error 550-\\\\\\\"5.1.1 The email account that you tried to reach does not exist. Please try\\\\\\\\n5.1.1 double-checking the recipient's email address for typos or\\\\\\\\n5.1.1 unnecessary spaces. Learn more at\\\\\\\\n5.1.1 http://support.google.com/mail/bin/answer.py?answer=6596 s13si8621225qct.81\\\\\\\" (delivery attempts: 0)\\\"}],\\\"bounceSubType\\\":\\\"General\\\",\\\"timestamp\\\":\\\"2012-07-18T14:26:21.000Z\\\",\\\"feedbackId\\\":\\\"000001389a7c40ca-a7f1fba9-d0e4-11e1-b74d-0d11d9f219b5-000000\\\"},\\\"mail\\\":{\\\"timestamp\\\":\\\"2012-07-18T14:27:07.000Z\\\",\\\"source\\\":\\\"\\\\\\\"Watchdog.net\\\\\\\" <info@watchdog.net>\\\",\\\"messageId\\\":\\\"000001389a7c34ee-64c16414-0497-4a68-8595-48a0dacaae30-000000\\\",\\\"destination\\\":[\\\"shell.muchael@gmail.com\\\"]}}\",
\n  \"Timestamp\" : \"2012-07-18T14:27:10.818Z\",
\n  \"SignatureVersion\" : \"1\",
\n  \"Signature\" : \"dEJYbH0lwhtWuGbnc1oiDXoiD8EL0tHEbrG2SMLUP8WZMNE43epYZqEDkDdNJCgosM5I82OFDlt3eLpI+dxamY0L/9m1UQkwuDBCCampB4ikmFCMieFaEgUagEyaebeq41vU7kBVOogkTjQVvRuVcOYVhTz3IO72oFAaxMcOqOg=\",
\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",
\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic:3c4cbe74-5962-40f8-b753-16555a72e787\"
\n}
json
      }
      before do
        create :member, :email => "username@example.com"
      end

      it_behaves_like "misformated notification handler"
    end

    context "no recipients in the bounce message" do
      before do
        Rails.logger.should_not_receive(:error)
      end

      let(:data) {
<<json
{\n  \"Type\" : \"Notification\",
\n  \"MessageId\" : \"2af9f02d-dd41-4874-96fc-f6deeff281d1\",
\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:479537524374:ses-bounces-topic\",
\n  \"Message\" : \"{\\\"notificationType\\\":\\\"Bounce\\\",\\\"bounce\\\":{\\\"bounceType\\\":\\\"Undefined\\\",\\\"reportingMTA\\\":\\\"dns; a194-82.smtp-out.amazonses.com\\\",\\\"bouncedRecipients\\\":[],\\\"bounceSubType\\\":\\\"General\\\",\\\"timestamp\\\":\\\"2012-07-18T14:26:21.000Z\\\",\\\"feedbackId\\\":\\\"000001389a7c40ca-a7f1fba9-d0e4-11e1-b74d-0d11d9f219b5-000000\\\"},\\\"mail\\\":{\\\"timestamp\\\":\\\"2012-07-18T14:27:07.000Z\\\",\\\"source\\\":\\\"\\\\\\\"Watchdog.net\\\\\\\" <info@watchdog.net>\\\",\\\"messageId\\\":\\\"000001389a7c34ee-64c16414-0497-4a68-8595-48a0dacaae30-000000\\\",\\\"destination\\\":[\\\"shell.muchael@gmail.com\\\"]}}\",
\n  \"Timestamp\" : \"2012-07-18T14:27:10.818Z\",
\n  \"SignatureVersion\" : \"1\",
\n  \"Signature\" : \"dEJYbH0lwhtWuGbnc1oiDXoiD8EL0tHEbrG2SMLUP8WZMNE43epYZqEDkDdNJCgosM5I82OFDlt3eLpI+dxamY0L/9m1UQkwuDBCCampB4ikmFCMieFaEgUagEyaebeq41vU7kBVOogkTjQVvRuVcOYVhTz3IO72oFAaxMcOqOg=\",
\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",
\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic:3c4cbe74-5962-40f8-b753-16555a72e787\"
\n}
json
      }
      before do
        create :member, :email => "username@example.com"
      end

      it_behaves_like "misformated notification handler" 
    end

    context "when a complaint with feedback is received" do
      let(:data) {
<<json
{\n  \"Type\" : \"Notification\",
\n  \"MessageId\" : \"2af9f02d-dd41-4874-96fc-f6deeff281d1\",
\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:479537524374:ses-bounces-topic\",
\n  \"Message\" : \"{\\\"notificationType\\\":\\\"Complaint\\\",\\n  \\\"complaint\\\":{\\n     \\\"userAgent\\\":\\\"Comcast Feedback Loop (V0.01)\\\",\\n     \\\"complainedRecipients\\\":[\\n        {\\n           \\\"emailAddress\\\":\\\"username@example.com\\\"\\n        }\\n     ],\\n     \\\"complaintFeedbackType\\\":\\\"abuse\\\",\\n     \\\"arrivalDate\\\":\\\"2009-12-03T04:24:21.000-05:00\\\",\\n     \\\"timestamp\\\":\\\"2012-05-25T14:59:38.623-07:00\\\",\\n     \\\"feedbackId\\\":\\\"000001378603177f-18c07c78-fa81-4a58-9dd1-fedc3cb8f49a-000000\\\"\\n  },\\n  \\\"mail\\\":{\\n     \\\"timestamp\\\":\\\"2012-05-25T14:59:38.623-07:00\\\",\\n     \\\"messageId\\\":\\\"000001378603177f-7a5433e7-8edb-42ae-af10-f0181f34d6ee-000000\\\",\\n     \\\"source\\\":\\\"email_1337983178623@amazon.com\\\",\\n     \\\"destination\\\":[\\n        \\\"recipient1@example.com\\\",\\n        \\\"recipient2@example.com\\\",\\n        \\\"recipient3@example.com\\\",\\n        \\\"recipient4@example.com\\\"\\n     ]\\n  }\\n}\",
\n  \"Timestamp\" : \"2012-07-18T14:27:10.818Z\",
\n  \"SignatureVersion\" : \"1\",
\n  \"Signature\" : \"dEJYbH0lwhtWuGbnc1oiDXoiD8EL0tHEbrG2SMLUP8WZMNE43epYZqEDkDdNJCgosM5I82OFDlt3eLpI+dxamY0L/9m1UQkwuDBCCampB4ikmFCMieFaEgUagEyaebeq41vU7kBVOogkTjQVvRuVcOYVhTz3IO72oFAaxMcOqOg=\",
\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",
\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic:3c4cbe74-5962-40f8-b753-16555a72e787\"
\n}
json
      }

      it_behaves_like "misformated notification handler"

      it "should unsubscribe the recipient" do
        unsubscribes_the_recipient_because_of "Complaint/abuse"
      end
    end

    context "when a complaint with non-spam feedback is received" do
      let(:data) {
<<json
{\n  \"Type\" : \"Notification\",
\n  \"MessageId\" : \"2af9f02d-dd41-4874-96fc-f6deeff281d1\",
\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:479537524374:ses-bounces-topic\",
\n  \"Message\" : \"{\\\"notificationType\\\":\\\"Complaint\\\",\\n  \\\"complaint\\\":{\\n     \\\"userAgent\\\":\\\"Comcast Feedback Loop (V0.01)\\\",\\n     \\\"complainedRecipients\\\":[\\n        {\\n           \\\"emailAddress\\\":\\\"username@example.com\\\"\\n        }\\n     ],\\n     \\\"complaintFeedbackType\\\":\\\"not-spam\\\",\\n     \\\"arrivalDate\\\":\\\"2009-12-03T04:24:21.000-05:00\\\",\\n     \\\"timestamp\\\":\\\"2012-05-25T14:59:38.623-07:00\\\",\\n     \\\"feedbackId\\\":\\\"000001378603177f-18c07c78-fa81-4a58-9dd1-fedc3cb8f49a-000000\\\"\\n  },\\n  \\\"mail\\\":{\\n     \\\"timestamp\\\":\\\"2012-05-25T14:59:38.623-07:00\\\",\\n     \\\"messageId\\\":\\\"000001378603177f-7a5433e7-8edb-42ae-af10-f0181f34d6ee-000000\\\",\\n     \\\"source\\\":\\\"email_1337983178623@amazon.com\\\",\\n     \\\"destination\\\":[\\n        \\\"recipient1@example.com\\\",\\n        \\\"recipient2@example.com\\\",\\n        \\\"recipient3@example.com\\\",\\n        \\\"recipient4@example.com\\\"\\n     ]\\n  }\\n}\",
\n  \"Timestamp\" : \"2012-07-18T14:27:10.818Z\",
\n  \"SignatureVersion\" : \"1\",
\n  \"Signature\" : \"dEJYbH0lwhtWuGbnc1oiDXoiD8EL0tHEbrG2SMLUP8WZMNE43epYZqEDkDdNJCgosM5I82OFDlt3eLpI+dxamY0L/9m1UQkwuDBCCampB4ikmFCMieFaEgUagEyaebeq41vU7kBVOogkTjQVvRuVcOYVhTz3IO72oFAaxMcOqOg=\",
\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",
\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic:3c4cbe74-5962-40f8-b753-16555a72e787\"
\n}
json
      }

      before do
        create :member, :email => "username@example.com"
      end

      it_behaves_like "misformated notification handler"

    end

      context "when a complaint without feedback is received" do
        let(:data) {
<<json
{"Type" : "Notification",
 "MessageId" : "2af9f02d-dd41-4874-96fc-f6deeff281d1",
  "TopicArn" : "arn:aws:sns:us-east-1:479537524374:ses-bounces-topic",
  "Message" : \"{\\n  \\\"notificationType\\\":\\\"Complaint\\\",\\n  \\\"complaint\\\":{\\\"complainedRecipients\\\":[\\n        {\\n           \\\"emailAddress\\\":\\\"username@example.com\\\"\\n        }\\n     ],\\n     \\\"timestamp\\\":\\\"2012-05-25T14:59:38.613-07:00\\\",\\n     \\\"feedbackId\\\":\\\"0000013786031775-fea503bc-7497-49e1-881b-a0379bb037d3-000000\\\"\\n  },\\n  \\\"mail\\\":{\\n     \\\"timestamp\\\":\\\"2012-05-25T14:59:38.613-07:00\\\",\\n     \\\"messageId\\\":\\\"0000013786031775-163e3910-53eb-4c8e-a04a-f29debf88a84-000000\\\",\\n     \\\"source\\\":\\\"email_1337983178613@amazon.com\\\",\\n     \\\"destination\\\":[\\n        \\\"recipient1@example.com\\\",\\n        \\\"recipient2@example.com\\\",\\n        \\\"recipient3@example.com\\\",\\n        \\\"recipient4@example.com\\\"\\n     ]\\n  }\\n}\", "Timestamp" : "2012-07-18T14:27:10.818Z",
"SignatureVersion" : "1",
"Signature" : "dEJYbH0lwhtWuGbnc1oiDXoiD8EL0tHEbrG2SMLUP8WZMNE43epYZqEDkDdNJCgosM5I82OFDlt3eLpI+dxamY0L/9m1UQkwuDBCCampB4ikmFCMieFaEgUagEyaebeq41vU7kBVOogkTjQVvRuVcOYVhTz3IO72oFAaxMcOqOg=",
"SigningCertURL" : "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem",
"UnsubscribeURL" : "https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:479537524374:ses-bounces-topic:3c4cbe74-5962-40f8-b753-16555a72e787"
}
json
        }

        it "should unsubscribe the recipient" do
          unsubscribes_the_recipient_because_of "Complaint"
        end

        it_behaves_like "misformated notification handler"
      end
  end
end
