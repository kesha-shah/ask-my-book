require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  def valid_question
    Question.new(question: 'question', context: 'context', answer: 'answer', book: Book.first)
  end

  test 'should be valid' do
    assert valid_question.valid?
  end

  test 'question should be present' do
    question = valid_question
    question.question = nil
    assert_not question.valid?
    assert question.errors.full_messages == ["Question can't be blank"]
  end

  test 'question should not be more than 140 characters' do
    question = valid_question
    question.question = 'a' * 141
    assert_not question.valid?
    assert question.errors.full_messages == ['Question is too long (maximum is 140 characters)']
  end

  test 'context and answer can be blank' do
    question = valid_question
    question.context = nil
    question.answer = nil
    assert question.valid?
  end

  test 'question must be associated with a book' do
    question = valid_question
    question.book = nil
    assert_not question.valid?
    assert question.errors.full_messages == ['Book must exist']
  end
end
