# frozen_string_literal: true

# Represents a question in a book that has an associated answer.
class Question < ApplicationRecord
  # Associations
  belongs_to :book

  # Validations
  validates :question, presence: true, length: { maximum: 140 }
end
