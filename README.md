# README

## Summary: Ask My Book

Ask My Book is a web application that uses generative AI to allow users to ask questions to a book. The app is made using Ruby on Rails as a backend and has a React frontend.

[Live Demo](https://ask-my-book-q1d7.onrender.com/) (Note: Only cached questions would work if my free OpenAI Tokens have expired and also response time might be higher as I am using Render free hosting with only 0.1CPU and 512MB ram)

## Pre-requisites

To run this app, you will need the following:

1. Ruby 3.2.2 or higher. Check using `ruby --version`.
2. Rails 7.0.7 or higher. Check using `rails --version`.
3. Node 18.17.0 or higher. Check using `node --version`.

## Setup

To set up the app, follow these steps:

### Backend setup:

1. Clone the repository and navigate to the project directory.
2. In your terminal, set the `OPENAI_KEY` environment variable to your Open AI API key. For example, `export OPENAI_KEY=<your_key_here>`.
3. Install backend dependencies using `bundle install`.
4. Create the `books_development` and `books_test` database in Postgres. If running locally, you can use the `rails db:create` command.
5. Migrate the database using `rails db:migrate`.
6. Go to `config/application.rb` and replace `open_api_secret` with your Open AI API key.
7. To setup the database with in-built books, follow the instructions in the [comments](https://github.com/kesha-shah/ask-my-book/blob/main/lib/tasks/create_books.rake) in `lib/tasks/create_books.rake`.
8. Please make sure in `config/application.rb`, the `book_title` is equal to the title of the book you want to use. Make sure that you have performed the setup for the book as described in step 5.

### Frontend setup:

1. Install frontend dependencies using `cd askmybook-react && npm install`.

## Running

1. To run the Rails backend, run the following command from the project root: `rails s`. The backend will be available at http://localhost:3000.
2. To run the React frontend, run the following command from `/askmybook-react`: `npm start`. The frontend will be available at http://localhost:3001.

## Adding a new book

To add a new book, follow these steps:

1. Create a new book folder under `/storage/books`, and copy the PDF file there.
2. Create a new file in the same folder called `metadata.json`, and fill it with a list of default questions and contextual questions. These are used for context when asking OpenAI. See the example in `/storage/books/the-minimalist-entrepreneur/metadata.json` for reference.
3. Add the book's cover image to the `askmybook-react/public` directory after creating a new folder for the book.
4. Follow the instructions in the comments in `lib/tasks/create_books.rake`. In this case, embeddings will need to be generated, so see the relevant example. This is to load the book's details in the database.
5. To actually use the book in the app, change the `book_title` in `config/application.rb` to the title of the new book.
6. Restart the backend server.

## Testing

To run backend tests including model and controller, run `rails test` from the project root.

## Implementation details and architecture decisions

- AskMyBook project is originally created by [Sahil Lavingia](https://github.com/slavingia/askmybook)
 using python, django and Heroku. This is an implementation of same code using React, Rails and deployed on Render.

### Database Design 

The main goal of this project was that it should be very simple to integrate a new book for asking questions. 
Adding a new book will persist metadata so that it is easy to switch between books when needed. 

There are 3 tables created to store book and question related data:

* `books` - Stores all metadata of books including its image path, embedding path, pages path and other fields which are described later.
* `lucky_questions` - Stores lucky questions for each book which can be used when you click "I am feeling lucky" button.
* `questions` - Stores all previously asked questions and is used as a cache in app.

### Adding a new book (implementation)

For any new book, there are few things which we require to render UI page and call OpenAI APIs:

1. Original Book PDF - This is used to create embeddings file.
2. Embeddings file - This file contains the embeddings which are returned by OpenAI. They are used to match the most relevant section of the book which can be given as context when asking further questions.
3. Pages file - Stores the text from each page as a separate entry along with the number of tokens.
4. Book Image - To show it on UI.
5. Context - These are predefined questions and answers to give OpenAI context before asking the actual question.
6. Purchase Link - Link to purchase the book, when user clicks on the book image.
7. Lucky Questions - Used when user clicks on the "I am feeling Lucky" button.
8. Default Question - Shown on index page in the textbox by default.

Context, default question and lucky questions need to be added in a json file like [here](https://github.com/kesha-shah/ask-my-book/blob/main/storage/books/the-minimalist-entrepreneur/metadata.json)

In `create_books.rake` task we create the embeddings and pages file internally and store it in the paths given in parameters. For now, local paths are used; but in the future it would be better to use cloud storage i.e. store it in S3 and retrieve it from there. After creating all necessary files, it will eventually store all these metadata in `books` table and `lucky_questions` table.

For now, the current application works with only one book which you can configure by setting the `book_title` in `application.rb` config file.
On application startup it will retrive that book metadata in memory and use it for all API calls. 
If you have multiple books and you want to change the book, then you just need to change `book_title` and it should start working. 

As future improvement, we can also change this and create an API where you give `book_title` and it will render your new UI with given book without requiring a restart.

## Learnings

This is my first React + Rails App hands on experience!! I literally learnt React and Rails from scratch 😀
Any suggestions are more than welcome! 
