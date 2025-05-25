FactoryBot.define do
  factory :user do
    Faker::Config.locale = :ja
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
