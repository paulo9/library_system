class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :book

  # Status enum: 0 = borrowed, 1 = returned
  enum status: { borrowed: 0, returned: 1 }

  # Validations
  validates :borrowed_at, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validate :due_date_after_borrowed_at
  validate :user_cannot_borrow_same_book_twice, on: :create

  # Scopes
  scope :active, -> { where(status: :borrowed) }
  scope :overdue, -> { where(status: :borrowed).where('due_date < ?', Time.current) }
  scope :due_today, -> { where(status: :borrowed).where(due_date: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :by_user, ->(user) { where(user: user) }

  # Callbacks
  before_validation :set_due_date, on: :create
  after_create :update_book_availability
  after_update :update_book_availability, if: :saved_change_to_status?

  # Methods
  def overdue?
    borrowed? && due_date < Time.current
  end

  def days_overdue
    return 0 unless overdue?
    (Time.current.to_date - due_date.to_date).to_i
  end

  def days_until_due
    return 0 unless borrowed?
    (due_date.to_date - Time.current.to_date).to_i
  end

  def return_book!
    update!(status: :returned, returned_at: Time.current)
  end

  private

  def set_due_date
    self.due_date = borrowed_at + 2.weeks if borrowed_at.present?
  end

  def due_date_after_borrowed_at
    return unless borrowed_at.present? && due_date.present?
    
    if due_date <= borrowed_at
      errors.add(:due_date, "must be after borrowed date")
    end
  end

  def user_cannot_borrow_same_book_twice
    return unless user.present? && book.present?
    
    existing_loan = Loan.where(user: user, book: book, status: :borrowed)
    if existing_loan.exists?
      errors.add(:book, "is already borrowed by this user")
    end
  end

  def update_book_availability
    # This will be used when we implement book copies
    # For now, we'll just track the loan status
  end
end
