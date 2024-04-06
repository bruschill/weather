class OpenWeatherMapAPI
  API_KEY = Rails.application.credentials[:open_weather_map_api_key]
  BASE_URL = 'https://api.openweathermap.org'.freeze

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

  def current_weather(postal_code)
    cached_data = Rails.cache.read(postal_code)

    if cached_data.present?
      cached_data
    else
      lat, lon = geocode_by_postal_code(postal_code)
      params = {
        lat: lat,
        lon: lon,
      }

      begin
        response = @conn.get("data/2.5/weather") do |request|
          request.params = params.merge(request.params)
        end

        data_to_cache = parse_response_body(response.body)
        cache_current_weather_data(postal_code, data_to_cache)

        data_to_cache
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

  def five_day_forecast(postal_code)
    cache_exists = false

    if cache_exists
      # return cache data for postal code
    else
      lat, lon = geocode_by_postal_code(postal_code)
      params = {
        lat: lat,
        lon: lon,
      }

      begin
        response = @conn.get("data/2.5/forecast") do |request|
          request.params = params.merge(request.params)
        end

        # need to parse a different way, as data needed is in response.body["list"]
        # data is every three hours starting at 03:00 the day after present day
        data_to_cache = parse_response_body(response.body)
        cache_current_forecast_data(postal_code, data_to_cache)

        data_to_cache
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
    params = {
      zip: "#{postal_code},US",
    }

    begin
      response = @conn.get("geo/1.0/zip") do |request|
        request.params = params.merge(request.params)
      end

      data = response.body

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

  def parse_response_body(data)
    # collect only necessary fields here
    # duplicate fahrenheit fields in celsius
    # respond with { data: { fields: 'that', we: 'need'}}
    data
  end

  def cache_current_weather_data(postal_code, data)
    # cache weather data, return true if it worked, false if it failed
    val = Rails.cache.write(postal_code, data)
    puts val
    val
  end

  def cache_current_forecast_data(postal_code, data)
    val = Rails.cache.write(postal_code, data)
    puts val
    val
  end
end
