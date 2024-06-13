require 'rack/test'
require_relative '../app'
require_relative 'spec_helper'

RSpec.describe 'Test Single Out of Order Readings Post' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  describe '- single POST with out of order readings' do
    let(:post_data) do
      {
        id: '5b8dec52-f673-4ff3-b804-169eab080b61',
        readings: [
          {
            timestamp: '2023-10-29T13:08:15+01:00',
            count: 5
          },
          {
            timestamp: '2023-10-29T13:09:15+01:00',
            count: 1
          },
          {
            timestamp: '2023-10-29T13:07:15+01:00',
            count: 3
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

  describe 'GET device reading' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/5b8dec52-f673-4ff3-b804-169eab080b61"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 9, 'latest_timestamp' => '2023-10-29T13:09:15+01:00' })
    end
  end
end
