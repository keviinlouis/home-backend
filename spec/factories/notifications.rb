require 'faker'

FactoryBot.define do
  factory :notification do
    title { Faker::Artist.name }
    description { Faker::Quote.yoda }
    user
    resource { create(:bill, user: user) }
  end
end
