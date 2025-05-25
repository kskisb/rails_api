10.times do
  user = FactoryBot.create(:user)

  5.times do
    FactoryBot.create(:post, user: user)
  end
end
