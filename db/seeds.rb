# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

3.times do |i|
  user = User.create(account_name: "user#{i + 1}", display_name: "user#{i + 1}",
                     birthday: '2000-01-01', email: "user#{i + 1}@example.com", password: 'password')

  tweet_data = 50.times.map do |j|
    {
      user_id: user.id,
      content: "Hello, world! #{j}",
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  Tweet.insert_all(tweet_data)
end
