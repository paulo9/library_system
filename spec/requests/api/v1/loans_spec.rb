require 'rails_helper'

RSpec.describe "Api::V1::Loans", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:another_member) { create(:user, :member) }
  let(:book) { create(:book, :with_multiple_copies) }
  let(:loan) { create(:loan, user: member, book: book) }

  describe "GET /api/v1/loans" do
    context "when user is a librarian" do
      before { sign_in librarian }

      it "returns a successful response" do
        get "/api/v1/loans"
        expect(response).to have_http_status(:ok)
      end

      it "returns all loans in JSON format" do
        create_list(:loan, 3)
        get "/api/v1/loans"
        
        expect(response.content_type).to include("application/json")
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["loans"]).to be_an(Array)
        expect(json_response["data"]["loans"].length).to eq(3)
      end

      it "includes pagination information" do
        create_list(:loan, 15)
        get "/api/v1/loans", params: { page: 1, per_page: 10 }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["pagination"]).to include(
          "current_page" => 1,
          "per_page" => 10,
          "total_count" => 15,
          "total_pages" => 2
        )
      end

      it "filters loans by user_id" do
        loan1 = create(:loan, user: member)
        loan2 = create(:loan, user: another_member)
        
        get "/api/v1/loans", params: { user_id: member.id }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["loans"].length).to eq(1)
        expect(json_response["data"]["loans"].first["user"]["id"]).to eq(member.id)
      end

      it "filters loans by book_id" do
        book1 = create(:book)
        book2 = create(:book)
        loan1 = create(:loan, book: book1)
        loan2 = create(:loan, book: book2)
        
        get "/api/v1/loans", params: { book_id: book1.id }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["loans"].length).to eq(1)
        expect(json_response["data"]["loans"].first["book"]["id"]).to eq(book1.id)
      end

      it "filters loans by status" do
        borrowed_loan = create(:loan, status: "borrowed")
        returned_loan = create(:loan, :returned)
        
        get "/api/v1/loans", params: { status: "borrowed" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["loans"].length).to eq(1)
        expect(json_response["data"]["loans"].first["status"]).to eq("borrowed")
      end

      it "filters loans by overdue status" do
        overdue_loan = create(:loan, :overdue)
        current_loan = create(:loan)
        
        get "/api/v1/loans", params: { overdue: "true" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["loans"].length).to eq(1)
        expect(json_response["data"]["loans"].first["overdue"]).to be true
      end

      it "filters loans by due today" do
        due_today_loan = create(:loan, :due_today)
        future_loan = create(:loan)
        
        get "/api/v1/loans", params: { due_today: "true" }
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["loans"].length).to eq(1)
        expect(json_response["data"]["loans"].first["id"]).to eq(due_today_loan.id)
      end
    end

    context "when user is a member" do
      before { sign_in member }

      it "returns only the member's own loans" do
        member_loan = create(:loan, user: member)
        other_loan = create(:loan, user: another_member)
        
        get "/api/v1/loans"
        
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["loans"].length).to eq(1)
        expect(json_response["data"]["loans"].first["user"]["id"]).to eq(member.id)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        get "/api/v1/loans"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/loans/:id" do
    context "when user is a librarian" do
      before { sign_in librarian }

      it "returns a successful response" do
        get "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:ok)
      end

      it "returns the loan in JSON format" do
        get "/api/v1/loans/#{loan.id}"
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["data"]["id"]).to eq(loan.id)
        expect(json_response["data"]["user"]["id"]).to eq(loan.user.id)
        expect(json_response["data"]["book"]["id"]).to eq(loan.book.id)
        expect(json_response["data"]["status"]).to eq(loan.status)
        expect(json_response["data"]).to include("borrowed_at", "due_date", "overdue", "days_overdue", "days_until_due")
      end

      it "returns not found for non-existent loan" do
        get "/api/v1/loans/99999"
        expect(response).to have_http_status(:not_found)
        
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Record not found")
      end
    end

    context "when user is the loan owner" do
      before { sign_in member }

      it "returns a successful response" do
        get "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not the loan owner" do
      before { sign_in another_member }

      it "returns forbidden status" do
        get "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        get "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/loans" do
    context "when user is a member" do
      before { sign_in member }

      context "with valid parameters" do
        it "creates a new loan" do
          expect {
            post "/api/v1/loans", params: { book_id: book.id }
          }.to change(Loan, :count).by(1)
        end

        it "returns a successful response" do
          post "/api/v1/loans", params: { book_id: book.id }
          expect(response).to have_http_status(:created)
        end

        it "returns the created loan in JSON format" do
          post "/api/v1/loans", params: { book_id: book.id }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be true
          expect(json_response["message"]).to eq("Book borrowed successfully")
          expect(json_response["data"]["user"]["id"]).to eq(member.id)
          expect(json_response["data"]["book"]["id"]).to eq(book.id)
          expect(json_response["data"]["status"]).to eq("borrowed")
        end

        it "sets the correct due date" do
          post "/api/v1/loans", params: { book_id: book.id }
          
          json_response = JSON.parse(response.body)
          due_date = Time.parse(json_response["data"]["due_date"])
          expected_due_date = 2.weeks.from_now
          
          expect(due_date).to be_within(1.minute).of(expected_due_date)
        end
      end

      context "when book is not available" do
        let(:unavailable_book) do
          book = create(:book, total_copies: 1)
          # Create a loan with a different user to make the book unavailable
          other_user = create(:user, :member)
          create(:loan, book: book, user: other_user)
          book
        end

        it "does not create a new loan" do
          expect {
            post "/api/v1/loans", params: { book_id: unavailable_book.id }
          }.not_to change(Loan, :count)
        end

        it "returns an error response" do
          post "/api/v1/loans", params: { book_id: unavailable_book.id }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns appropriate error message" do
          post "/api/v1/loans", params: { book_id: unavailable_book.id }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["message"]).to include("cannot borrow this book")
        end
      end

      context "when user already borrowed the book" do
        before { create(:loan, user: member, book: book) }

        it "does not create a new loan" do
          expect {
            post "/api/v1/loans", params: { book_id: book.id }
          }.not_to change(Loan, :count)
        end

        it "returns an error response" do
          post "/api/v1/loans", params: { book_id: book.id }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with invalid book_id" do
        it "returns not found" do
          post "/api/v1/loans", params: { book_id: 99999 }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when user is a librarian" do
      before { sign_in librarian }

      it "creates a new loan" do
        expect {
          post "/api/v1/loans", params: { book_id: book.id }
        }.to change(Loan, :count).by(1)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        post "/api/v1/loans", params: { book_id: book.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH/PUT /api/v1/loans/:id" do
    context "when user is a librarian" do
      before { sign_in librarian }

      context "when returning a borrowed book" do
        it "updates the loan status to returned" do
          patch "/api/v1/loans/#{loan.id}", params: { loan: { status: "returned" } }
          loan.reload
          expect(loan.status).to eq("returned")
          expect(loan.returned_at).not_to be_nil
        end

        it "returns a successful response" do
          patch "/api/v1/loans/#{loan.id}", params: { loan: { status: "returned" } }
          expect(response).to have_http_status(:ok)
        end

        it "returns the updated loan in JSON format" do
          patch "/api/v1/loans/#{loan.id}", params: { loan: { status: "returned" } }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be true
          expect(json_response["message"]).to eq("Book returned successfully")
          expect(json_response["data"]["status"]).to eq("returned")
          expect(json_response["data"]["returned_at"]).not_to be_nil
        end
      end

      context "when trying to return an already returned book" do
        let(:returned_loan) { create(:loan, :returned) }

        it "returns an error response" do
          patch "/api/v1/loans/#{returned_loan.id}", params: { loan: { status: "returned" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns appropriate error message" do
          patch "/api/v1/loans/#{returned_loan.id}", params: { loan: { status: "returned" } }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["message"]).to include("already been returned")
        end
      end

      context "when trying to update other fields" do
        it "returns an error response" do
          patch "/api/v1/loans/#{loan.id}", params: { loan: { borrowed_at: Time.current } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns appropriate error message" do
          patch "/api/v1/loans/#{loan.id}", params: { loan: { borrowed_at: Time.current } }
          
          json_response = JSON.parse(response.body)
          expect(json_response["success"]).to be false
          expect(json_response["message"]).to include("Only status updates are allowed")
        end
      end
    end

    context "when user is the loan owner" do
      before { sign_in member }

      it "allows returning the book" do
        patch "/api/v1/loans/#{loan.id}", params: { loan: { status: "returned" } }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not the loan owner" do
      before { sign_in another_member }

      it "returns forbidden status" do
        patch "/api/v1/loans/#{loan.id}", params: { loan: { status: "returned" } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        patch "/api/v1/loans/#{loan.id}", params: { loan: { status: "returned" } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/loans/:id" do
    context "when user is a librarian" do
      before { sign_in librarian }

      it "deletes the loan" do
        loan_to_delete = create(:loan)
        expect {
          delete "/api/v1/loans/#{loan_to_delete.id}"
        }.to change(Loan, :count).by(-1)
      end

      it "returns a successful response" do
        delete "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:ok)
      end

      it "returns success message" do
        delete "/api/v1/loans/#{loan.id}"
        
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq("Loan record deleted successfully")
      end
    end

    context "when user is the loan owner" do
      before { sign_in member }

      it "allows deleting the loan" do
        expect {
          delete "/api/v1/loans/#{loan.id}"
        }.to change(Loan, :count).by(-1)
      end
    end

    context "when user is not the loan owner" do
      before { sign_in another_member }

      it "returns forbidden status" do
        delete "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized status" do
        delete "/api/v1/loans/#{loan.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
