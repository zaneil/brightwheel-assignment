# API Documentation for Device Reading  Endpoint

This document provides detailed information about the API interactions available for the Reading Device Endpoint. Below you will find the methods supported, required parameters, sample requests, and responses.


## POST /api/v1/device-readings

Adds new device readings to the store and updates summary attributes.

### Parameters

- **`id`** (required): A string representing the UUID for the device.
- **`readings`** (required): an array of readings for the device
  - **`timestamp`** (required): an ISO-8061 timestamp for when the reading was taken
  - **`count`** (required): an integer representing the reading data
 

### Sample Request

```
curl -X POST http://localhost:8080/api/v1/device-readings -H "Content-Type: application/json" -d '{ "id": "36d5658a-6908-479e-887e-a949ec199272", "readings": [{ "timestamp": "2021-09-29T16:08:15+01:00", "count": 2 }, { "timestamp": "2021-09-29T16:09:15+01:00", "count": 15 } ] }'
```
- ### Sample Response
```
{"status":"success"}
```

## GET /api/v1/device-readings/:id

Returns summary reading data for a device

### Parameters

- **`id`** (required): A string representing the UUID for the device.
### Query Parameters

- **`attributes`** (optional): A csv string of attributes to include in the response
  - **values**: cumulative_count,latest_timestamp
  - **default**: returns both cumulative_count, latest_timestamp

### Sample Requests - cumulative_count

```
curl -X GET "http://localhost:8080/api/v1/device-readings/36d5658a-6908-479e-887e-a949ec199272?attributes=cumulative_count"

```
- ### Sample Response
```
{"cumulative_count":17}
```

### Sample Requests - latest_timestamp

```
curl -X GET "http://localhost:8080/api/v1/device-readings/36d5658a-6908-479e-887e-a949ec199272?attributes=latest_timestamp"

```
- ### Sample Response
```
{"latest_timestamp":"2021-09-29T16:09:15+01:00"}
```