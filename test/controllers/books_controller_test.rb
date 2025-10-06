require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @book = books(:one)
    @librarian = users(:librarian)
    @member = users(:member)
  end

  test "should get index" do
    sign_in @member
    get books_url
    assert_response :success
  end

  test "should get new when librarian" do
    sign_in @librarian
    get new_book_url
    assert_response :success
  end

  test "should not get new when member" do
    sign_in @member
    get new_book_url
    assert_redirected_to root_path
  end

  test "should create book when librarian" do
    sign_in @librarian
    assert_difference('Book.count') do
      post books_url, params: { book: { title: "New Book", author: "New Author", genre: "Fiction", isbn: "1234567890123", total_copies: 1 } }
    end
    assert_redirected_to book_url(Book.last)
  end

  test "should not create book when member" do
    sign_in @member
    assert_no_difference('Book.count') do
      post books_url, params: { book: { title: "New Book", author: "New Author", genre: "Fiction", isbn: "1234567890123", total_copies: 1 } }
    end
    assert_redirected_to root_path
  end

  test "should show book" do
    sign_in @member
    get book_url(@book)
    assert_response :success
  end

  test "should get edit when librarian" do
    sign_in @librarian
    get edit_book_url(@book)
    assert_response :success
  end

  test "should not get edit when member" do
    sign_in @member
    get edit_book_url(@book)
    assert_redirected_to root_path
  end

  test "should update book when librarian" do
    sign_in @librarian
    patch book_url(@book), params: { book: { title: "Updated Title" } }
    assert_redirected_to book_url(@book)
    @book.reload
    assert_equal "Updated Title", @book.title
  end

  test "should not update book when member" do
    sign_in @member
    original_title = @book.title
    patch book_url(@book), params: { book: { title: "Updated Title" } }
    assert_redirected_to root_path
    @book.reload
    assert_equal original_title, @book.title
  end

  test "should destroy book when librarian" do
    sign_in @librarian
    assert_difference('Book.count', -1) do
      delete book_url(@book)
    end
    assert_redirected_to books_url
  end

  test "should not destroy book when member" do
    sign_in @member
    assert_no_difference('Book.count') do
      delete book_url(@book)
    end
    assert_redirected_to root_path
  end
end
