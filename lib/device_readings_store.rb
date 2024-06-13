class DeviceReadingsStore
  # Initializes a new store for device readings using a hash.
  def initialize
    @device_readings = {}
  end

  # Adds a reading to the store. Prints a warning for duplicate timestamps.
  # NOTE: First arrival wins. Could add logic to do conditional replace based on
  # first/last timestamp, first arrived or last arrived or min/max count etc.
  def add_reading(id, timestamp, count)
    @device_readings[id] ||= {}
    if @device_readings[id].key?(timestamp)
      puts "Warning: Duplicate record for ID #{id} at timestamp #{timestamp} ignored."
    else
      @device_readings[id][timestamp] = count
    end
  end

  # Returns all readings for a given device ID.
  def get_all_readings_by_id(id)
    @device_readings[id] || {}
  end

  # Calculates the cumulative count and latest timestamp for a device.

  # NOTE: design decision - We retrieve all stored readings for the device aggregate the cumulative count and latest timestamp.
  # This is not as efficient as doing delta updates (to existing cumulative_count and comparing against latest_timestamp),
  # but it's more robust with less chance of summary getting out of sync with stored data. It also leaves open the possibility of
  # implementing some conditional business logic and keeps code simpler.
  # Of course, delta analysis may be necessary depending on the number of readings/device and SLA.
  def calculate_device_summary(id)
    readings_by_id = get_all_readings_by_id(id)
    cumulative_count = readings_by_id.values.sum
    latest_timestamp = readings_by_id.keys.max
    [cumulative_count, latest_timestamp]
  end
end

class DeviceSummaryStore
  # Initializes a new store for device summaries.
  def initialize
    @device_summary = {}
  end

  # Upserts a summary data to the store.
  def update_summary(id, cumulative_count, latest_timestamp)
    @device_summary[id] ||= {}
    @device_summary[id][:cumulative_count] = cumulative_count
    @device_summary[id][:latest_timestamp] = latest_timestamp
  end

  # Retrieves the latest timestamp for a device.
  def get_latest_timestamp(id)
    @device_summary[id][:latest_timestamp] || nil
  end

  # Retrieves the cumulative count for a device.
  def get_cumulative_count(id)
    @device_summary[id][:cumulative_count] || 0
  end

  # Retrieves all summary data for a device.
  def get_summary_data(id)
    @device_summary[id] || {}
  end
end
