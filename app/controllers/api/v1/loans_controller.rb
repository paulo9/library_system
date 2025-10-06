class Api::V1::LoansController < Api::BaseController
  before_action :set_loan, only: [:show, :update, :destroy]
  before_action :authorize_loan, only: [:show, :update, :destroy]
  
  # GET /api/v1/loans
  def index
    @loans = policy_scope(Loan).includes(:book, :user)
    
    # Filter by user (for members, only show their own loans)
    if current_user.member?
      @loans = @loans.where(user: current_user)
    elsif params[:user_id].present?
      @loans = @loans.where(user_id: params[:user_id])
    end
    
    # Filter by book
    if params[:book_id].present?
      @loans = @loans.where(book_id: params[:book_id])
    end
    
    # Filter by status
    if params[:status].present?
      @loans = @loans.where(status: params[:status])
    end
    
    # Filter by overdue
    if params[:overdue] == 'true'
      @loans = @loans.overdue
    end
    
    # Filter by due today
    if params[:due_today] == 'true'
      @loans = @loans.due_today
    end
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 10
    per_page = [per_page, 100].min # Limit max per_page to 100
    
    @loans = @loans.order(created_at: :desc)
    total_count = @loans.count
    @loans = @loans.offset((page - 1) * per_page).limit(per_page)
    
    render_success({
      loans: @loans.map { |loan| loan_serializer(loan) },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    })
  end
  
  # GET /api/v1/loans/:id
  def show
    render_success(loan_serializer(@loan))
  end
  
  # POST /api/v1/loans
  def create
    authorize Loan
    
    # Find the book
    book = Book.find(params[:book_id])
    
    # Check if user can borrow the book
    unless current_user.can_borrow_book?(book)
      return render_error('You cannot borrow this book. It may not be available or you may have already borrowed it.', :unprocessable_entity)
    end
    
    @loan = Loan.new(
      user: current_user,
      book: book,
      borrowed_at: Time.current
    )
    
    if @loan.save
      render_success(loan_serializer(@loan), 'Book borrowed successfully', :created)
    else
      render_error('Failed to borrow book', :unprocessable_entity, @loan.errors.full_messages)
    end
  end
  
  # PATCH/PUT /api/v1/loans/:id
  def update
    # Only allow updating status to 'returned'
    if params[:loan] && params[:loan][:status] == 'returned'
      if @loan.borrowed?
        @loan.return_book!
        render_success(loan_serializer(@loan), 'Book returned successfully')
      else
        render_error('This book has already been returned', :unprocessable_entity)
      end
    else
      render_error('Only status updates are allowed', :unprocessable_entity)
    end
  end
  
  # DELETE /api/v1/loans/:id
  def destroy
    if @loan.destroy
      render_success({}, 'Loan record deleted successfully')
    else
      render_error('Failed to delete loan record', :unprocessable_entity, @loan.errors.full_messages)
    end
  end
  
  private
  
  def set_loan
    @loan = Loan.find(params[:id])
  end
  
  def authorize_loan
    authorize @loan
  end
  
  def loan_serializer(loan)
    {
      id: loan.id,
      user: {
        id: loan.user.id,
        name: loan.user.full_name,
        email: loan.user.email
      },
      book: {
        id: loan.book.id,
        title: loan.book.title,
        author: loan.book.author,
        isbn: loan.book.isbn
      },
      status: loan.status,
      borrowed_at: loan.borrowed_at,
      due_date: loan.due_date,
      returned_at: loan.returned_at,
      overdue: loan.overdue?,
      days_overdue: loan.days_overdue,
      days_until_due: loan.days_until_due,
      created_at: loan.created_at,
      updated_at: loan.updated_at
    }
  end
end
