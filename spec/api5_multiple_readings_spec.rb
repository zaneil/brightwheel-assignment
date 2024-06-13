require 'rack/test'
require_relative '../app'
require_relative 'spec_helper'

$id = 'e24a1f5d-8d4e-4a64-9a91-01276b5d25a1'

RSpec.describe 'Test multiple readings posted (including out of order and duplicates)' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  describe '- first POST' do
    let(:post_data) do
      {
        id: $id,
        readings: [
          {
            timestamp: '2023-10-29T13:08:15+09:00',
            count: 3
          },
          {
            timestamp: '2023-10-29T13:09:15+09:00',
            count: 12
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

  describe 'GET device reading after first reading set sent' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/#{$id}"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 15, 'latest_timestamp' => '2023-10-29T13:09:15+09:00' })
    end
  end

  describe '- second Post' do
    let(:post_data) do
      {
        id: $id,
        readings: [
          {
            timestamp: '2023-10-29T14:08:15+09:00',
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

  describe 'GET device reading after second reading set sent' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/#{$id}"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 16, 'latest_timestamp' => '2023-10-29T14:08:15+09:00' })
    end
  end
  describe '- third Post (out of order reading' do
    let(:post_data) do
      {
        id: $id,
        readings: [
          {
            timestamp: '2023-10-29T12:08:15+09:00',
            count: 100
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

  describe 'GET after third reading set sent' do
    it 'returns correct summary' do
      get "#{$DEVICE_READINGS_ENDPOINT}/#{$id}"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 116, 'latest_timestamp' => '2023-10-29T14:08:15+09:00' })
    end
  end
  describe '- fourth Post (duplicate reading)' do
    let(:post_data) do
      {
        id: $id,
        readings: [
          {
            timestamp: '2023-10-29T12:08:15+09:00',
            count: 100
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

  describe 'GET after fourth reading (duplicate' do
    it 'no changes (duplicate ' do
      get "#{$DEVICE_READINGS_ENDPOINT}/#{$id}"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)
      expect(parsed_response).to eq({ 'cumulative_count' => 116, 'latest_timestamp' => '2023-10-29T14:08:15+09:00' })
    end
  end
end
