require 'rack/test'
require_relative '../app'
require_relative 'spec_helper'

RSpec.describe 'Test Simple Post and Get happy path' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  describe '- check that single POST to device-readings returns success' do
    let(:post_data) do
      {
        id: '623e8ab6-e377-463b-b8f8-5a1e6b5a8acc',
        readings: [
          {
            timestamp: '2021-09-29T16:08:15+01:00',
            count: 2
          },
          {
            timestamp: '2021-09-29T16:09:15+01:00',
            count: 15
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

  describe 'GET device reading both attributes' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/623e8ab6-e377-463b-b8f8-5a1e6b5a8acc"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 17, 'latest_timestamp' => '2021-09-29T16:09:15+01:00' })
    end
  end
  describe 'GET device reading cumulative_count only' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/623e8ab6-e377-463b-b8f8-5a1e6b5a8acc?attributes=cumulative_count"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 17 })
    end
  end
  describe 'GET device reading latest_timestamp only' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/623e8ab6-e377-463b-b8f8-5a1e6b5a8acc?attributes=latest_timestamp"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'latest_timestamp' => '2021-09-29T16:09:15+01:00' })
    end
  end
end
