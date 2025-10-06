class Api::V1::BooksController < Api::BaseController
  before_action :set_book, only: [:show, :update, :destroy]
  before_action :authorize_book, only: [:show, :update, :destroy]
  
  # GET /api/v1/books
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
    
    # Filter by author
    if params[:author].present?
      @books = @books.by_author(params[:author])
    end
    
    # Order first
    @books = @books.order(:title)
    
    # Filter by availability (after ordering, before pagination)
    if params[:available] == 'true'
      @books = @books.select { |book| book.available? }
    end
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 10
    per_page = [per_page, 100].min # Limit max per_page to 100
    
    total_count = @books.is_a?(Array) ? @books.length : @books.count
    
    if @books.is_a?(Array)
      # Manual pagination for arrays
      start_index = (page - 1) * per_page
      @books = @books[start_index, per_page] || []
    else
      @books = @books.offset((page - 1) * per_page).limit(per_page)
    end
    
    render_success({
      books: @books.map { |book| book_serializer(book) },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    })
  end
  
  # GET /api/v1/books/:id
  def show
    render_success(book_serializer(@book))
  end
  
  # POST /api/v1/books
  def create
    authorize Book
    @book = Book.new(book_params)
    
    if @book.save
      render_success(book_serializer(@book), 'Book created successfully', :created)
    else
      render_error('Failed to create book', :unprocessable_entity, @book.errors.full_messages)
    end
  end
  
  # PATCH/PUT /api/v1/books/:id
  def update
    if @book.update(book_params)
      render_success(book_serializer(@book), 'Book updated successfully')
    else
      render_error('Failed to update book', :unprocessable_entity, @book.errors.full_messages)
    end
  end
  
  # DELETE /api/v1/books/:id
  def destroy
    if @book.destroy
      render_success({}, 'Book deleted successfully')
    else
      render_error('Failed to delete book', :unprocessable_entity, @book.errors.full_messages)
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
  
  def book_serializer(book)
    {
      id: book.id,
      title: book.title,
      author: book.author,
      genre: book.genre,
      isbn: book.isbn,
      total_copies: book.total_copies,
      available_copies: book.available_copies,
      borrowed_copies: book.borrowed_copies,
      availability_status: book.availability_status,
      available: book.available?,
      created_at: book.created_at,
      updated_at: book.updated_at
    }
  end
end
