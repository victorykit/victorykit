require Rails.root.join('db', 'migrate', '20121025143023_merge_members')

describe 'merging members by email ignoring case' do
  it 'keeps only the first created' do
    p1 = create(:petition)
    p2 = create(:petition)
    p3 = create(:petition)
    p4 = create(:petition)

    bob1 = create(:member, :email => 'Bob@gmail.com')
    bob2 = create(:member, :email => 'boB@gmail.com')
    bob3 = create(:member, :email => 'BOB@gmail.com')
    joe =  create(:member, :email => 'joe@gmail.com')

    create(:signature, :member => bob1, :petition => p1)
    create(:signature, :member => bob2, :petition => p1)
    create(:signature, :member => bob2, :petition => p2)
    create(:signature, :member => bob3, :petition => p3)
    create(:signature, :member => joe,  :petition => p1)
    create(:signature, :member => joe,  :petition => p4)

    MergeMembers.suppress_messages { MergeMembers.migrate(:up) }

    Member.find_by_email('Bob@gmail.com').tap do |bob|
      bob.should_not be_nil
      bob.signatures.should have(4).elements
      bob.signatures.where(:petition_id => p1.id).should have(2).elements
      bob.signatures.where(:petition_id => p2.id).should have(1).element
      bob.signatures.where(:petition_id => p3.id).should have(1).element
    end

    Member.find_by_email('boB@gmail.com').should be_nil
    Member.find_by_email('BOB@gmail.com').should be_nil
  end

end
