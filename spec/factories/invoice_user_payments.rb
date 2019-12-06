FactoryBot.define do
  factory :invoice_user_payment do
    invoice_user
    amount { invoice_user.amount }
  end
end
