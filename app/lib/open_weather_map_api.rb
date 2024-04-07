class OpenWeatherMapAPI
  API_KEY = Rails.application.credentials[:open_weather_map_api_key]
  BASE_URL = 'https://api.openweathermap.org'.freeze
  WEATHER_DATA_EXPIRATION = 5.seconds
  GEOCODE_DATA_EXPIRATION = 1.month

  def initialize
    default_request_params = {
      appid: API_KEY,
      units: 'imperial'
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
      cached_data.merge({ metadata: { cached: true } })
    else
      lat, lon = geocode_by_postal_code(postal_code)
      params = {
        lat: lat,
        lon: lon,
      }

      begin
        # current weather request
        response = @conn.get("data/2.5/weather") do |request|
          request.params = params.merge(request.params)
        end

        current_weather_data = parse_current_weather_response_data(response.body)
        location_name = response.body["name"]

        # forecast request
        response = @conn.get("data/2.5/forecast") do |request|
          request.params = params.merge(request.params)
        end

        forecast_data = parse_forecast_response_data(response.body)

        data_to_cache = {
          data: {
            location: location_name,
            current: current_weather_data,
            forecast: forecast_data
          }
        }

        Rails.cache.write(postal_code, data_to_cache, expires_in: WEATHER_DATA_EXPIRATION)

        data_to_cache.merge({ metadata: { cached: false } })
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

  private

  def geocode_by_postal_code(postal_code)
    cached_data = Rails.cache.read("#{postal_code}/geocode")

    if cached_data
      [cached_data["lat"], cached_data["lon"]]
    else
      params = {
        zip: "#{postal_code},US"
      }

      begin
        response = @conn.get("geo/1.0/zip") do |request|
          request.params = params.merge(request.params)
        end

        data = response.body
        cache_key = "#{postal_code}/geocode"
        Rails.cache.write(cache_key, data, expires_in: GEOCODE_DATA_EXPIRATION)

        [data["lat"], data["lon"]]
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

  def parse_current_weather_response_data(data)
    environment_data = data["main"].select { |key, _value| key.in?(%W[humidity pressure]) }
    fahrenheit_temperature_data = data["main"].select { |key, _value| key.in?(%W[temp temp_min temp_max feels_like]) }
    celsius_temperature_data = convert_fahrenheit_temperature_data_to_celsius(fahrenheit_temperature_data)
    wind_data = data["wind"]
    current_conditions_data = data["weather"][0]["main"]
    timestamp = Time.at(data["dt"])

    {
      timestamp: timestamp,
      environment: environment_data,
      temperature: {
        fahrenheit: fahrenheit_temperature_data,
        celsius: celsius_temperature_data
      },
      wind: wind_data,
      current_conditions: current_conditions_data
    }
  end

  def parse_forecast_response_data(data)
    five_day_forecast = data["list"]

    parsed_forecast = five_day_forecast.map do |forecast_interval|
      environment_data = forecast_interval["main"].select { |key, _value| key.in?(%W[humidity pressure]) }
      fahrenheit_temperature_data = forecast_interval["main"].select { |key, _value| key.in?(%W[temp_min temp_max]) }
      celsius_temperature_data = convert_fahrenheit_temperature_data_to_celsius(fahrenheit_temperature_data)
      wind_data = forecast_interval["wind"]
      timestamp = forecast_interval["dt_txt"]

      {
        environment: environment_data,
        temperature: {
          fahrenheit: fahrenheit_temperature_data,
          celsius: celsius_temperature_data
        },
        wind: wind_data,
        timestamp: timestamp
      }
    end

    {
      forecast: parsed_forecast
    }
  end

  def convert_fahrenheit_temperature_data_to_celsius(data)
    data.each_with_object({}) do |(key, value), hash|
      hash[key] = ((value.to_f - 32) * 5 / 9).round(2)
    end
  end
end
