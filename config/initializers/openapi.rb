require 'openai'

# Initialize the OpenAI client
OpenAI.configure do |config|
  config.access_token = ENV['OPENAI_KEY']
end

# Store the client in a global variable
OPEN_AI_CLIENT = OpenAI::Client.new