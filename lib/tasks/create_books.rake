require 'csv'
require 'openai'

namespace :book do
  desc "Creates a book with the given parameters.

    NOTE: Local paths should be relative to the project's root
    NOTE: image_path should start with / and all other paths should not start with /
    NOTE: If a book with the same title already exists, this task will not create a new book.

    The following parameters are required:

    * title: The title of the book.
    * purchase_link: URL to purchase the book.
    * image_path: Local path to the book's image. (This is relative to the /public folder in askmybook-react app)
    * embeddings_path: Local path to create the book's embeddings CSV file. If a file already exists, it will be overwritten.
    * pages_path: Local path to create the book's pages CSV file. If a file already exists, it will be overwritten.
    * metadata_json_path: Local path for the JSON file which contains the default question, lucky questions, context header, and context QA string. Please check example in storage/first-aid-manual/metadata.json
   
    The following parameter are optional:

    * file_path: Local path to the book's PDF file. Local paths should be relative to the project's root. If file path is not given, the book's embeddings and pages CSV files will be directly taken from their respective paths.

    Example of how to run this task:

    If embeddings need to be generated from PDF file, call the task like below: (Please make sure your OpenAI token is present in env and valid)
    ---------------------------------------------------------------------------
    rake book:create title='First Aid Manual' purchase_link='https://www.indianredcross.org/publications/FA-manual.pdf' file_path='storage/books/first-aid-manual/book.pdf' image_path='/first-aid-manual/book.png' embeddings_path='storage/books/first-aid-manual/embeddings.csv' pages_path='storage/books/first-aid-manual/pages.csv' metadata_json_path='storage/books/first-aid-manual/metadata.json'

    If embeddings are already present, skip setting file_path like below:
    ---------------------------------------------------------------------
    rake book:create title='The Minimalist Entrepreneur' purchase_link='https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397' image_path='/the-minimalist-entrepreneur/book.png' embeddings_path='storage/books/the-minimalist-entrepreneur/embeddings.csv' pages_path='storage/books/the-minimalist-entrepreneur/pages.csv' metadata_json_path='storage/books/the-minimalist-entrepreneur/metadata.json'
    rake book:create title='First Aid Manual' purchase_link='https://www.indianredcross.org/publications/FA-manual.pdf' image_path='/first-aid-manual/book.png' embeddings_path='storage/books/first-aid-manual/embeddings.csv' pages_path='storage/books/first-aid-manual/pages.csv' metadata_json_path='storage/books/first-aid-manual/metadata.json'
    "
  task create: :environment do
    # Validate that all parameters are present.
    if validate_parameters(ENV)

      unless check_book_exist(ENV['title'])
      # Setup OpenAI client.
        client = OpenAI::Client.new(access_token: ENV['OPENAI_KEY'])

        # Generate the pages and embeddings file.
        pdf_file_path = ENV['file_path']
        if !pdf_file_path.nil? && !pdf_file_path.empty? && pdf_file_path.end_with?('.pdf')
          csv_content = create_pages_csv(pdf_file_path, ENV['pages_path'])
          create_embeddings(client, ENV['embeddings_path'], csv_content)
        end

        default_question, lucky_questions, context_header, context_qa = parse_qa_json(ENV['metadata_json_path'])

        # Create a new book and store it in the database.
        book = Book.create(
          title: ENV['title'],
          purchase_link: ENV['purchase_link'],
          file_path: ENV['file_path'],
          image_path: ENV['image_path'],
          embeddings_path: ENV['embeddings_path'],
          pages_path: ENV['pages_path'],
          default_question:,
          context_header:,
          context_qa:
        )

        # Create the lucky questions and store them in the database.
        lucky_questions.each do |question|
          book.lucky_questions.create(question:)
        end
      end
    end
  end
end

private

def validate_parameters(params)
  keys = %w[title purchase_link image_path embeddings_path pages_path metadata_json_path]
  keys.each do |key|
    if params[key].nil? || params[key].empty?
      puts "#{key} parameter should not be empty."
      return false
    end
  end
  true
end

def check_book_exist(title)
  book = Book.find_by(title: title)
  if book.nil?
    return false
  end
  puts "Book with title: #{title} already exist."
  true
end

# Helper function to parse the JSON file and return the default question, lucky questions, context header, and QA string.
def parse_qa_json(file)
  puts("Parsing JSON file: #{file}")
  json = JSON.parse(File.read(file))
  qa_string = ''
  json['context_qa'].each do |qa|
    qa_string.concat("Question: #{qa['question']}\nAnswer: #{qa['answer']}\n\n")
  end
  [json['default_question'], json['lucky_questions'], json['context_header'], qa_string]
end

# Helper function to generate the pages.csv file for a PDF file
def create_pages_csv(pdf_file, csv_file)
  puts("Creating pages file: #{csv_file} from pdf file: #{pdf_file}")
  reader = PDF::Reader.new(pdf_file)
  csv_content = [%w[title content tokens]]

  tokenizer = Tokenizers.from_pretrained('gpt2')

  reader.pages.each do |page|
    # Clean whitespace from the text.
    text = page.text.gsub(/\s+/, ' ')
    # Count the total number of tokens.
    token_count = tokenizer.encode(text).tokens.length
    # Append to the csv content
    csv_content << ["Page #{page.number}", text, token_count]
  end

  # Create the csv file
  CSV.open(csv_file, 'w') do |csv|
    csv_content.each do |content|
      csv << content
    end
  end

  puts("Finished creating #{csv_file}")
  csv_content
end

# Helper function to create embeddings from the pages.csv data
def create_embeddings(client, file, csv_content)
  puts("Creating embeddings file: #{file}")
  embedding_content = []

  # Create title row
  title_row = ['title']
  4096.times do |i|
    title_row << "#{i}"
  end

  embedding_content << title_row

  # Drop the first row and add embeddings for each page.
  csv_content.drop(1).each do |content|
    row = [content[0]]

    # Send OpenAI request to create the embeddings
    response = client.embeddings(
      parameters: {
        model: 'text-search-curie-doc-001',
        input: content[1]
      }
    )
    embeddings = response.dig('data', 0, 'embedding')

    puts("Fetched #{embeddings.length} embeddings for #{row}")

    # Store the embeddings in the row
    embeddings&.each do |embedding|
      row << embedding
    end

    # Add the row to the content
    embedding_content << row
  end

  # Create the csv file
  CSV.open(file, 'w') do |csv|
    embedding_content.each do |content|
      csv << content
    end
  end

  puts("Finished creating #{file}")
  embedding_content
end
