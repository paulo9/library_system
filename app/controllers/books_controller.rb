class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [:show, :edit, :update, :destroy, :borrow_book]
  before_action :authorize_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = policy_scope(Book)
    
    # Search functionality
    if params[:search].present?
      @books = @books.search(params[:search])
    end
    
    # Filter by genre
    if params[:genre].present?
      @books = @books.by_genre(params[:genre])
    end
    
    # Get unique genres for filter dropdown
    @genres = Book.distinct.pluck(:genre).compact.sort
    
    # Pagination (you can add gem 'kaminari' or 'will_paginate' later)
    @books = @books.order(:title)
  end

  def show
  end

  def new
    authorize Book
    @book = Book.new
  end

  def create
    authorize Book
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: 'Book was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: 'Book was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: 'Book was successfully deleted.'
  end

  def borrow_book
    if current_user.can_borrow_book?(@book)
      @loan = Loan.new(
        user: current_user,
        book: @book,
        borrowed_at: Time.current
      )
      
      authorize @loan
      
      if @loan.save
        redirect_to @book, notice: "Book borrowed successfully! Due date: #{@loan.due_date.strftime('%B %d, %Y')}"
      else
        redirect_to @book, alert: "Unable to borrow book: #{@loan.errors.full_messages.join(', ')}"
      end
    else
      redirect_to @book, alert: "You cannot borrow this book. It may not be available or you may have already borrowed it."
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def authorize_book
    authorize @book
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
  end
end
