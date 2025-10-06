import React from 'react';

const BookCard = ({ book, currentUser, onBorrow, onEdit, onDelete }) => {
  const handleBorrow = () => {
    if (window.confirm("Borrow this book? It will be due in 2 weeks.")) {
      onBorrow(book.id);
    }
  };

  const handleDelete = () => {
    if (window.confirm("Are you sure you want to delete this book?")) {
      onDelete(book.id);
    }
  };

  const canBorrow = currentUser?.role === 'member' && book.available && !book.borrowed_by_current_user;
  const canEdit = currentUser?.role === 'librarian';
  const isBorrowedByUser = currentUser?.role === 'member' && book.borrowed_by_current_user;

  return (
    <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200">
      <div className="p-6">
        <h3 className="text-xl font-semibold text-gray-900 mb-2">
          <a href={`/books/${book.id}`} className="hover:text-blue-600">
            {book.title}
          </a>
        </h3>
        
        <p className="text-gray-600 mb-2">
          <span className="font-medium">Author:</span> {book.author}
        </p>
        
        <p className="text-gray-600 mb-2">
          <span className="font-medium">Genre:</span> 
          <span className="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded ml-1">
            {book.genre}
          </span>
        </p>
        
        <p className="text-gray-600 mb-2">
          <span className="font-medium">ISBN:</span> {book.isbn}
        </p>
        
        <p className="text-gray-600 mb-2">
          <span className="font-medium">Copies:</span> {book.availability_status}
        </p>
        
        <div className="flex justify-between items-center">
          <a 
            href={`/books/${book.id}`}
            className="text-blue-600 hover:text-blue-800 font-medium"
          >
            View Details
          </a>
          
          <div className="flex gap-2">
            {canBorrow && (
              <button
                onClick={handleBorrow}
                className="bg-green-600 hover:bg-green-700 text-white text-xs font-bold py-1 px-2 rounded"
              >
                Borrow
              </button>
            )}
            
            {isBorrowedByUser && (
              <span className="text-green-600 text-xs font-medium">Borrowed by you</span>
            )}
            
            {!book.available && !isBorrowedByUser && (
              <span className="text-red-600 text-xs font-medium">Not available</span>
            )}
            
            {canEdit && (
              <>
                <a 
                  href={`/books/${book.id}/edit`}
                  className="text-yellow-600 hover:text-yellow-800 font-medium"
                >
                  Edit
                </a>
                <button
                  onClick={handleDelete}
                  className="text-red-600 hover:text-red-800 font-medium bg-transparent border-none cursor-pointer underline"
                >
                  Delete
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default BookCard;
