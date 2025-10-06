class Book < ApplicationRecord
  # Validations
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }
  validates :author, presence: true, length: { minimum: 1, maximum: 255 }
  validates :genre, presence: true, length: { minimum: 1, maximum: 100 }
  validates :isbn, presence: true, uniqueness: true, length: { is: 13 }
  validates :total_copies, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :by_author, ->(author) { where("author ILIKE ?", "%#{author}%") }
  scope :search, ->(query) { where("title ILIKE ? OR author ILIKE ?", "%#{query}%", "%#{query}%") }

  # Methods
  def available_copies
    # This will be implemented when we add book copies/loans
    total_copies
  end

  def display_title
    "#{title} by #{author}"
  end

  def genre_list
    genre.split(',').map(&:strip)
  end
end
