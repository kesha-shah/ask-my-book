class CreateLuckyQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :lucky_questions do |t|
      t.string :question, limit: 140, null: false
    end
  end
end
