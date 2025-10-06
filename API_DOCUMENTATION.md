# Library Management System API Documentation

## Overview

This document describes the RESTful API for the Library Management System. The API provides endpoints for managing books and loans with proper authentication and authorization.

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

The API supports two authentication methods:

### 1. Token Authentication (Recommended for External Access)
For external applications and API clients, use token authentication:

**API Token**: `library_api_2024_secure_token`

**Usage Methods:**
- **Authorization Header**: `Authorization: Bearer library_api_2024_secure_token`
- **Query Parameter**: `?api_token=library_api_2024_secure_token`

### 2. Session Authentication (For Web Application)
For web application users, use Devise session authentication (sign in through the web interface).

### Public API Endpoints
- `/api/v1/public/books` - Public book listing (token required)
- `/api/v1/public/books/:id` - Public book details (token required)

### Authenticated API Endpoints  
- `/api/v1/books` - Full book management (token or session required)
- `/api/v1/loans` - Loan management (token or session required)

## Response Format

All API responses follow a consistent JSON format:

### Success Response
```json
{
  "success": true,
  "message": "Success message",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "details": ["Additional error details"]
}
```

## Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server error

## Public Books API (Token Required)

### GET /api/v1/public/books

Retrieve a list of books with optional filtering and pagination. **Requires API token.**

**Parameters:**
- `search` (string, optional) - Search by title or author
- `genre` (string, optional) - Filter by genre
- `author` (string, optional) - Filter by author
- `available` (boolean, optional) - Filter by availability
- `page` (integer, optional) - Page number (default: 1)
- `per_page` (integer, optional) - Items per page (default: 10, max: 100)

**Example Request:**
```bash
curl -H "Authorization: Bearer library_api_2024_secure_token" \
  "http://localhost:3000/api/v1/public/books?search=ruby&genre=Fiction&page=1&per_page=5"
```

**Example Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "books": [
      {
        "id": 1,
        "title": "Ruby Programming",
        "author": "John Doe",
        "genre": "Fiction",
        "isbn": "1234567890123",
        "total_copies": 5,
        "available_copies": 3,
        "borrowed_copies": 2,
        "availability_status": "3 of 5 available",
        "available": true,
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 5,
      "total_count": 1,
      "total_pages": 1
    }
  }
}
```

### GET /api/v1/public/books/:id

Retrieve a specific book by ID. **Requires API token.**

**Example Request:**
```bash
curl -H "Authorization: Bearer library_api_2024_secure_token" \
  "http://localhost:3000/api/v1/public/books/1"
```

**Example Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": 1,
    "title": "Ruby Programming",
    "author": "John Doe",
    "genre": "Fiction",
    "isbn": "1234567890123",
    "total_copies": 5,
    "available_copies": 3,
    "borrowed_copies": 2,
    "availability_status": "3 of 5 available",
    "available": true,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

## Authenticated Books API (Token or Session Required)

### GET /api/v1/books

Retrieve a list of books with optional filtering and pagination.

**Parameters:**
- `search` (string, optional) - Search by title or author
- `genre` (string, optional) - Filter by genre
- `author` (string, optional) - Filter by author
- `available` (boolean, optional) - Filter by availability
- `page` (integer, optional) - Page number (default: 1)
- `per_page` (integer, optional) - Items per page (default: 10, max: 100)

**Example Request:**
```bash
GET /api/v1/books?search=ruby&genre=Fiction&page=1&per_page=5
```

**Example Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "books": [
      {
        "id": 1,
        "title": "Ruby Programming",
        "author": "John Doe",
        "genre": "Fiction",
        "isbn": "1234567890123",
        "total_copies": 5,
        "available_copies": 3,
        "borrowed_copies": 2,
        "availability_status": "3 of 5 available",
        "available": true,
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 5,
      "total_count": 1,
      "total_pages": 1
    }
  }
}
```

### GET /api/v1/books/:id

Retrieve a specific book by ID.

**Example Request:**
```bash
GET /api/v1/books/1
```

**Example Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": 1,
    "title": "Ruby Programming",
    "author": "John Doe",
    "genre": "Fiction",
    "isbn": "1234567890123",
    "total_copies": 5,
    "available_copies": 3,
    "borrowed_copies": 2,
    "availability_status": "3 of 5 available",
    "available": true,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### POST /api/v1/books

Create a new book. Requires librarian role.

**Request Body:**
```json
{
  "book": {
    "title": "New Book Title",
    "author": "Author Name",
    "genre": "Genre",
    "isbn": "1234567890123",
    "total_copies": 5
  }
}
```

**Example Response:**
```json
{
  "success": true,
  "message": "Book created successfully",
  "data": {
    "id": 2,
    "title": "New Book Title",
    "author": "Author Name",
    "genre": "Genre",
    "isbn": "1234567890123",
    "total_copies": 5,
    "available_copies": 5,
    "borrowed_copies": 0,
    "availability_status": "5 of 5 available",
    "available": true,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### PATCH/PUT /api/v1/books/:id

Update an existing book. Requires librarian role.

**Request Body:**
```json
{
  "book": {
    "title": "Updated Title",
    "author": "Updated Author"
  }
}
```

**Example Response:**
```json
{
  "success": true,
  "message": "Book updated successfully",
  "data": {
    "id": 1,
    "title": "Updated Title",
    "author": "Updated Author",
    "genre": "Fiction",
    "isbn": "1234567890123",
    "total_copies": 5,
    "available_copies": 3,
    "borrowed_copies": 2,
    "availability_status": "3 of 5 available",
    "available": true,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### DELETE /api/v1/books/:id

Delete a book. Requires librarian role.

**Example Response:**
```json
{
  "success": true,
  "message": "Book deleted successfully",
  "data": {}
}
```

## Loans API

### GET /api/v1/loans

Retrieve a list of loans with optional filtering and pagination.

**Parameters:**
- `user_id` (integer, optional) - Filter by user ID (librarians only)
- `book_id` (integer, optional) - Filter by book ID
- `status` (string, optional) - Filter by status ("borrowed" or "returned")
- `overdue` (boolean, optional) - Filter by overdue status
- `due_today` (boolean, optional) - Filter by loans due today
- `page` (integer, optional) - Page number (default: 1)
- `per_page` (integer, optional) - Items per page (default: 10, max: 100)

**Example Request:**
```bash
GET /api/v1/loans?status=borrowed&overdue=true&page=1&per_page=10
```

**Example Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "loans": [
      {
        "id": 1,
        "user": {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com"
        },
        "book": {
          "id": 1,
          "title": "Ruby Programming",
          "author": "Author Name",
          "isbn": "1234567890123"
        },
        "status": "borrowed",
        "borrowed_at": "2024-01-01T00:00:00.000Z",
        "due_date": "2024-01-15T00:00:00.000Z",
        "returned_at": null,
        "overdue": false,
        "days_overdue": 0,
        "days_until_due": 5,
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total_count": 1,
      "total_pages": 1
    }
  }
}
```

### GET /api/v1/loans/:id

Retrieve a specific loan by ID.

**Example Request:**
```bash
GET /api/v1/loans/1
```

**Example Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "id": 1,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "book": {
      "id": 1,
      "title": "Ruby Programming",
      "author": "Author Name",
      "isbn": "1234567890123"
    },
    "status": "borrowed",
    "borrowed_at": "2024-01-01T00:00:00.000Z",
    "due_date": "2024-01-15T00:00:00.000Z",
    "returned_at": null,
    "overdue": false,
    "days_overdue": 0,
    "days_until_due": 5,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### POST /api/v1/loans

Create a new loan (borrow a book).

**Request Body:**
```json
{
  "book_id": 1
}
```

**Example Response:**
```json
{
  "success": true,
  "message": "Book borrowed successfully",
  "data": {
    "id": 2,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "book": {
      "id": 1,
      "title": "Ruby Programming",
      "author": "Author Name",
      "isbn": "1234567890123"
    },
    "status": "borrowed",
    "borrowed_at": "2024-01-01T00:00:00.000Z",
    "due_date": "2024-01-15T00:00:00.000Z",
    "returned_at": null,
    "overdue": false,
    "days_overdue": 0,
    "days_until_due": 14,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### PATCH/PUT /api/v1/loans/:id

Update a loan (return a book).

**Request Body:**
```json
{
  "loan": {
    "status": "returned"
  }
}
```

**Example Response:**
```json
{
  "success": true,
  "message": "Book returned successfully",
  "data": {
    "id": 1,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "book": {
      "id": 1,
      "title": "Ruby Programming",
      "author": "Author Name",
      "isbn": "1234567890123"
    },
    "status": "returned",
    "borrowed_at": "2024-01-01T00:00:00.000Z",
    "due_date": "2024-01-15T00:00:00.000Z",
    "returned_at": "2024-01-10T00:00:00.000Z",
    "overdue": false,
    "days_overdue": 0,
    "days_until_due": 0,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-10T00:00:00.000Z"
  }
}
```

### DELETE /api/v1/loans/:id

Delete a loan record.

**Example Response:**
```json
{
  "success": true,
  "message": "Loan record deleted successfully",
  "data": {}
}
```

## Error Examples

### Validation Error (422)
```json
{
  "success": false,
  "message": "Failed to create book",
  "details": [
    "Title can't be blank",
    "Author can't be blank",
    "Isbn is the wrong length (should be 13 characters)"
  ]
}
```

### Not Found Error (404)
```json
{
  "error": "Record not found",
  "message": "Couldn't find Book with 'id'=999"
}
```

### Unauthorized Error (401)
```json
{
  "success": false,
  "message": "You need to sign in or sign up before continuing."
}
```

### Forbidden Error (403)
```json
{
  "error": "Not authorized",
  "message": "You are not authorized to perform this action"
}
```

## Testing

To run the API tests:

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rspec

# Run only API tests
bundle exec rspec spec/requests/api/

# Run with coverage
bundle exec rspec --format documentation
```

## Usage Examples

### Using curl

#### Public API (Token Authentication)

```bash
# Get all books (public API with token)
curl -X GET "http://localhost:3000/api/v1/public/books" \
  -H "Authorization: Bearer library_api_2024_secure_token" \
  -H "Content-Type: application/json"

# Get specific book (public API with token)
curl -X GET "http://localhost:3000/api/v1/public/books/1" \
  -H "Authorization: Bearer library_api_2024_secure_token" \
  -H "Content-Type: application/json"

# Get books with token as parameter
curl -X GET "http://localhost:3000/api/v1/public/books?api_token=library_api_2024_secure_token" \
  -H "Content-Type: application/json"
```

#### Authenticated API (Token Authentication)

```bash
# Get all books (authenticated API with token)
curl -X GET "http://localhost:3000/api/v1/books" \
  -H "Authorization: Bearer library_api_2024_secure_token" \
  -H "Content-Type: application/json"

# Create a new book (authenticated API with token)
curl -X POST "http://localhost:3000/api/v1/books" \
  -H "Authorization: Bearer library_api_2024_secure_token" \
  -H "Content-Type: application/json" \
  -d '{
    "book": {
      "title": "New Book",
      "author": "Author Name",
      "genre": "Fiction",
      "isbn": "1234567890123",
      "total_copies": 5
    }
  }'
```

#### Authenticated API (Session Authentication)

```bash
# Get all books (authenticated API with session)
curl -X GET "http://localhost:3000/api/v1/books" \
  -H "Content-Type: application/json" \
  -b "session_cookie"

# Create a new book (requires librarian login)
curl -X POST "http://localhost:3000/api/v1/books" \
  -H "Content-Type: application/json" \
  -b "session_cookie" \
  -d '{
    "book": {
      "title": "New Book",
      "author": "Author Name",
      "genre": "Fiction",
      "isbn": "1234567890123",
      "total_copies": 5
    }
  }'

# Borrow a book
curl -X POST "http://localhost:3000/api/v1/loans" \
  -H "Content-Type: application/json" \
  -b "session_cookie" \
  -d '{
    "book_id": 1
  }'

# Return a book
curl -X PATCH "http://localhost:3000/api/v1/loans/1" \
  -H "Content-Type: application/json" \
  -b "session_cookie" \
  -d '{
    "loan": {
      "status": "returned"
    }
  }'
```

### Using JavaScript/Fetch

```javascript
// Get all books
fetch('/api/v1/books', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: 'include'
})
.then(response => response.json())
.then(data => console.log(data));

// Create a new book
fetch('/api/v1/books', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: 'include',
  body: JSON.stringify({
    book: {
      title: 'New Book',
      author: 'Author Name',
      genre: 'Fiction',
      isbn: '1234567890123',
      total_copies: 5
    }
  })
})
.then(response => response.json())
.then(data => console.log(data));
```
