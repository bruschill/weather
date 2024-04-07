module OpenWeatherMap
  GEOCODE_DATA_EXPIRATION = 1.month

  class Geocoder
    def self.geocode_by_postal_code(postal_code)
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
  end
end
