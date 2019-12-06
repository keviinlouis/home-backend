FactoryBot.define do
  factory :invoice do
    bill
    amount { bill.amount }
    expires_at { bill.expires_at }
    number { bill.invoices.count }
    status { :available }
  end
end
