class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title, limit: 100
      t.string :purchase_link
      t.string :file_path, null: true
      t.string :image_path
      t.string :embeddings_path
      t.string :pages_path
      t.text :default_question
      t.text :context_header
      t.text :context_qa
      t.timestamps
    end

    add_index :books, :title, unique: true

    add_reference :questions, :book, foreign_key: true
    add_reference :lucky_questions, :book, foreign_key: true
  end
end
