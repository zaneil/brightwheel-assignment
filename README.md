# Intro
## Choice of programming language/frameworks
### This is my first Ruby code (zero prior knowledge)
This is my first exposure to Ruby, as such it took closer to 10 hours. I decided to use Ruby instead of Python/Django (my comfort zone) since Brightwheel uses Rails and learning new languages is fun!

I used a lightweight, less popular library (sinatra) instead of Ruby on Rails.  Although I'm aware that Ruby on Rails is a comprehensive framework, I chose to a smaller implementation to focus initially on mastering the fundamentals and make efficient use of my learning time. I have Python/Django/Flask expertise, which should shorten the learning curve for Rails. 

Since this is my first time coding in Ruby, there might be some areas where I'm not following Ruby's best practices or naming conventions perfectly. I'm here to learn and improve, so I'd really appreciate any feedback or advice you can give me.

## Design Decisions
Unit Tests vs API integration tests
For this small project I chose to write API integration tests. I know unit tests are important, but I think in fast paced startups it is more efficient to write integration tests.  Writing tests are easy, but maintaining them is more challenging. Integration tests provide less testing. Of course for larger projects, a mix of unit tests and integration tests are both imporant. 


# How to run locally

## Prequisites
- Ruby (3.2.2 recommended)
  - Download and install from https://www.ruby-lang.org/en/downloads/releases/
- Bundler (2.5.11 recommended)

## Option 2: Clone Repo
`git clone https://github.com/zaneil/brightwheel-assignment.git`

## 2a)Local Setup (Mac)
### Open Terminal on your Mac
### Navigate to brightwheel-assignment
`cd <your_directory_path>/brightwheel-assignment`
### Install Gem dependencies
- `bundle install`

### Run tests
`bundle exec rspec`
should out something like...
```
Finished in 0.01959 seconds (files took 0.22066 seconds to load)
20 examples, 0 failures
```

### Start server
  `bundle exec ruby app.rb`

should output something like... 
```
[2024-06-13 14:17:10] INFO  WEBrick 1.8.1
[2024-06-13 14:17:10] INFO  ruby 3.3.2 (2024-05-30) [x86_64-darwin22]
== Sinatra (v4.0.0) has taken the stage on  for development with backup from WEBrick
[2024-06-13 14:17:10] INFO  WEBrick::HTTPServer#start: pid=69920 port=8080
```

#### Check server is running
Open a new terminal and run
`curl -X GET http://localhost:8080`
should output... 
```
Server Running
```


# API Documentation
See DOCUMENTATION.md file


# Project Structure
- app.rb contains endpoints and routing
- lib/controller.rb handles validations and calling the data model/store
- lib/device_readings_store.rb contains models DeviceReadingsStore + and DeviceSummaryStore
- spec/ directory contains tests


# Design Decisions and System Limiations

## Data not persisted / lost on server stop
- **Requirement**: "No data can be persisted to disk and must be stored in memory."
- **Issue** Current implmentation does not save data anywhere so data is lost when server goes down.
- **Possible Solutions for future**
  - 1) ability to backup data at some interval somewhere (s3 or the like if cant be stored to disk) and load from there
    2) log data as it comes in to s3 or similar.
    3) Add a database somewhere
- **Note** For now I considered this out of scope of this exercise.

## Custom Datastore instead of SQLite
- I wrote in memory datastore intead of using in memory SQL lite in order to learn Ruby better. if i had used sql light i could ihave still persisted in memory and it would have given the option to add an external SQL db in the future. 

## Handling Duplicate Timestamps: First Arrival Wins
- "There may also be duplicate readings for a given timestamp. Any duplicate readings can be ignored." 
- I interpreted this to mean first arrived wins, but in reality it depends on how device readings work 
- Could add logic to do conditional replace based on first/last timestamp, first arrived or last arrived or min/max count etc.

## Calculating Device Summary Values After post and saving in memory (instead of calcualting at run time):
  - Currently we are updating summary and storing in memory after successful post.
  - Alternatively, this could be calclated at run time, but that would slow down get requests as readings are added. 

## Calculating Summary Values after post (instead of at run time)
- We retrieve all stored readings for the device aggregate the cumulative count and latest timestamp. This is not as efficient as doing delta updates (to existing cumulative_count and comparing against latest_timestamp),
- it's more robust with less chance of summary getting out of sync with stored data. It also leaves open the possibility of implementing some conditional business logic and keeps code simpler. Of course, delta analysis may be necessary depending on the number of readings/device and SLA.

## Potential Race Condition 
- Since device readings can be sent out of order there is a race condition which is possible.
- Example: Assume, a reading is taken at t1 for device1 and sent, then another reading is taken at time t2 for the same device and then sent separately.
- If events occur like this...
  - POST device reading a (id2, count2, t2)
  - GET (id1) returns latest time of t2 and cumulative_count of count1 
  - POST device reading a (id1, count1, t1)
  - GET (id1) returns latest time of t2 and cumulative_count of count1+count2 
- If the second reading is arrives/is processed first, then a consumer polls the GET it will show latest_timestamp of t2 but only include the second device reading.
- This edge case may be a non issue, but depends on how the device GET is being used and likelihood of this occuring and mattering. 

# Future Improvements
- Add logging
- ENV variables + parameterize for production/staging envs
- dockerize
- Add Makefile for easy setup/running/tests etc...
- Add auth for security considerations
- Post response should include summary readings in response?
- Post response should warn of duplicate reading being ignored
- Test suite is hacky (lots of duplicate code)
- Better error handling and validation
