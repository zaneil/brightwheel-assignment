require 'sinatra'
require 'json'
require_relative 'lib/device_readings_store'
require_relative 'lib/controller'

set :bind, '0.0.0.0'
set :port, ENV['PORT']

# Route to confirm the server is running
get '/' do
  'Server Running'
end

# Initialize global variables for device stores and controller
$device_readings_store = DeviceReadingsStore.new
$device_summary_store = DeviceSummaryStore.new
$controller = ActionsController.new

# POST endpoint to add device readings
post '/api/v1/device-readings' do
  content_type :json
  request_data = request.body.read
  begin
    # Validate and parse the incoming JSON body
    request_json = validate_post_device_body(request_data)
    # Add readings to the store
    $controller.add_readings_to_store(request_json)
    # Return success status if no errors
    # NOTE: may want to return updated cumulative_count and latest_timestamp readings added to this response
    { status: 'success' }.to_json
  rescue StandardError => e
    # Respond with error message if validation fails
    halt 400, { error: e.message }.to_json
  end
end

# GET endpoint to retrieve device readings by ID
# optional attributes query parameter (comma separated string)
get '/api/v1/device-readings/:id' do
  content_type :json

  begin
    # Validate parameters and extract ID and attributes
    id, attributes = validate_params(params)
    # retrieve readings from store
    $controller.get_readings_summary_from_store(id, attributes).to_json
  rescue StandardError => e
    # Respond with error message if validation fails
    halt 400, { error: e.message }.to_json
  end
end

