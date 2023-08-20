# frozen_string_literal: true

require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  test 'GET /book returns a successful response' do
    get '/book'
    assert_response :success
  end

  test 'GET /book returns JSON with current question, lucky questions, purchase link, and image path' do
    get '/book'
    assert_equal 'application/json; charset=utf-8', @response.content_type
    body = JSON.parse(@response.body)
    assert_includes body, 'current_question'
    assert_includes body, 'lucky_questions'
    assert_includes body, 'purchase_link'
    assert_includes body, 'image_path'
  end

  test 'POST /book/ask returns a successful response when the question exists in the database' do
    question = Question.create(question: 'What is the meaning of life?', answer:'42', ask_count: 1, context:'', book_id: Book.instance.id)
    post '/book/ask', params: { question: 'What is the meaning of life?' }
    assert_response :success
    assert_equal 'application/json; charset=utf-8', @response.content_type
    body = JSON.parse(@response.body)
    assert_includes body, 'id'
    assert_includes body, 'answer'
    assert_includes body, 'current_question'
    assert_equal '42', JSON.parse(@response.body)['answer']
    assert_equal 2, question.reload.ask_count
  end

  test 'POST /book/ask returns a successful response and creates a new question in the database when the question does not exist' do
    GetAnswerService.stub :call, ['42', ''] do
      post '/book/ask', params: { question: 'What is the real meaning of life?' }
      assert_response :success
      assert_equal 'application/json; charset=utf-8', @response.content_type
      body = JSON.parse(@response.body)
      assert_includes body, 'id'
      assert_includes body, 'answer'
      assert_includes body, 'current_question'
      assert_equal '42', JSON.parse(@response.body)['answer']
      question = Question.find_by(question: 'What is the real meaning of life?')
      assert_equal 1, question.ask_count
    end 
  end

  test 'POST /book/ask returns a 200 status code and an error message when there is an error getting the answer' do
    GetAnswerService.stub :call, [nil, nil] do
        post '/book/ask', params: { question: 'What is the real meaning of life?' }
        assert_response :success
        assert_equal 'application/json; charset=utf-8', @response.content_type
        body = JSON.parse(@response.body)
        assert_includes body, 'id'
        assert_includes body, 'answer'
        assert_includes body, 'current_question'
        assert_equal 'There was a problem answering the question. Please make sure you have setup the Open AI API key correctly.', body['answer']
    end
  end

  test 'GET /book/question returns a successful response and the answer to the question when the question exists in the database' do
    question = Question.create(question: 'What is the meaning of life?', answer:'42', ask_count: 1, context:'', book_id: Book.instance.id)
    get "/book/question/#{question.id}"
    assert_response :success
    assert_equal 'application/json; charset=utf-8', @response.content_type
    body = JSON.parse(@response.body)
    assert_includes body, 'id'
    assert_includes body, 'answer'
    assert_includes body, 'current_question'
    assert_equal '42', body['answer']
  end

  test 'GET /book/question returns a 404 status code when the question does not exist in the database' do
    get '/book/question/-1'
    assert_response 404
  end
end