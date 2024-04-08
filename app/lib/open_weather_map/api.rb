require_relative "response_parser"
require_relative "util"

module OpenWeatherMap
  class API
    API_KEY = Rails.application.credentials[:open_weather_map_api_key]
    BASE_URL = "https://api.openweathermap.org".freeze
    WEATHER_DATA_EXPIRATION = 30.minutes.freeze
    GEOCODE_DATA_EXPIRATION = 1.month.freeze

    GENERIC_ERROR_MESSAGE = "There's been an unexpected error. Please try again later.".freeze
    BAD_ADDRESS_ERROR_MESSAGE = "Error getting weather for address. Please provide as an address that includes a postal code.".freeze

    def initialize
      default_request_params = {
        appid: API_KEY,
        units: "imperial"
      }

      @conn = Faraday.new(BASE_URL) do |builder|
        builder.params = default_request_params
        builder.response :json
        builder.response :raise_error
      end
    end

    def weather(postal_code)
      cached_data = Rails.cache.read(postal_code)

      if cached_data.present?
        cached_data.merge({metadata: {cached: true}})
      else
        begin
          location_hash = geocode_by_postal_code(postal_code)

          params = {
            lat: location_hash[:lat],
            lon: location_hash[:lon]
          }

          # current weather request
          weather_response = @conn.get("data/2.5/weather") do |request|
            request.params = params.merge(request.params)
          end

          current_weather_data = OpenWeatherMap::ResponseParser.parse_current_weather_response_data(weather_response.body)
          location_name = weather_response.body["name"]

          # forecast request
          forecast_response = @conn.get("data/2.5/forecast") do |request|
            request.params = params.merge(request.params)
          end

          forecast_data = OpenWeatherMap::ResponseParser.parse_forecast_response_data(forecast_response.body)

          data_to_cache = {
            data: {
              location: location_name,
              current: current_weather_data,
              forecast: forecast_data
            }
          }

          Rails.cache.write(postal_code, data_to_cache, expires_in: WEATHER_DATA_EXPIRATION)

          data_to_cache.merge({metadata: {cached: false}})
        rescue Faraday::UnauthorizedError
          # log server config error
          {error: GENERIC_ERROR_MESSAGE}
        rescue Faraday::BadRequestError
          {error: BAD_ADDRESS_ERROR_MESSAGE}
        rescue Faraday::ResourceNotFound
          {error: BAD_ADDRESS_ERROR_MESSAGE}
        rescue Faraday::TooManyRequestsError
          {error: GENERIC_ERROR_MESSAGE}
        rescue Faraday::ServerError
          {error: GENERIC_ERROR_MESSAGE}
        end
      end
    end

    def geocode_by_postal_code(postal_code)
      cached_data = Rails.cache.read("#{postal_code}/geocode")

      if cached_data
        {lat: cached_data[:lat], lon: cached_data[:lon]}
      else
        params = {
          zip: "#{postal_code},US"
        }

        begin
          response = @conn.get("geo/1.0/zip") do |request|
            request.params = params.merge(request.params)
          end

          data = response.body
          data_to_cache = {lat: data["lat"], lon: data["lon"]}
          cache_key = "#{postal_code}/geocode"
          Rails.cache.write(cache_key, data_to_cache, expires_in: GEOCODE_DATA_EXPIRATION)

          data_to_cache
        rescue StandardError
          raise
        end
      end
    end
  end
end
