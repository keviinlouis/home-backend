require 'faker'

FactoryBot.define do
  factory :bill_event do
    kind { BillEvent.kinds.keys.sample }
    message { Faker::Quote.famous_last_words }
    user
    bill
  end
end
