# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample users for testing
users_data = [
  {
    email: "librarian@library.com",
    password: "password123",
    first_name: "Sarah",
    last_name: "Johnson",
    role: "librarian"
  },
  {
    email: "member1@library.com",
    password: "password123",
    first_name: "John",
    last_name: "Smith",
    role: "member"
  },
  {
    email: "member2@library.com",
    password: "password123",
    first_name: "Emily",
    last_name: "Davis",
    role: "member"
  },
  {
    email: "admin@library.com",
    password: "password123",
    first_name: "Michael",
    last_name: "Brown",
    role: "librarian"
  }
]

users_data.each do |user_attrs|
  User.find_or_create_by(email: user_attrs[:email]) do |user|
    user.assign_attributes(user_attrs)
  end
end

puts "Created #{User.count} users"

# Create sample books for testing
books_data = [
  {
    title: "The Great Gatsby",
    author: "F. Scott Fitzgerald",
    genre: "Fiction",
    isbn: "9780743273565",
    total_copies: 3
  },
  {
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    genre: "Fiction",
    isbn: "9780061120084",
    total_copies: 2
  },
  {
    title: "1984",
    author: "George Orwell",
    genre: "Science Fiction",
    isbn: "9780451524935",
    total_copies: 4
  },
  {
    title: "Pride and Prejudice",
    author: "Jane Austen",
    genre: "Romance",
    isbn: "9780141439518",
    total_copies: 2
  },
  {
    title: "The Catcher in the Rye",
    author: "J.D. Salinger",
    genre: "Fiction",
    isbn: "9780316769174",
    total_copies: 3
  },
  {
    title: "A Brief History of Time",
    author: "Stephen Hawking",
    genre: "Science",
    isbn: "9780553380163",
    total_copies: 2
  }
]

books_data.each do |book_attrs|
  Book.find_or_create_by(isbn: book_attrs[:isbn]) do |book|
    book.assign_attributes(book_attrs)
  end
end

puts "Created #{Book.count} books"
