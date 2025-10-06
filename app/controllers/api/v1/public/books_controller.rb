class Api::V1::Public::BooksController < Api::V1::Public::BaseController
  
  # GET /api/v1/public/books
  def index
    @books = Book.all
    
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
    
    # Filter by availability
    if params[:available] == 'true'
      @books = @books.select { |book| book.available? }
    end
    
    # Order first
    @books = @books.order(:title)
    
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
      books: @books.map { |book| public_book_serializer(book) },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    })
  end
  
  # GET /api/v1/public/books/:id
  def show
    @book = Book.find(params[:id])
    render_success(public_book_serializer(@book))
  end
  
  private
  
  def public_book_serializer(book)
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
