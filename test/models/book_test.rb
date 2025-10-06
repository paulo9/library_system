require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @book = Book.new(
      title: "Test Book",
      author: "Test Author",
      genre: "Test Genre",
      isbn: "1234567890123",
      total_copies: 1
    )
  end

  test "should be valid" do
    assert @book.valid?
  end

  test "title should be present" do
    @book.title = ""
    assert_not @book.valid?
  end

  test "author should be present" do
    @book.author = ""
    assert_not @book.valid?
  end

  test "genre should be present" do
    @book.genre = ""
    assert_not @book.valid?
  end

  test "isbn should be present" do
    @book.isbn = ""
    assert_not @book.valid?
  end

  test "isbn should be unique" do
    duplicate_book = @book.dup
    @book.save
    assert_not duplicate_book.valid?
  end

  test "isbn should be 13 characters" do
    @book.isbn = "123456789012"
    assert_not @book.valid?
    @book.isbn = "12345678901234"
    assert_not @book.valid?
  end

  test "total_copies should be present" do
    @book.total_copies = nil
    assert_not @book.valid?
  end

  test "total_copies should be greater than 0" do
    @book.total_copies = 0
    assert_not @book.valid?
    @book.total_copies = -1
    assert_not @book.valid?
  end

  test "display_title should return title and author" do
    assert_equal "Test Book by Test Author", @book.display_title
  end
end
