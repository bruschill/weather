require_relative "util"

module OpenWeatherMap
  class API
    API_KEY = Rails.application.credentials[:open_weather_map_api_key]
    BASE_URL = "https://api.openweathermap.org".freeze
    WEATHER_DATA_EXPIRATION = 5.seconds
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
        lat, lon = OpenWeatherMap::Geocoder.geocode_by_postal_code(postal_code)
        params = {
          lat: lat,
          lon: lon
        }

        begin
          # current weather request
          response = @conn.get("data/2.5/weather") do |request|
            request.params = params.merge(request.params)
          end

          current_weather_data = OpenWeatherMap::ResponseParser.parse_current_weather_response_data(response.body)
          location_name = response.body["name"]

          # forecast request
          response = @conn.get("data/2.5/forecast") do |request|
            request.params = params.merge(request.params)
          end

          forecast_data = OpenWeatherMap::ResponseParser.parse_forecast_response_data(response.body)

          data_to_cache = {
            data: {
              location: location_name,
              current: current_weather_data,
              forecast: forecast_data
            }
          }

          Rails.cache.write(postal_code, data_to_cache, expires_in: WEATHER_DATA_EXPIRATION)

          data_to_cache.merge({metadata: {cached: false}})
        rescue Faraday::UnauthorizedError => e
          # 401, some kind of misconfiguration like wrong API key
        rescue Faraday::ResourceNotFound => e
          # 404, most likely a non-US address
        rescue Faraday::ClientError => e
          if e.response_status == 429
            # too many requests per minute
          else
            # site down or some other critical error we're not prepared to handle
          end
        end
      end
    end

  end
end
