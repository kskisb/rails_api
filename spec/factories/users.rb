FactoryBot.define do
  factory :user do
    Faker::Config.locale = :ja
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
  end
end
