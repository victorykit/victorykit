require 'spec_helper'

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

    shared_examples_for "bounce notification handler" do
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

    context "when a bounce is received" do
      let(:data) {
<<json
{
  "notificationType":"Bounce",
  "bounce":{
    "bounceType":"Permanent",
    "reportingMTA":"dns; email.example.com",
    "bouncedRecipients":[
      {
        "emailAddress":"username@example.com",
        "status":"5.1.1",
        "action":"failed",
        "diagnosticCode":"smtp; 550 5.1.1 <username@example.com>... User"
      }
    ],
      "bounceSubType":"General",
      "timestamp":"2012-06-19T01:07:52.000Z",
      "feedbackId":"00000138111222aa-33322211-cccc-cccc-cccc-ddddaaaa068a-000000"
  },
  "mail":{
    "timestamp":"2012-06-19T01:05:45.000Z",
    "source":"sender@example.com",
    "messageId":"00000138111222aa-33322211-cccc-cccc-cccc-ddddaaaa0680-000000",
    "destination":[
      "username@example.com"
    ]
  }
}
json
      }

      it "should unsubscribe the recipient" do
        unsubscribes_the_recipient_because_of "Bounce/Permanent/General"
      end

      it_behaves_like "bounce notification handler"
    end

    context "when a complaint with feedback is received" do
      let(:data) {
<<json
{
  "notificationType":"Complaint",
  "complaint":{
     "userAgent":"Comcast Feedback Loop (V0.01)",
     "complainedRecipients":[
        {
           "emailAddress":"username@example.com"
        }
     ],
     "complaintFeedbackType":"abuse",
     "arrivalDate":"2009-12-03T04:24:21.000-05:00",
     "timestamp":"2012-05-25T14:59:38.623-07:00",
     "feedbackId":"000001378603177f-18c07c78-fa81-4a58-9dd1-fedc3cb8f49a-000000"
  },
  "mail":{
     "timestamp":"2012-05-25T14:59:38.623-07:00",
     "messageId":"000001378603177f-7a5433e7-8edb-42ae-af10-f0181f34d6ee-000000",
     "source":"email_1337983178623@amazon.com",
     "destination":[
        "recipient1@example.com",
        "recipient2@example.com",
        "recipient3@example.com",
        "recipient4@example.com"
     ]
  }
}
json
      }

      it_behaves_like "bounce notification handler"

      it "should unsubscribe the recipient" do
        unsubscribes_the_recipient_because_of "Complaint/abuse"
      end

      context "when a complaint without feedback is received" do
        let(:data) {
<<json
{
  "notificationType":"Complaint",
  "complaint":{
     "complainedRecipients":[
        {
           "emailAddress":"username@example.com"
        }
     ],
     "timestamp":"2012-05-25T14:59:38.613-07:00",
     "feedbackId":"0000013786031775-fea503bc-7497-49e1-881b-a0379bb037d3-000000"
  },
  "mail":{
     "timestamp":"2012-05-25T14:59:38.613-07:00",
     "messageId":"0000013786031775-163e3910-53eb-4c8e-a04a-f29debf88a84-000000",
     "source":"email_1337983178613@amazon.com",
     "destination":[
        "recipient1@example.com",
        "recipient2@example.com",
        "recipient3@example.com",
        "recipient4@example.com"
     ]
  }
}
json
        }

        it "should unsubscribe the recipient" do
          unsubscribes_the_recipient_because_of "Complaint"
        end

        it_behaves_like "bounce notification handler"
      end
    end
  end
end
