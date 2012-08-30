describe PetitionStatisticsTotals do
  let(:stats) { ['10', '20'] }
  subject { described_class.new stats }
  specify { subject.to_i.should eq 30 }
end