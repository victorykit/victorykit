describe Paypal do
  describe '.verify_payment' do
    before do
      Paypal.stub(:send_post).and_return(result)
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
