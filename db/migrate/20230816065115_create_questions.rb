class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :question, limit: 140, null: false
      t.text :context, null: true
      t.text :answer, limit: 1000, null: true
      t.integer :ask_count, default: 1
      t.timestamps
    end
  end
end
