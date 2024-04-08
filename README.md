# Weather App
## Setup
### System requirements
- `Ruby 3.3.0`
- `Redis v7.2.4`
    - using [Homebrew](https://brew.sh/), `brew install redis`

### Install dependencies
1. `bundle`
2. `yarn`
3. `gem install foreman`
4. put provided `master.key` in `./config`

### Running the project
- `foreman start`

### Server address
- `localhost:3000`

### Running tests
- `bin/rails test`

### Running linters
- `yarn lint`, which runs 
    - `yarn run eslint app/javascript/packs --fix`
    - `rake standard:fix`

### Troubleshooting
- Redis
  - if you installed redis via a different path than Homebrew, you'll have to check `config/environments/development.rb:23` and change the URL to match your machine
  - if you have Redis server automatically start on boot, you'll have to remove the `redis: ...` process from `Procfile`

## Addendum
### Assumptions
- at minimum, user must provide a 5-digit postal code
- app will be run in production, but there are no environments for it yet

### Implementation details
- if fetched data is was retrieved from cache, an * will appear next to the 'My Location' header text
- temperature units toggleable (see Bugs section)

### Decisions
- Rails 6
  - the job description mentioned using Rails 5/6
- Redis - chosen because out of the box, it has:
  - write data to flat file on failure/shut down
  - read data from flat file on boot
  - clustering
  - fastest for small data sets

### Future Work
- front-end tests
  - had issues setting up `jest`, need to explore modern approaches
- logging
  - at the very least, log when requests to open weather api fail for any reason
- turn weather responses into Ruby objects, i.e. `class Day` for forecast day, which would make data validation easier/clearer
  - makes more specific unit testing easier
- make `OpenWeatherMap::API, ...` methods have input validation
- add styles

### Bugs
- loading spinner isn't displaying w/ state change
- entering a valid postal code, having the response render, toggling the unit toggle, then attempting to enter a new postal code results in blank screen
  - this is due state (from AppState.jsx) getting lost
  - front-end tests would have greatly prevented the lost time spent debugging this
- entering a valid postal code, having the response render, then entering text that is not a valid postal code displays error while still displaying original request's weather
