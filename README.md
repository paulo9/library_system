# Library Management System

A modern library management system built with Ruby on Rails 7.1, React, and PostgreSQL. Features user authentication, book management, loan tracking, and a RESTful API with both authenticated and public endpoints.

## 🚀 Features

### Core Functionality
- **User Authentication & Authorization** - Devise-based authentication with role-based access (Librarian/Member)
- **Book Management** - CRUD operations for books with search and filtering
- **Loan Management** - Borrow and return books with due date tracking
- **Dashboard** - Role-specific dashboards for librarians and members
- **Modern UI** - Tailwind CSS with responsive design

### API Features
- **RESTful API** - Complete CRUD operations for books and loans
- **Public API** - Token-based public access for external integrations
- **Authenticated API** - Session-based authentication for internal use
- **Comprehensive Testing** - RSpec test suite with FactoryBot

### Frontend
- **React Integration** - Modern React components with Vite
- **Hybrid Approach** - Mix of Rails ERB views and React components
- **API Integration** - Real-time data fetching and updates

## 🛠️ Tech Stack

### Backend
- **Ruby 3.3.0**
- **Rails 7.1.3**
- **PostgreSQL 15**
- **Devise** - Authentication
- **Pundit** - Authorization
- **RSpec** - Testing

### Frontend
- **React 19.2.0**
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **JavaScript ES6+**

### Infrastructure
- **Docker & Docker Compose**
- **PostgreSQL** - Database
- **Puma** - Web server

## 📋 Prerequisites

Before running this project, make sure you have:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Git**

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd library_system
```

### 2. Start the Application

```bash
# Start all services (database + web server)
docker-compose up

# Or run in background
docker-compose up -d
```

### 3. Initialize the Database

```bash
# Run database migrations
docker-compose exec web rails db:migrate

# Seed the database with sample data
docker-compose exec web rails db:seed
```

### 4. Access the Application

- **Web Application**: http://localhost:3000
- **Database**: localhost:5432 (postgres/password)

## 👥 Default Users

After seeding, you can log in with these accounts:

### Librarian Account
- **Email**: librarian@example.com
- **Password**: password123
- **Permissions**: Full access to all features

### Member Account
- **Email**: member@example.com
- **Password**: password123
- **Permissions**: Borrow books, view own loans

## 🔧 Development

### Running Commands

All Rails commands should be run inside the Docker container:

```bash
# Run Rails console
docker-compose exec web rails console

# Run database migrations
docker-compose exec web rails db:migrate

# Run tests
docker-compose exec web rspec

# Generate new migration
docker-compose exec web rails generate migration CreateNewTable

# Run specific test file
docker-compose exec web rspec spec/requests/api/v1/books_spec.rb
```

### File Structure

```
app/
├── controllers/
│   ├── api/                    # API controllers
│   │   ├── base_controller.rb  # API base with authentication
│   │   └── v1/
│   │       ├── books_controller.rb
│   │       ├── loans_controller.rb
│   │       └── public/         # Public API endpoints
│   ├── books_controller.rb     # Web interface
│   ├── loans_controller.rb
│   └── dashboard_controller.rb
├── models/
│   ├── user.rb                 # Devise user model
│   ├── book.rb                 # Book model with validations
│   └── loan.rb                 # Loan model with relationships
├── policies/                   # Pundit authorization
│   ├── book_policy.rb
│   └── loan_policy.rb
├── frontend/                   # React components
│   ├── components/
│   │   ├── App.jsx
│   │   ├── BookCard.jsx
│   │   ├── BooksList.jsx
│   │   └── SearchAndFilter.jsx
│   └── entrypoints/
│       ├── application.jsx
│       └── books.jsx
└── views/                      # Rails ERB templates
    ├── books/
    │   ├── index.html.erb      # Original Rails view
    │   └── index_react.html.erb # React-powered view
    ├── dashboard/
    └── layouts/
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
docker-compose exec web rspec

# Run specific test file
docker-compose exec web rspec spec/requests/api/v1/books_spec.rb

# Run tests with coverage
docker-compose exec web rspec --format documentation
```

### Test Structure

```
spec/
├── factories/                  # FactoryBot factories
│   ├── users.rb
│   ├── books.rb
│   └── loans.rb
├── requests/
│   └── api/
│       └── v1/
│           ├── books_spec.rb   # API endpoint tests
│           └── loans_spec.rb
└── rails_helper.rb            # RSpec configuration
```

## 🌐 API Documentation

### Authentication

#### Public API (Token-based)
```bash
# Use this token for public API access
Authorization: Bearer library_api_2024_secure_token
```

#### Authenticated API (Session-based)
```bash
# Login first, then use session cookies
curl -X POST http://localhost:3000/users/sign_in \
  -d "user[email]=librarian@example.com" \
  -d "user[password]=password123"
```

### API Endpoints

#### Books API
```bash
# Get all books (public)
curl -H "Authorization: Bearer library_api_2024_secure_token" \
  http://localhost:3000/api/v1/public/books

# Get specific book (public)
curl -H "Authorization: Bearer library_api_2024_secure_token" \
  http://localhost:3000/api/v1/public/books/1

# Create book (authenticated)
curl -X POST http://localhost:3000/api/v1/books \
  -H "Content-Type: application/json" \
  -d '{"book":{"title":"New Book","author":"Author Name","isbn":"1234567890","genre":"Fiction","total_copies":5}}'

# Update book (authenticated)
curl -X PUT http://localhost:3000/api/v1/books/1 \
  -H "Content-Type: application/json" \
  -d '{"book":{"title":"Updated Title"}}'

# Delete book (authenticated)
curl -X DELETE http://localhost:3000/api/v1/books/1
```

#### Loans API
```bash
# Get all loans (authenticated)
curl http://localhost:3000/api/v1/loans

# Create loan (authenticated)
curl -X POST http://localhost:3000/api/v1/loans \
  -H "Content-Type: application/json" \
  -d '{"loan":{"book_id":1,"due_date":"2024-12-31"}}'

# Return book (authenticated)
curl -X PUT http://localhost:3000/api/v1/loans/1 \
  -H "Content-Type: application/json" \
  -d '{"loan":{"returned_at":"2024-01-15T10:00:00Z"}}'
```

### API Response Format

```json
{
  "books": [
    {
      "id": 1,
      "title": "Sample Book",
      "author": "Author Name",
      "isbn": "1234567890",
      "genre": "Fiction",
      "total_copies": 5,
      "available_copies": 3,
      "available": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 1
  }
}
```

