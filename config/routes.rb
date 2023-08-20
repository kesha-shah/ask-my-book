# frozen_string_literal: true

Rails.application.routes.draw do
  get '/book', to: 'books#get'
  get '/book/question/:id', to: 'books#question'
  post '/book/ask', to: 'books#ask'
  get "*path", to: "fallback#index", constraints: ->(req) { !req.xhr? && req.format.html? }

end
