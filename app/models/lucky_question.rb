# frozen_string_literal: true

# Represents a lucky question that is randomly selected from a book.
class LuckyQuestion < ApplicationRecord
  # Associations
  belongs_to :book

  # Validations
  validates :question, presence: true, length: { maximum: 140 }
end
