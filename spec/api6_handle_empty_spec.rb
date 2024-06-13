require 'rack/test'
require_relative '../app'
require_relative 'spec_helper'

RSpec.describe 'Test Empty Post Json returns 400' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  describe '- check that empty post returns 400' do
    let(:post_data) do
      {}.to_json
    end

    it 'Post returns 400' do
      post "#{$DEVICE_READINGS_ENDPOINT}", post_data, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
    end
  end

  describe 'GET device reading without id' do
    it 'returns 400' do
      get "#{$DEVICE_READINGS_ENDPOINT}/"
      expect(last_response.status).to eq(404)
    end
  end
end
