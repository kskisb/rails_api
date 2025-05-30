class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :content, presence: true, length: { maximum: 280 }

  def likes_count
    likes.count
  end
end
