# frozen_string_literal: true

# Represents a book that contains a collection of questions and answers.
class Book < ApplicationRecord
  # Associations
  has_many :questions, dependent: :destroy
  has_many :lucky_questions, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :purchase_link, presence: true
  validates :image_path, presence: true
  validates :embeddings_path, presence: true
  validates :pages_path, presence: true
  validates :default_question, presence: true
  validates :context_header, presence: true
  validates :context_qa, presence: true

  # Class methods

  # Returns the singleton instance of the book with the title specified in the Rails configuration.
  #
  # @return [Book] The book instance.
  @instance = nil
  def self.instance
    @instance ||= find_by(title: Rails.application.config.book_title)
  end
end
