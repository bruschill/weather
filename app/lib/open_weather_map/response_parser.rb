module OpenWeatherMap
  class ResponseParser
    # Parse current weather response data, returning a hash that includes initial and derived values we use
    # The process flow is as follows:
    # - parse fahrenheit temperature values, round them, and return just a hash of the selected keys
    # - convert fahrenheit temperature values to celsius
    # - parse current weather conditions
    # - parse timestamp
    # - return derived hash
    #
    # ====== Usage Example
    # data = {
    #   coord: {lon: -118.406, lat: 34.0901},
    #   weather: [{id: 800, main: "Clear", description: "clear sky", icon: "01n"}],
    #   base: "stations",
    #   main: {temp: 54.34, feels_like: 52.75, temp_min: 51.57, temp_max: 58.3, pressure: 1010, humidity: 70},
    #   visibility: 10000,
    #   wind: {speed: 9.22, deg: 250},
    #   clouds: {all: 0},
    #   dt: 1712546280,
    #   sys: {type: 2, id: 2082254, country: "US", sunrise: 1712496715, sunset: 1712542728},
    #   timezone: -25200,
    #   id: 5328041,
    #   name: "Beverly Hills",
    #   cod: 200
    # }
    #
    # parsed_data = OpenWeatherMap::ResponseParser.parse_current_weather_response_data(data)
    #
    # parsed_data #=> {
    #   timestamp: "2024-04-07 22:18:00 -0500",
    #   temperature: {
    #     fahrenheit: { temp: 54, feels_like: 53, temp_min: 52, temp_max: 58 },
    #     celsius: { temp: 12, feels_like: 12, temp_min: 11, temp_max: 14 }
    #   },
    #   current_conditions: "Clear"
    # }
    # @param [Hash] data
    # @return [Hash]
    def self.parse_current_weather_response_data(data)
      fahrenheit_temperature_data = data["main"].each_with_object({}) do |(key, value), hash|
        if key.in?(%W[temp temp_min temp_max feels_like])
          hash[key] = value.round
        end
      end
      celsius_temperature_data = OpenWeatherMap::Util.convert_fahrenheit_temperature_data_to_celsius(fahrenheit_temperature_data)
      current_conditions_data = data["weather"][0]["main"]
      timestamp = Time.at(data["dt"]).to_s

      {
        timestamp: timestamp,
        temperature: {
          fahrenheit: fahrenheit_temperature_data,
          celsius: celsius_temperature_data
        },
        current_conditions: current_conditions_data
      }
    end

    # Parse current weather response data, returning a hash that includes initial and derived values we use
    # The process flow is as follows:
    # - parse forecast by provided list of date intervals
    # - preprocess the forecast by interval, grouping intervals by date:
    #   - extract interval timestamp, convert to date
    #   - extract min and max temp for interval, build hash with those values
    #   - add temperature hash to for date
    # - build result hash from preprocessed_hash
    #   - find min, max temperature for date across intervals, round them
    #   - parse the date from the key
    #   - set day_name
    #     - if date is today
    #       - return "Today"
    #     - else
    #       - return the date formatted to show weekday name
    #   - build forecast data for day
    # - return result hash
    #
    # ====== Usage Example
    # data = {
    #   cod: "200",
    #   message: 0,
    #   cnt: 40,
    #   list: [
    #     {
    #       dt: 1712556000,
    #       main: {
    #         temp: 54.73,
    #         feels_like: 52.97,
    #         temp_min: 54.73,
    #         temp_max: 55.87,
    #         pressure: 1011,
    #         sea_level: 1011,
    #         grnd_level: 994,
    #         humidity: 65,
    #         temp_kf: -0.63
    #       },
    #       weather: [{
    #         id: 801,
    #         main: "Clouds",
    #         description: "few clouds",
    #         icon: "02n"
    #       }],
    #       clouds: {
    #         all: 18
    #       },
    #       wind: {
    #         speed: 1.25,
    #         deg: 67,
    #         gust: 5.59
    #       },
    #       visibility: 10000,
    #       pop: 0,
    #       sys: {
    #         pod: "n"
    #       },
    #       dt_txt: "2024-04-08 06:00:00"
    #     },
    #     ...
    #   ],
    #   city: {
    #     id: 5328041,
    #     name: "Beverly Hills",
    #     coord: {lat: 34.0901, lon: -118.4065},
    #     country: "US",
    #     population: 34109,
    #     timezone: -25200,
    #     sunrise: 1712496715,
    #     sunset: 1712542728
    #   }
    # }
    #
    # parsed_data = OpenWeatherMap::ResponseParser.parse_forecast_response_data(data)
    # parsed_data #=> {
    #   "2024-04-08": {
    #     day_name: "Today",
    #     fahrenheit: {temp_min: 52, temp_max: 67},
    #     celsius: {temp_min: 11, temp_max: 19}
    #   },
    #   "2024-04-09": {
    #     day_name: "Tuesday",
    #     fahrenheit: {temp_min: 58, temp_max: 73},
    #     celsius: {temp_min: 14, temp_max: 23}
    #   },
    #   "2024-04-10": {
    #     day_name: "Wednesday",
    #     fahrenheit: {temp_min: 60, temp_max: 74},
    #     celsius: {temp_min: 16, temp_max: 23}
    #   },
    #   "2024-04-11": {
    #     day_name: "Thursday",
    #     fahrenheit: {temp_min: 62, temp_max: 75},
    #     celsius: {temp_min: 17, temp_max: 24}
    #   },
    #   "2024-04-12": {
    #     day_name: "Friday",
    #     fahrenheit: {temp_min: 59, temp_max: 73},
    #     celsius: {temp_min: 15, temp_max: 23}
    #   },
    #   "2024-04-13": {
    #     day_name: "Saturday",
    #     fahrenheit: {temp_min: 59, temp_max: 62},
    #     celsius: {temp_min: 15, temp_max: 17}
    #   }
    # }
    #
    # @param [Hash] data
    # @return [Hash]
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
          date.strftime("%A")
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
