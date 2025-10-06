FactoryBot.define do
  factory :loan do
    association :user
    association :book
    borrowed_at { Time.current }
    due_date { 2.weeks.from_now }
    status { "borrowed" }

    trait :returned do
      status { "returned" }
      returned_at { Time.current }
    end

    trait :overdue do
      borrowed_at { 3.weeks.ago }
      due_date { 1.week.ago }
      status { "borrowed" }
    end

    trait :due_today do
      borrowed_at { 2.weeks.ago }
      due_date { Date.current.end_of_day }
      status { "borrowed" }
    end
  end
end
