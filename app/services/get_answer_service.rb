require 'cosine_similarity'
require 'csv'
require 'json'

class GetAnswerService
  COMPLETIONS_MODEL = 'text-davinci-003'.freeze
  MODEL_NAME = 'curie'
  DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001".freeze
  QUERY_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-query-001".freeze
  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* ".freeze
  SEPRATOR_LEN = 3
  QUESTIONS_SEPERATOR = "\n\n\nQ: ".freeze
  ANSWER_SEPERATOR = "\n\nA: ".freeze

  def self.call(book, question)
    data = File.read(Rails.root.join(book.pages_path))
    book_pages = CSV.parse(data, headers: true).map(&:to_h)
    embeddings = load_embeddings(Rails.root.join(book.embeddings_path))
    prompt, context = construct_prompt(book, question, embeddings, book_pages)
    return unless prompt

    response = OPEN_AI_CLIENT.completions(
      parameters: {
        prompt: prompt,
        temperature: 0.0,
        max_tokens: 150,
        model: COMPLETIONS_MODEL
      }
    )
    [response['choices'][0]['text'].strip, context]
  end

  private

  def self.load_embeddings(file_path)
    embeddings = {}
    CSV.foreach(file_path, headers: false) do |row|
      embeddings[row[0]] = row[1..].map(&:to_f) if row[0] != 'title'
    end
    embeddings
  end

  def self.order_document_sections_by_query_similarity(query, contexts)
    query_embedding = get_embedding(query, QUERY_EMBEDDINGS_MODEL)
    return unless query_embedding

    contexts.map do |doc_index, doc_embedding|
      similarity = cosine_similarity(query_embedding, doc_embedding)
      [similarity, doc_index]
    end.sort.reverse
  end

  def self.get_embedding(text, model)
    response = OPEN_AI_CLIENT.embeddings(parameters: { model: model, input: text })
    return unless response['data']

    response['data'][0]['embedding']
  end

  def self.construct_prompt(book, question, context_embeddings, book_pages)
    most_relevant_document_sections = order_document_sections_by_query_similarity(question, context_embeddings)
    return unless most_relevant_document_sections

    chosen_sections = filter_chosen_sections(most_relevant_document_sections, book_pages)
    [book.context_header + chosen_sections.join('') + book.context_qa + "\n\n\nQ: " + question + "\n\nA: ",
     chosen_sections.join('')]
  end

  def self.filter_chosen_sections(most_relevant_document_sections, book_pages)
    chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []
    most_relevant_document_sections.each do |_, section_index|
      document_section = book_pages.find { |row| row['title'] == section_index }
      chosen_sections_len += document_section['tokens'].to_i + SEPRATOR_LEN
      if chosen_sections_len > MAX_SECTION_LEN
        space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.length
        chosen_sections.append(SEPARATOR + document_section['content'][0..space_left])
        chosen_sections_indexes.append(section_index.to_s)
        break
      end
      chosen_sections.append(SEPARATOR + document_section['content'])
      chosen_sections_indexes.append(section_index.to_s)
    end
    chosen_sections
  end
end
