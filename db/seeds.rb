5.times do |i|
  user = User.create!(
    name: "user#{i + 1}",
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )

  3.times do |j|
    user.posts.create!(
      content: "こんにちは、#{user.name} です。"
    )
  end
end
