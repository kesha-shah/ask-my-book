#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install

rm -rf public
npm install --prefix client && npm run build --prefix client

bundle exec rake db:migrate
bundle exec rake book:create title='The Minimalist Entrepreneur' purchase_link='https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397' image_path='/the-minimalist-entrepreneur/book.png' embeddings_path='storage/books/the-minimalist-entrepreneur/embeddings.csv' pages_path='storage/books/the-minimalist-entrepreneur/pages.csv' metadata_json_path='storage/books/the-minimalist-entrepreneur/metadata.json'

cp -a client/build/. public/