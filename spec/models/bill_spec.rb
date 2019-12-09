require 'rails_helper'

RSpec.describe Bill, type: :model do
  describe '#attribute_leftovers_to_owner' do
    before(:each) do
      @bill = create(:bill)
      @bill_user_owner = @bill.bill_users.first
      @owner_user = @bill.user
      @another_user = create(:user)
      users = [
        { id: @another_user.id, percent: 50.0 },
        { id: @owner_user.id, percent: 50.0 }
      ]
      @bill.update_users users
      @bill.active_all_users
    end

    it 'should add leftovers to owner in percent' do
      @bill.send(:update_user, id: @another_user.id, percent: 40)
      @bill.active_all_users
      @bill.attribute_leftovers_to_owner
      expect(@bill_user_owner.reload.percent).to eq 60
    end

    it 'should add leftovers to owner in percent' do
      @bill.send(:update_user, id: @another_user.id, percent: 40)
      @bill.send(:update_user, id: @owner_user.id, percent: 50)
      @bill.attribute_leftovers_to_owner(in_next_percent: true)
      expect(@bill_user_owner.reload.next_percent).to eq 60
    end
  end
end
