describe Paypal do
  describe '.verify_payment' do
    before do
      Net::HTTP::Post.stub(:new).and_return(Net::HTTPResponse.new('1.1', 200, ''))
      Net::HTTP.any_instance.stub(:request).and_return(stub(:body => result))
    end

    context 'success' do
      let(:result) { 'VERIFIED' }
      specify { Paypal.verify_payment({}).should be_true }
    end

    context 'failure' do
      let(:result) { 'FAILED' }
      specify { Paypal.verify_payment({}).should be_false }
    end

  end
end
