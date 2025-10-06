import React, { useState, useEffect } from 'react';

const SearchAndFilter = ({ onSearch, initialSearch = '', initialGenre = '', genres = [] }) => {
  const [search, setSearch] = useState(initialSearch);
  const [genre, setGenre] = useState(initialGenre);

  const handleSubmit = (e) => {
    e.preventDefault();
    onSearch({ search, genre });
  };

  const handleClear = () => {
    setSearch('');
    setGenre('');
    onSearch({ search: '', genre: '' });
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow mb-6">
      <form onSubmit={handleSubmit} className="flex flex-wrap gap-4">
        <div className="flex-1 min-w-64">
          <input
            type="text"
            placeholder="Search by title or author..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        
        <div className="min-w-48">
          <select
            value={genre}
            onChange={(e) => setGenre(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">All Genres</option>
            {genres.map((genreOption) => (
              <option key={genreOption} value={genreOption}>
                {genreOption}
              </option>
            ))}
          </select>
        </div>
        
        <div className="flex gap-2">
          <button
            type="submit"
            className="bg-gray-600 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded"
          >
            Search
          </button>
          <button
            type="button"
            onClick={handleClear}
            className="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded"
          >
            Clear
          </button>
        </div>
      </form>
    </div>
  );
};

export default SearchAndFilter;
