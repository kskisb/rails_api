FactoryBot.define do
  factory :message do
    body { "MyText" }
    read { false }
    conversation { nil }
    user { nil }
  end
end
