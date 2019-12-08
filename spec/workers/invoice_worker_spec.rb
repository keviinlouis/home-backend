require 'rails_helper'

RSpec.describe InvoiceWorker do
  before(:each) do
    @worker = InvoiceWorker.new
  end
  describe 'perform' do
    it 'should create a new invoice' do
      bill = create(:bill)
      expect(Invoice.count).to eq 1
      invoice = @worker.perform bill_id: bill.id
      expect(Invoice.count).to eq 2
      expect(invoice.bill_id).to eq bill.id
    end

    it 'should not create a new invoice when bill does not exists' do
      expect(Invoice.count).to eq 0
      invoice = @worker.perform bill_id: 'wrong id'
      expect(Invoice.count).to eq 0
      expect(invoice).to be_nil
    end
  end
end
