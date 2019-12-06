FactoryBot.define do
  factory :invoice_user do
    invoice
    bill_user
    user { bill_user.user }
    amount { invoice.amount }
    expires_at { invoice.expires_at }
    status { :available}
  end
end
