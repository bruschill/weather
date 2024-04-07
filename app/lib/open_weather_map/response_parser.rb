module OpenWeatherMap
  class ResponseParser
    def self.parse_current_weather_response_data(data)
      location_name = data["location"]
      environment_data = data["main"].select { |key, _value| key.in?(%W[humidity pressure]) }
      fahrenheit_temperature_data = data["main"].select { |key, _value| }
      celsius_temperature_data = OpenWeatherMap::Util.convert_fahrenheit_temperature_data_to_celsius(fahrenheit_temperature_data)
      fahrenheit_temperature_data = data["main"].each_with_object({}) do |(key, value), hash|
        if key.in?(%W[temp temp_min temp_max feels_like])
          hash[key] = value.round
        end
      end
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

    def self.parse_forecast_response_data(data)
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
        min_temp = value.map { |v| v[:temp_min] }.min.round
        max_temp = value.map { |v| v[:temp_max] }.max.round
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
            temp_min: OpenWeatherMap::Util.convert_fahrenheit_to_celsius(min_temp),
            temp_max: OpenWeatherMap::Util.convert_fahrenheit_to_celsius(max_temp)
          }
        }
      end
    end

  end
end
