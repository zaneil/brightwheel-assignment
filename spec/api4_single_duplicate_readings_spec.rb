require 'rack/test'
require_relative '../app'
require_relative 'spec_helper'

RSpec.describe 'Test Single Post with duplicate readings' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  describe '- single POST with duplicate readings' do
    let(:post_data) do
      {
        id: '7b9a1a8b-7722-4d6f-93f8-97e3b6e56fc6',
        readings: [
          {
            timestamp: '2023-10-29T13:08:15+01:00',
            count: 5
          },
          {
            timestamp: '2023-10-29T13:08:15+01:00',
            count: 1
          }
        ]
      }.to_json
    end

    it 'Post returns success' do
      post "#{$DEVICE_READINGS_ENDPOINT}", post_data, { 'CONTENT_TYPE' => 'application/json' }
      parsed_response = JSON.parse(last_response.body) # Parse the JSON string response into a Ruby hash
      expect(last_response.status).to eq(200)
      expect(parsed_response).to eq({ 'status' => 'success' }) # Now comparing hash to hash
    end
  end

  describe 'GET device reading first wins' do
    it 'ignores the duplicate time stamp' do
      get "#{$DEVICE_READINGS_ENDPOINT}/7b9a1a8b-7722-4d6f-93f8-97e3b6e56fc6"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 5, 'latest_timestamp' => '2023-10-29T13:08:15+01:00' })
    end
  end
end
