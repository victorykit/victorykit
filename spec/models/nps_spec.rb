describe Metrics::Nps do
  def create_petition(*args)
    params  = args.last.is_a?(Hash) ? args.pop : {}
    actions = args.flatten
    created_at = params[:created_at] || Time.now

    create(:petition, params.merge(to_send: true)).tap do |petition|
      actions.each { |action| self.send "create_#{action}", petition, created_at }
    end
  end

  def create_subscribe(petition, created_at=Time.now)
    create :signature, created_member: true, petition: petition, created_at: created_at
  end

  def create_unsubscribe(petition, created_at=Time.now)
    email = ScheduledEmail.where(petition_id: petition.id).last or raise "No email found"
    create :unsubscribe, sent_email: email, cause: "unsubscribed", created_at: created_at
  end

  def create_email(petition, created_at=Time.now)
    create :scheduled_email, petition: petition, created_at: created_at
  end

  context 'email_by_petition' do

    context 'with a single petition' do
      subject { Metrics::Nps.email_by_petition(petition.id) }

      context 'and a signature' do
        let(:petition) { create_petition :email, :subscribe }
        specify { expect(subject.nps).to eq(1.0) }
      end

      context 'and a signature, and an unsubscribe' do
        let(:petition) { create_petition :email, :subscribe, :unsubscribe }
        specify { expect(subject.nps).to eq(0.0) }
      end

      context 'and multiple signatures and unsubscribes' do
        let(:petition) {
          create_petition :email, :email, :email, :email, :subscribe, :subscribe, :unsubscribe
        }
        specify { expect(subject.nps).to eq(0.25) }
      end
    end


    context 'with multiple petitions' do
      let(:first)  { create_petition :email, :subscribe }
      let(:second) { create_petition :email, :subscribe, :unsubscribe }
      let(:third)  { create_petition :email, :email, :email, :email, :subscribe, :subscribe, :unsubscribe }

      subject { Metrics::Nps.email_by_petition([ first, second, third ].map(&:id)) }

      specify {
        expect(subject[0].nps).to eq(1.0)
        expect(subject[1].nps).to eq(0.0)
        expect(subject[2].nps).to eq(0.25)
      }
    end
  end

  context 'email_by_timeframe' do
    let(:relevant)  { create_petition :email, :email, :subscribe, created_at: 1.week.ago }
    let(:ignored)   { create_petition :email, :subscribe,         created_at: 1.month.ago }
    before { relevant; ignored }
    subject { Metrics::Nps.email_by_timeframe(timeframe, sent_threshold: 0) }

    context 'with a short timeframe' do
      let(:timeframe) { 8.days.ago }
      specify {
        expect(subject.length).to eq(1)
        expect(subject[0].nps).to eq(0.5)
      }
    end

    context 'with a long timeframe' do
      let(:timeframe) { 2.months.ago }
      specify {
        expect(subject.length).to eq(2)
        expect(subject.map(&:nps)).to match_array([1.0, 0.5])
      }
    end
  end

  context 'email_aggregate' do
    let(:oldish) { create_petition :email, :email, :subscribe, :unsubscribe, created_at: 1.month.ago }
    let(:newish) { create_petition :email, :email, :subscribe, :subscribe,   created_at: 1.week.ago }
    let(:newest) { create_petition :email, :email, :subscribe,               created_at: 1.day.ago }
    before { oldish; newish; newest }
    subject { Metrics::Nps.email_aggregate(1.month.ago - 1.second) }
    specify { expect(subject.nps).to eq(0.5) }
  end
end
