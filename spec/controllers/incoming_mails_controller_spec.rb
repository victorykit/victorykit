require 'mail'

describe IncomingMailsController do

  describe "create" do
    it "should call MailReceiver.receive_unsubscribe_email if to field starts with 'unsubscribe'" do
      Mail::Message.any_instance.stub(:to_s => 'email_to_s')
      EmailProcessor.should_receive(:handle_exceptional_email).with('email_to_s', 'unsubscribe+hash@appmail.watchdog.net', 'unsubscribe')

      get :create, {:to => "unsubscribe+hash@appmail.watchdog.net", :message => "email"}
    end


    it "should return 404 if to field doesn`t start from none of above" do
      get :create, {:to => "somethingelse+hash@appmail.watchdog.net", :message => "email"}
      response.status.should == 404
    end

  end

end
