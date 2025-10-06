class CreateLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :due_date, null: false
      t.datetime :returned_at
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :loans, [:user_id, :book_id, :status], unique: true, where: "status = 0"
    add_index :loans, :due_date
    add_index :loans, :status
  end
end
