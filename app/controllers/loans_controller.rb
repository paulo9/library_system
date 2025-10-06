class LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan, only: [:show, :return_book]
  before_action :set_book, only: [:borrow_book]

  def index
    @loans = policy_scope(Loan).includes(:book, :user).order(created_at: :desc)
    
    if current_user.member?
      @loans = @loans.where(user: current_user)
    end
  end

  def show
    authorize @loan
  end

  def borrow_book
    authorize Loan
    
    if current_user.can_borrow_book?(@book)
      @loan = Loan.new(
        user: current_user,
        book: @book,
        borrowed_at: Time.current
      )
      
      if @loan.save
        redirect_to @book, notice: "Book borrowed successfully! Due date: #{@loan.due_date.strftime('%B %d, %Y')}"
      else
        redirect_to @book, alert: "Unable to borrow book: #{@loan.errors.full_messages.join(', ')}"
      end
    else
      redirect_to @book, alert: "You cannot borrow this book. It may not be available or you may have already borrowed it."
    end
  end

  def return_book
    authorize @loan
    
    if @loan.borrowed?
      @loan.return_book!
      redirect_to loans_path, notice: "Book returned successfully!"
    else
      redirect_to loans_path, alert: "This book has already been returned."
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def set_book
    @book = Book.find(params[:book_id])
  end
end
