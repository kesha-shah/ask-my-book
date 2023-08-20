# frozen_string_literal: true

# Controller for handling book-related requests.
class BooksController < ApplicationController
  # Returns the default question and lucky questions for the book.
  #
  # @return [JSON] The JSON response containing the current question and lucky questions.
  def get
    book = Book.instance
    render json: {
      current_question: book.default_question,
      lucky_questions: lucky_questions(book),
      purchase_link: book.purchase_link,
      image_path: book.image_path
    }
  end

  # Handles a question submission and returns the answer.
  #
  # @return [JSON] The JSON response containing the answer to the question.
  def ask
    asked_question = params['question']
    question = Question.find_by(question: asked_question)
    if question
      question.increment!(:ask_count)
      render json: { id: question.id, answer: question.answer, current_question: asked_question }
    else
      answer, context = GetAnswerService.call(Book.instance, asked_question)
      if answer
        question = Question.create(question: asked_question, answer:, ask_count: 1, context:,
                                   book_id: Book.instance.id)
        render json: { id: question.id, answer: question.answer, current_question: asked_question }
      else
        render json: { id: -1, answer: 'There was a problem answering the question. Please make sure you have setup the Open AI API key correctly.', current_question: asked_question }
      end
    end
  end

  # Returns the answer to a specific question that has already been asked before.
  #
  # @return [JSON] The JSON response containing the answer to the question.
  def question
    question = Question.find_by(id: params['id'])
    if question
      render json: { id: question.id, answer: question.answer, current_question: question.question }
    else
      render status: 404
    end
  end

  private

  # Returns an array of lucky questions for the specified book.
  #
  # @param book [Book] The book to get the lucky questions from.
  # @return [Array<String>] An array of lucky questions.
  def lucky_questions(book)
    lucky_questions = []
    book.lucky_questions.each do |question|
      lucky_questions << question.question
    end
    lucky_questions
  end
end
