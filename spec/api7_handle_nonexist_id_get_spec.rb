require 'rack/test'
require_relative '../app'
require_relative 'spec_helper'

RSpec.describe 'Test Simple Post and Get happy path' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  describe 'GET id that does exist' do
    it 'handle gracefully' do
      get "#{$DEVICE_READINGS_ENDPOINT}/c758a686-ec3c-48f0-8876-1b8b4b07c426"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({})
    end
  end
end
