class LoanPolicy < ApplicationPolicy
  # Members can view their own loans, librarians can view all loans
  def index?
    user.present?
  end

  def show?
    user.present? && (user.librarian? || record.user == user)
  end

  # Both members and librarians can create loans
  def create?
    user&.member? || user&.librarian?
  end

  def new?
    create?
  end

  # Librarians can update any loan, members can update their own loans
  def update?
    user&.librarian? || (user&.member? && record.user == user)
  end

  def edit?
    update?
  end

  # Librarians can delete any loan record, members can delete their own loan records
  def destroy?
    user&.librarian? || (user&.member? && record.user == user)
  end

  # Custom actions
  def borrow_book?
    user&.member? && record.book.available? && !record.book.borrowed_by?(user)
  end

  def return_book?
    user&.librarian?
  end

  class Scope < Scope
    def resolve
      if user&.librarian?
        scope.all
      else
        # Members can only see their own loans
        scope.where(user: user)
      end
    end
  end
end
