class BookPolicy < ApplicationPolicy
  # All users can view books
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  # Only librarians can manage books
  def create?
    user&.librarian?
  end

  def new?
    create?
  end

  def update?
    user&.librarian?
  end

  def edit?
    update?
  end

  def destroy?
    user&.librarian?
  end

  class Scope < Scope
    def resolve
      if user&.librarian?
        scope.all
      else
        # Members can see all books but can't manage them
        scope.all
      end
    end
  end
end
