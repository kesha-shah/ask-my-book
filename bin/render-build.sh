#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install

rm -rf public
npm install --prefix client && npm run build --prefix client

bundle exec rake db:migrate
bundle exec rake book:create title='First Aid Manual' purchase_link='https://www.indianredcross.org/publications/FA-manual.pdf' image_path='/first-aid-manual/book.png' embeddings_path='storage/books/first-aid-manual/embeddings.csv' pages_path='storage/books/first-aid-manual/pages.csv' metadata_json_path='storage/books/first-aid-manual/metadata.json'

cp -a client/build/. public/