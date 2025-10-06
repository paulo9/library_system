FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    isbn { Faker::Number.number(digits: 13).to_s }
    total_copies { Faker::Number.between(from: 1, to: 10) }

    trait :with_multiple_copies do
      total_copies { 5 }
    end

    trait :single_copy do
      total_copies { 1 }
    end

    trait :unavailable do
      total_copies { 1 }
      after(:create) do |book|
        # Create a loan to make the book unavailable
        create(:loan, book: book)
      end
    end
  end
end
