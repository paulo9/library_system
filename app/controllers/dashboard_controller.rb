class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.librarian?
      librarian_dashboard
    else
      member_dashboard
    end
  end

  private

  def librarian_dashboard
    @total_books = Book.count
    @total_borrowed_books = Loan.borrowed.count
    @books_due_today = Loan.due_today.includes(:book, :user)
    @overdue_loans = Loan.overdue.includes(:book, :user)
    @members_with_overdue = User.joins(:loans).where(loans: { status: :borrowed, due_date: ...Time.current }).distinct
    
    # Recent activity
    @recent_loans = Loan.includes(:book, :user).order(created_at: :desc).limit(10)
    
    # Statistics
    @total_members = User.member.count
    @available_books = Book.all.count { |book| book.available? }
  end

  def member_dashboard
    @current_loans = current_user.current_loans.includes(:book)
    @overdue_loans = current_user.overdue_loans.includes(:book)
    @loans_due_today = current_user.loans_due_today.includes(:book)
    
    # Recent activity
    @recent_loans = current_user.loans.includes(:book).order(created_at: :desc).limit(5)
    
    # Statistics
    @total_borrowed = current_user.loans.count
    @currently_borrowed = current_user.current_loans.count
  end
end
