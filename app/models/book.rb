class Book < ApplicationRecord
  has_many :loans, dependent: :destroy
  has_many :borrowers, through: :loans, source: :user

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
  scope :available, -> { where("total_copies > 0") }

  # Methods
  def available_copies
    borrowed_count = loans.borrowed.count
    [total_copies - borrowed_count, 0].max
  end

  def borrowed_copies
    loans.borrowed.count
  end

  def available?
    available_copies > 0
  end

  def borrowed_by?(user)
    loans.borrowed.exists?(user: user)
  end

  def current_loan_for(user)
    loans.borrowed.find_by(user: user)
  end

  def display_title
    "#{title} by #{author}"
  end

  def genre_list
    genre.split(',').map(&:strip)
  end

  def availability_status
    if available_copies > 0
      "#{available_copies} of #{total_copies} available"
    else
      "All copies borrowed"
    end
  end
end
