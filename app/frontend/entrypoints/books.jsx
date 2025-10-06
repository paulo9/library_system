import React from "react";
import ReactDOM from "react-dom/client";
import BooksList from "../components/BooksList";

// Books-specific React entry point
const rootElement = document.getElementById("root");
if (rootElement) {
  const root = ReactDOM.createRoot(rootElement);
  
  // Get data from the page (passed from Rails)
  const booksData = window.booksData || { books: [], genres: [] };
  const currentUser = window.currentUser || null;
  const canCreateBook = window.canCreateBook || false;
  const searchParams = window.searchParams || { search: '', genre: '' };

  root.render(
    <div className="p-6">
      <BooksList
        initialBooks={booksData.books}
        initialGenres={booksData.genres}
        currentUser={currentUser}
        canCreateBook={canCreateBook}
        initialSearch={searchParams.search}
        initialGenre={searchParams.genre}
      />
    </div>
  );
}
