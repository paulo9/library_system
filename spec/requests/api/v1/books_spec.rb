require 'rails_helper'

RSpec.describe "Api::V1::Books", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book) { create(:book) }
  let(:valid_attributes) do
    {
      title: "Test Book",
      author: "Test Author",
      genre: "Fiction",
      isbn: "1234567890123",
      total_copies: 5
    }
  end
  let(:invalid_attributes) do
    {
      title: "",
      author: "",
      genre: "",
      isbn: "invalid",
      total_copies: -1
    }
  end

  describe "GET /api/v1/books" do
    context "when user is authenticated" do
      before { sign_in librarian }

      it "returns a successful response" do
        get "/api/v1/books"
        expect(response).to have_http_status(:ok)
      end

      it "returns books in JSON format" do
        create_list(:book, 3)
        get "/api/v1/books"
        
        expect(response.content_type).to include("application/json")
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["books"]).to be_an(Array)
        expect(json_response["data"]["books"].length).to eq(3)
      end

      it "includes pagination information" do
        create_list(:book, 15)
        get "/api/v1/books", params: { page: 1, per_page: 10 }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["pagination"]).to include(
          "current_page" => 1,
          "per_page" => 10,
          "total_count" => 15,
          "total_pages" => 2
        )
      end

      it "filters books by search query" do
        create(:book, title: "Ruby Programming", author: "John Doe")
        create(:book, title: "Python Basics", author: "Jane Smith")
        
        get "/api/v1/books", params: { search: "Ruby" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["books"].length).to eq(1)
        expect(json_response["data"]["books"].first["title"]).to eq("Ruby Programming")
      end

      it "filters books by genre" do
        create(:book, genre: "Fiction")
        create(:book, genre: "Non-Fiction")
        
        get "/api/v1/books", params: { genre: "Fiction" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["books"].length).to eq(1)
        expect(json_response["data"]["books"].first["genre"]).to eq("Fiction")
      end

      it "filters books by author" do
        create(:book, author: "John Doe")
        create(:book, author: "Jane Smith")
        
        get "/api/v1/books", params: { author: "John" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["books"].length).to eq(1)
        expect(json_response["data"]["books"].first["author"]).to eq("John Doe")
      end

      it "filters books by availability" do
        available_book = create(:book, :with_multiple_copies)
        # Create a book with all copies borrowed
        unavailable_book = create(:book, total_copies: 1)
        create(:loan, book: unavailable_book)
        
        get "/api/v1/books", params: { available: "true" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["books"].length).to eq(1)
        expect(json_response["data"]["books"].first["id"]).to eq(available_book.id)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        get "/api/v1/books"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/books/:id" do
    context "when user is authenticated" do
      before { sign_in librarian }

      it "returns a successful response" do
        get "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(:ok)
      end

      it "returns the book in JSON format" do
        get "/api/v1/books/#{book.id}"
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["id"]).to eq(book.id)
        expect(json_response["data"]["title"]).to eq(book.title)
        expect(json_response["data"]["author"]).to eq(book.author)
        expect(json_response["data"]["genre"]).to eq(book.genre)
        expect(json_response["data"]["isbn"]).to eq(book.isbn)
        expect(json_response["data"]["total_copies"]).to eq(book.total_copies)
        expect(json_response["data"]).to include("available_copies", "borrowed_copies", "availability_status", "available")
      end

      it "returns not found for non-existent book" do
        get "/api/v1/books/99999"
        expect(response).to have_http_status(:not_found)
        
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Record not found")
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        get "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/books" do
    context "when user is a librarian" do
      before { sign_in librarian }

      context "with valid parameters" do
        it "creates a new book" do
          expect {
            post "/api/v1/books", params: { book: valid_attributes }
          }.to change(Book, :count).by(1)
        end

        it "returns a successful response" do
          post "/api/v1/books", params: { book: valid_attributes }
          expect(response).to have_http_status(:created)
        end

        it "returns the created book in JSON format" do
          post "/api/v1/books", params: { book: valid_attributes }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be true
          expect(json_response["message"]).to eq("Book created successfully")
          expect(json_response["data"]["title"]).to eq(valid_attributes[:title])
          expect(json_response["data"]["author"]).to eq(valid_attributes[:author])
          expect(json_response["data"]["genre"]).to eq(valid_attributes[:genre])
          expect(json_response["data"]["isbn"]).to eq(valid_attributes[:isbn])
          expect(json_response["data"]["total_copies"]).to eq(valid_attributes[:total_copies])
        end
      end

      context "with invalid parameters" do
        it "does not create a new book" do
          expect {
            post "/api/v1/books", params: { book: invalid_attributes }
          }.not_to change(Book, :count)
        end

        it "returns an error response" do
          post "/api/v1/books", params: { book: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns validation errors" do
          post "/api/v1/books", params: { book: invalid_attributes }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["message"]).to eq("Failed to create book")
          expect(json_response["details"]).to be_an(Array)
        end
      end
    end

    context "when user is a member" do
      before { sign_in member }

      it "returns forbidden status" do
        post "/api/v1/books", params: { book: valid_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        post "/api/v1/books", params: { book: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH/PUT /api/v1/books/:id" do
    let(:update_attributes) { { title: "Updated Title" } }

    context "when user is a librarian" do
      before { sign_in librarian }

      context "with valid parameters" do
        it "updates the book" do
          patch "/api/v1/books/#{book.id}", params: { book: update_attributes }
          book.reload
          expect(book.title).to eq("Updated Title")
        end

        it "returns a successful response" do
          patch "/api/v1/books/#{book.id}", params: { book: update_attributes }
          expect(response).to have_http_status(:ok)
        end

        it "returns the updated book in JSON format" do
          patch "/api/v1/books/#{book.id}", params: { book: update_attributes }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be true
          expect(json_response["message"]).to eq("Book updated successfully")
          expect(json_response["data"]["title"]).to eq("Updated Title")
        end
      end

      context "with invalid parameters" do
        it "returns an error response" do
          patch "/api/v1/books/#{book.id}", params: { book: { title: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns validation errors" do
          patch "/api/v1/books/#{book.id}", params: { book: { title: "" } }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["message"]).to eq("Failed to update book")
          expect(json_response["details"]).to be_an(Array)
        end
      end
    end

    context "when user is a member" do
      before { sign_in member }

      it "returns forbidden status" do
        patch "/api/v1/books/#{book.id}", params: { book: update_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        patch "/api/v1/books/#{book.id}", params: { book: update_attributes }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/books/:id" do
    context "when user is a librarian" do
      before { sign_in librarian }

      it "deletes the book" do
        book_to_delete = create(:book)
        expect {
          delete "/api/v1/books/#{book_to_delete.id}"
        }.to change(Book, :count).by(-1)
      end

      it "returns a successful response" do
        delete "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(:ok)
      end

      it "returns success message" do
        delete "/api/v1/books/#{book.id}"
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq("Book deleted successfully")
      end
    end

    context "when user is a member" do
      before { sign_in member }

      it "returns forbidden status" do
        delete "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        delete "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
