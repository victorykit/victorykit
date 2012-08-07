require 'spec_helper'
require 'member_hasher'

describe MemberHasher do
  
  it_behaves_like 'a hasher'

  describe '#member_for' do
    let(:peter_griffin) { mock }
    
    before do 
      Member.stub!(:where).with(:id => 42).and_return [peter_griffin]
      Member.stub!(:where).with(:id => 43).and_return []
    end

    context 'invalid hash' do
      specify { MemberHasher.member_for('o_O').should be_nil }
    end

    context 'absent hashed id' do
      specify { MemberHasher.member_for('43.HiH9s0').should be_nil }
    end

    context 'existing hased id' do
      specify { MemberHasher.member_for('42.aCKy3f').should be peter_griffin }
    end
    
  end
end
