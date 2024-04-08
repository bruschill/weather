module OpenWeatherMap
  class Util
    # Converts parsed fahrenheit temperature data to celsius
    #
    # The process flow is as follows:
    # - iterate through fahrenheit temperature data, converting the value to celsius
    #
    # ====== Usage Example
    # fahrenheit_temperature_data = {
    #   temp: 47,
    #   feels_like: 43,
    #   temp_min: 45,
    #   temp_max: 49
    # }
    #
    # celsius_temperature_data = OpenWeatherMap::Util.convert_fahrenheit_temperature_data_to_celsius(fahrenheit_temperature_data)
    # celsius_temperature_data #=> {
    #   temp: 8,
    #   feels_like: 6,
    #   temp_min: 7,
    #   temp_max: 9
    # }
    #
    # @param [Hash] data
    # @return [Hash]
    def self.convert_fahrenheit_temperature_data_to_celsius(data)
      data.each_with_object({}) do |(key, value), hash|
        hash[key] = convert_fahrenheit_to_celsius(value)
      end
    end

    # Converts fahrenheit temp to celsius
    #
    # ====== Usage Example
    # fahrenheit_temp = 32
    #
    # celsius_temp = OpenWeatherMap::Util.convert_fahrenheit_to_celsius()
    # celsius_temp #=> 0
    # @param [Integer] fahrenheit_temp
    # @return [Integer]
    def self.convert_fahrenheit_to_celsius(fahrenheit_temp)
      ((fahrenheit_temp.to_f - 32) * 5 / 9).round
    end
  end
end
