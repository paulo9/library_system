class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
end
