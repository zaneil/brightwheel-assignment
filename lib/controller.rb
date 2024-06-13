class ActionsController
  # Updates the summary in the store with cumulative counts and latest timestamp
  def update_summary_in_store(id)
    cumulative_count, latest_timestamp = $device_readings_store.calculate_device_summary(id)
    $device_summary_store.update_summary(id, cumulative_count, latest_timestamp)
  end

  # Adds device readings to the store and updates the summary afterward
  def add_readings_to_store(input_data)
    input_data['readings'].each do |reading|
      # Validate data before adding it to the store
      validate_timestamp(reading['timestamp'])
      validate_integer(reading['count'])
      $device_readings_store.add_reading(input_data['id'], reading['timestamp'], reading['count'])
    end

    # Update the summary readings (cumulative_count, latest_timestamp, etc..) for the device once all readings in the request are added
    
    # Note: design decision - (calculating at get runtime vs updating after post and saving in memory):
    # Currently we are updating summary and storing in memory after successful post.
    # Alternatively, this could be calclated at run time, but that would slow down get requests as readings are added. 
    update_summary_in_store(input_data['id'])
  end

  # Retrieves and formats the device readings summary from the store
  def get_readings_summary_from_store(id, attributes)
    device_summary = $device_summary_store.get_summary_data(id)
    # Optionally filter the response to include only requested attributes
    attributes.empty? ? device_summary : filter_attributes(device_summary, attributes)
  end

  private

  # Validates if the provided timestamp matches the ISO 8601 format
  def validate_timestamp(timestamp)
    pattern = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}\z/
    raise StandardError, 'Invalid timestamp provided.' unless timestamp.match(pattern)

    'Valid timestamp.'
  end

  # Validates if the input is an integer; raises an error if not
  def validate_integer(input)
    Integer(input)
  rescue ArgumentError, TypeError
    raise StandardError, "Invalid input: '#{input}' is not an integer."
  end

  # Filters device summary to include only requested attributes
  def filter_attributes(device_summary, attributes)
    attributes.each_with_object({}) do |attribute, filtered_summary|
      key = attribute.to_sym
      filtered_summary[key] = device_summary[key] if device_summary.key?(key)
    end
  end
end

helpers do
  # Validates the structure and presence of necessary fields in the device reading request
  def validate_post_device_body(request_payload)
    request_json = JSON.parse(request_payload)
    raise 'ID is required' unless request_json.key?('id') && !request_json['id'].empty?

    validate_readings_presence(request_json['readings'])
    request_json
  rescue JSON::ParserError
    raise 'Invalid JSON format'
  end

  # Ensures readings are present and each reading has necessary details
  def validate_readings_presence(readings)
    raise 'Readings are required' unless readings.is_a?(Array) && readings.any?

    readings.each do |reading|
      validate_reading_details(reading)
    end
  end

  # Validates the details of each reading entry
  def validate_reading_details(reading)
    raise 'Each reading must include a timestamp' unless reading.key?('timestamp') && !reading['timestamp'].empty?
    raise 'Each reading must include a count (integer)' unless reading.key?('count') && reading['count'].is_a?(Integer)
  end

  # Validates parameters for the GET request; checks ID and attributes
  def validate_params(params)
    id = validate_uuid(params[:id])
    attributes = parse_attributes(params['attributes'])
    [id, attributes]
  end

  # Validates UUID format
  def validate_uuid(id)
    pattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    raise 'Invalid UUID format' unless id =~ pattern

    id
  end

  # Parses and validates comma-separated attributes
  def parse_attributes(attributes)
    return [] unless attributes

    attrs = attributes.split(',')
    raise 'Attributes must be a comma-separated string' unless attrs.is_a?(Array)

    attrs
  end
end
