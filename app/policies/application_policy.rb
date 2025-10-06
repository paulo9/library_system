# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

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

  # Helper methods for role checking
  def librarian?
    user&.librarian?
  end

  def member?
    user&.member?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.librarian?
        scope.all
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end
end
