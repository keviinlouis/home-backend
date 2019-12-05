require 'faker'

FactoryBot.define do
  factory :bill do
    amount { Faker::Number.decimal(r_digits: 3) }
    name { Faker::Superhero.unique.name }
    description { Faker::Cannabis.brand }
    expires_at { Faker::Date.between(from: Date.today, to: Date.today + 5.years) }
    frequency { rand(30) }
    frequency_type { Bill.frequency_types.keys.sample }
    user

    factory :bill_without_frequency do
      frequency { nil }
      frequency_type { nil }
    end
  end
end
