class LoanPolicy < ApplicationPolicy
  # Members can view their own loans, librarians can view all loans
  def index?
    user.present?
  end

  def show?
    user.present? && (user.librarian? || record.user == user)
  end

  # Only members can borrow books
  def create?
    user&.member?
  end

  def new?
    create?
  end

  # Only librarians can mark books as returned
  def update?
    user&.librarian?
  end

  def edit?
    update?
  end

  # Only librarians can delete loan records
  def destroy?
    user&.librarian?
  end

  # Custom actions
  def borrow?
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
