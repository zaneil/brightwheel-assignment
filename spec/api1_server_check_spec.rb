require 'rack/test'
require_relative '../app'

RSpec.describe 'Check that server is up and running' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'check server running' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Server Running')
  end
end
