module OpenWeatherMap
  class Util
    def self.convert_fahrenheit_temperature_data_to_celsius(data)
      data.each_with_object({}) do |(key, value), hash|
        hash[key] = convert_fahrenheit_to_celsius(value)
      end
    end

    def self.convert_fahrenheit_to_celsius(fahrenheit_temp)
      ((fahrenheit_temp.to_f - 32) * 5 / 9).round
    end
  end
end
