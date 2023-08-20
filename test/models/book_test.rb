require 'test_helper'

class BookTest < ActiveSupport::TestCase
  def valid_book
    Book.new(title: 'title', purchase_link: 'purchase_link', file_path: 'file_path',
             image_path: 'image_path', embeddings_path: 'embeddings_path', pages_path: 'pages_path',
             default_question: 'default_question', context_header: 'context_header', context_qa: 'context_qa')
  end

  test 'should be valid' do
    assert valid_book.valid?
  end

  test 'title should be present' do
    book = valid_book
    book.title = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Title can't be blank"]
  end

  test 'title should be less than 100 characters' do
    book = valid_book
    book.title = 'a' * 101
    assert_not book.valid?
    assert book.errors.full_messages == ['Title is too long (maximum is 100 characters)']
  end

  test 'purchase_link should be present' do
    book = valid_book
    book.purchase_link = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Purchase link can't be blank"]
  end

  test 'file_path is optional' do
    book = valid_book
    book.file_path = nil
    assert book.valid?
  end

  test 'image_path should be present' do
    book = valid_book
    book.image_path = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Image path can't be blank"]
  end

  test 'embeddings_path should be present' do
    book = valid_book
    book.embeddings_path = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Embeddings path can't be blank"]
  end

  test 'pages_path should be present' do
    book = valid_book
    book.pages_path = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Pages path can't be blank"]
  end

  test 'default_question should be present' do
    book = valid_book
    book.default_question = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Default question can't be blank"]
  end

  test 'context_header should be present' do
    book = valid_book
    book.context_header = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Context header can't be blank"]
  end

  test 'context_qa should be present' do
    book = valid_book
    book.context_qa = nil
    assert_not book.valid?
    assert book.errors.full_messages == ["Context qa can't be blank"]
  end
end
