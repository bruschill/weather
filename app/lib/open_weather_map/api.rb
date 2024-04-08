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

      # Set up base Faraday connection object that's used for API requests
      @conn = Faraday.new(BASE_URL) do |builder|
        builder.params = default_request_params
        builder.response :json
        builder.response :raise_error
      end
    end

    # Requests current weather and forecast data for a particular zipcode
    #
    # The process flow is as follows:
    # - get geocode data
    #   - check cache
    #     - if cache exists
    #       - return cached data
    #     - else
    #       - query API for geocoded data for postal_code
    #       - cache geocoded data
    #       - return cached data
    # - get weather data
    #   - check cache
    #     - if cache exists
    #       - return cached data
    #     - else query API for current conditions
    #       - query API for current weather conditions for postal_code
    #         - parse response to include only values we need
    #       - query API for forecast weather conditions for postal_code
    #         - parse response to include only values we need
    #       - build weather hash to cache
    #       - cache weather hash
    #       - return weather hash
    #
    # ====== Usage Example
    # @open_weather_map = OpenWeatherMap::API.new
    # weather_data = @open_weather_map.weather(50322)
    #
    # weather_data #=>
    # {
    #   data: {
    #     location: "Urbandale",
    #     current: {
    #       timestamp: "2024-04-08 10:33:04 -0500",
    #       temperature: {
    #         fahrenheit: { temp: 53, feels_like: 52, temp_min: 51, temp_max: 54 },
    #         celsius: { temp: 12, feels_like: 11, temp_min: 11, temp_max: 12 }
    #       },
    #       current_conditions: "Clouds"
    #     },
    #     forecast: {
    #       "2024-04-08": { day_name: "Today", fahrenheit: { temp_min: 55, temp_max: 63 }, celsius: { temp_min: 13, temp_max: 17 } },
    #       "2024-04-09": { day_name: "Tuesday", fahrenheit: { temp_min: 39, temp_max: 62 }, celsius: { temp_min: 4, temp_max: 17 } },
    #       "2024-04-10": { day_name: "Wednesday", fahrenheit: { temp_min: 46, temp_max: 69 }, celsius: { temp_min: 8, temp_max: 21 } },
    #       "2024-04-11": { day_name: "Thursday", fahrenheit: { temp_min: 49, temp_max: 62 }, celsius: { temp_min: 9, temp_max: 17 } },
    #       "2024-04-12": { day_name: "Friday", fahrenheit: { temp_min: 42, temp_max: 60 }, celsius: { temp_min: 6, temp_max: 16 } },
    #       "2024-04-13": { day_name: "Saturday", fahrenheit: { temp_min: 44, temp_max: 59 }, celsius: { temp_min: 7, temp_max: 15 } }
    #     }
    #   },
    #   metadata: {
    #     cached: true
    #   }
    # }
    # @param [Integer] postal_code
    # @return [Hash]
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

          # Request current weather for postal code
          weather_response = @conn.get("data/2.5/weather") do |request|
            request.params = params.merge(request.params)
          end

          current_weather_data = OpenWeatherMap::ResponseParser.parse_current_weather_response_data(weather_response.body)
          location_name = weather_response.body["name"]

          # Request forecast for postal code
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
