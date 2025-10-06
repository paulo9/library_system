import React, { useState, useEffect } from 'react';
import BookCard from './BookCard';
import SearchAndFilter from './SearchAndFilter';

const BooksList = ({ 
  initialBooks = [], 
  initialGenres = [], 
  currentUser = null, 
  canCreateBook = false,
  initialSearch = '',
  initialGenre = ''
}) => {
  const [books, setBooks] = useState(initialBooks);
  const [genres, setGenres] = useState(initialGenres);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchBooks = async (searchParams = {}) => {
    setLoading(true);
    setError(null);
    
    try {
      const params = new URLSearchParams();
      if (searchParams.search) params.append('search', searchParams.search);
      if (searchParams.genre) params.append('genre', searchParams.genre);
      
      const response = await fetch(`/api/v1/public/books?${params.toString()}`, {
        headers: {
          'Authorization': 'Bearer library_api_2024_secure_token',
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to fetch books');
      }
      
      const data = await response.json();
      setBooks(data.data.books);
    } catch (err) {
      setError(err.message);
      console.error('Error fetching books:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (searchParams) => {
    fetchBooks(searchParams);
    // Update URL without page reload
    const url = new URL(window.location);
    if (searchParams.search) {
      url.searchParams.set('search', searchParams.search);
    } else {
      url.searchParams.delete('search');
    }
    if (searchParams.genre) {
      url.searchParams.set('genre', searchParams.genre);
    } else {
      url.searchParams.delete('genre');
    }
    window.history.pushState({}, '', url);
  };

  const handleBorrow = async (bookId) => {
    try {
      const response = await fetch(`/api/v1/loans`, {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer library_api_2024_secure_token',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ book_id: bookId })
      });
      
      if (response.ok) {
        // Refresh the books list to update availability
        fetchBooks();
        alert('Book borrowed successfully!');
      } else {
        const errorData = await response.json();
        alert(`Error: ${errorData.message}`);
      }
    } catch (err) {
      alert('Error borrowing book');
      console.error('Error borrowing book:', err);
    }
  };

  const handleEdit = (bookId) => {
    window.location.href = `/books/${bookId}/edit`;
  };

  const handleDelete = async (bookId) => {
    try {
      const response = await fetch(`/api/v1/books/${bookId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': 'Bearer library_api_2024_secure_token',
          'Content-Type': 'application/json'
        }
      });
      
      if (response.ok) {
        // Remove the book from the list
        setBooks(books.filter(book => book.id !== bookId));
        alert('Book deleted successfully!');
      } else {
        const errorData = await response.json();
        alert(`Error: ${errorData.message}`);
      }
    } catch (err) {
      alert('Error deleting book');
      console.error('Error deleting book:', err);
    }
  };

  return (
    <div className="mb-6">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-3xl font-bold text-gray-900">Books</h1>
        {canCreateBook && (
          <a 
            href="/books/new"
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Add New Book
          </a>
        )}
      </div>

      <SearchAndFilter
        onSearch={handleSearch}
        initialSearch={initialSearch}
        initialGenre={initialGenre}
        genres={genres}
      />

      {loading && (
        <div className="text-center py-8">
          <div className="text-gray-500">Loading books...</div>
        </div>
      )}

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          Error: {error}
        </div>
      )}

      {!loading && !error && books.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {books.map((book) => (
            <BookCard
              key={book.id}
              book={book}
              currentUser={currentUser}
              onBorrow={handleBorrow}
              onEdit={handleEdit}
              onDelete={handleDelete}
            />
          ))}
        </div>
      )}

      {!loading && !error && books.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-500 text-lg">
            {initialSearch || initialGenre ? (
              'No books found matching your search criteria.'
            ) : (
              <>
                No books available yet.
                {canCreateBook && (
                  <>
                    {' '}
                    <a href="/books/new" className="text-blue-600 hover:text-blue-800 font-medium">
                      Add the first book
                    </a>
                    .
                  </>
                )}
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default BooksList;
