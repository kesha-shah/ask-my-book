require 'test_helper'

class LuckyQuestionTest < ActiveSupport::TestCase
  def valid_lucky_question
    LuckyQuestion.new(question: 'question', book: Book.first)
  end

  test 'should be valid' do
    assert valid_lucky_question.valid?
  end

  test 'question should be present' do
    lucky_question = valid_lucky_question
    lucky_question.question = nil
    assert_not lucky_question.valid?
    assert lucky_question.errors.full_messages == ["Question can't be blank"]
  end

  test 'question should not be more than 140 characters' do
    lucky_question = valid_lucky_question
    lucky_question.question = 'a' * 141
    assert_not lucky_question.valid?
    assert lucky_question.errors.full_messages == ['Question is too long (maximum is 140 characters)']
  end

  test 'question must be associated with a book' do
    lucky_question = valid_lucky_question
    lucky_question.book = nil
    assert_not lucky_question.valid?
    assert lucky_question.errors.full_messages == ['Book must exist']
  end
end
