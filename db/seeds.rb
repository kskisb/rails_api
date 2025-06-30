10.times do |i|
  user = User.create!(
    name: "user#{i + 1}",
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )

  5.times do |j|
    user.posts.create!(
      content: "This is post #{j + 1} from #{user.name}."
    )
  end
end
