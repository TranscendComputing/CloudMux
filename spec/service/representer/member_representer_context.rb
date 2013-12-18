shared_context "with a member" do
  let(:account_1) { FactoryGirl.build(:account, :login=>"standard_subscriber_1", :email=>"standard_1@example.com") }
  let(:member) { FactoryGirl.build(:member, :account=>account_1) }
end
