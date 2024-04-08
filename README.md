### Weather App
#### System requirements
- `Ruby 3.3.0`
- `Redis v7.2.4`
    - using [Homebrew](https://brew.sh/), `brew install redis`

#### Install dependencies
1. `bundle`
2. `yarn`
3. `gem install foreman`
4. put provided `master.key` in `./config`

#### Running the project
- `foreman start`

#### Server address
- `localhost:3000`

#### Running tests
- `bin/rails test`

#### Running linters
- `yarn lint`, which runs 
    - `yarn run eslint app/javascript/packs --fix`
    - `rake standard:fix`

#### Troubleshooting
- Redis
  - if you installed redis via a different path than Homebrew, you'll have to check `config/environments/development.rb:23` and change the URL to match your machine
  - if you have Redis server automatically start on boot, you'll have to remove the `redis: ...` process from `Procfile`
