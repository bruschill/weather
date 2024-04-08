### Weather App
#### System requirements
- `Ruby 3.3.0`
- `Redis v7.2.4`
    - using [Homebrew](https://brew.sh/), `brew install redis` should do the trick

#### Install dependencies
1. `bundle`
2. `yarn`
3. `gem install foreman`

#### Running the project
- `foreman start`

#### Server address
- `localhost:3000`

#### Running tests
- `bin/rails test`

#### Troubleshooting
- Redis
  - if you installed redis via a different path than Homebrew, you'll have to check `config/environments/development.rb:23` and change the URL to match your machine
  - if you have Redis server automatically start on boot, you'll have to remove the `redis: ...` process from `Procfile`
