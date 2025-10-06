class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :loans, dependent: :destroy
  has_many :borrowed_books, through: :loans, source: :book

  # Role enum
  enum role: { member: 0, librarian: 1 }

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def librarian?
    role == 'librarian'
  end

  def member?
    role == 'member'
  end

  def current_loans
    loans.borrowed.includes(:book)
  end

  def overdue_loans
    loans.overdue.includes(:book)
  end

  def loans_due_today
    loans.due_today.includes(:book)
  end

  def can_borrow_book?(book)
    member? && book.available? && !book.borrowed_by?(self)
  end
end
