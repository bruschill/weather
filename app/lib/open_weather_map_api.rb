class OpenWeatherMapAPI
  API_KEY = Rails.application.credentials[:open_weather_map_api_key]
  BASE_URL = "https://api.openweathermap.org".freeze
  WEATHER_DATA_EXPIRATION = 5.seconds
  GEOCODE_DATA_EXPIRATION = 1.month

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
      lat, lon = geocode_by_postal_code(postal_code)
      params = {
        lat: lat,
        lon: lon
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
    location_name = data["location"]
    environment_data = data["main"].select { |key, _value| key.in?(%W[humidity pressure]) }
    fahrenheit_temperature_data = data["main"].select { |key, _value| key.in?(%W[temp temp_min temp_max feels_like]) }
    celsius_temperature_data = convert_fahrenheit_temperature_data_to_celsius(fahrenheit_temperature_data)
    wind_data = data["wind"]
    current_conditions_data = data["weather"][0]["main"]
    timestamp = Time.at(data["dt"])

    {
      location: location_name,
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
    location_name = data["city"]["name"]
    five_day_forecast = data["list"]

    preprocessed_five_day_forecast = five_day_forecast.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |forecast_interval, hash|
      # iterating by interval
      date = Date.parse(forecast_interval["dt_txt"])
      min_max_temp_hash = {
        temp_min: forecast_interval["main"]["temp_min"],
        temp_max: forecast_interval["main"]["temp_max"]
      }

      hash[date.to_s] << min_max_temp_hash
    end

    preprocessed_five_day_forecast.each_with_object({}) do |(key, value), hash|
      min_temp = value.map { |v| v[:temp_min] }.min
      max_temp = value.map { |v| v[:temp_max] }.max
      date = Date.parse(key)

      day_name = if date.today?
        "Today"
      else
        Date.parse(key).strftime("%A")
      end

      hash[key] = {
        day_name: day_name,
        fahrenheit: {
          temp_min: min_temp,
          temp_max: max_temp
        },
        celsius: {
          temp_min: convert_fahrenheit_to_celsius(min_temp),
          temp_max: convert_fahrenheit_to_celsius(max_temp)
        }
      }
    end
  end

  def convert_fahrenheit_temperature_data_to_celsius(data)
    data.each_with_object({}) do |(key, value), hash|
      hash[key] = convert_fahrenheit_to_celsius(value)
    end
  end

  def convert_fahrenheit_to_celsius(fahrenheit_temp)
    ((fahrenheit_temp.to_f - 32) * 5 / 9).round(2)
  end
end
