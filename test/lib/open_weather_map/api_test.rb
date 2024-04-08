require "test_helper"

describe "OpenWeatherMap::APITest" do
  describe "weather" do
    before do
      @owm = OpenWeatherMap::API.new
    end

    describe "when successful" do
      it "has properly formatted response" do
        VCR.use_cassette("successful_weather_request") do
          successful_response = {data: {location: "Urbandale", current: {timestamp: "2024-04-07 19:03:27 -0500", temperature: {fahrenheit: {"temp" => 62, "feels_like" => 60, "temp_min" => 61, "temp_max" => 63}, celsius: {"temp" => 17, "feels_like" => 16, "temp_min" => 16, "temp_max" => 17}}, current_conditions: "Clouds"}, forecast: {"2024-04-08" => {day_name: "Today", fahrenheit: {temp_min: 47, temp_max: 64}, celsius: {temp_min: 8, temp_max: 18}}, "2024-04-09" => {day_name: "Tuesday", fahrenheit: {temp_min: 42, temp_max: 64}, celsius: {temp_min: 6, temp_max: 18}}, "2024-04-10" => {day_name: "Wednesday", fahrenheit: {temp_min: 48, temp_max: 67}, celsius: {temp_min: 9, temp_max: 19}}, "2024-04-11" => {day_name: "Thursday", fahrenheit: {temp_min: 48, temp_max: 62}, celsius: {temp_min: 9, temp_max: 17}}, "2024-04-12" => {day_name: "Friday", fahrenheit: {temp_min: 41, temp_max: 62}, celsius: {temp_min: 5, temp_max: 17}}, "2024-04-13" => {day_name: "Saturday", fahrenheit: {temp_min: 59, temp_max: 59}, celsius: {temp_min: 15, temp_max: 15}}}}, metadata: {cached: false}}

          data = @owm.weather(50322)
          assert_equal(data, successful_response)
        end
      end
    end

    describe "when request for current weather fails" do
      describe "401" do
        it "returns correct error message" do
          VCR.use_cassette("current_weather_401") do
            expected = {error: OpenWeatherMap::API::GENERIC_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end

      describe "404" do
        it "returns correct error message" do
          VCR.use_cassette("current_weather_404") do
            expected = {error: OpenWeatherMap::API::BAD_ADDRESS_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end

      describe "429" do
        it "returns correct error message" do
          VCR.use_cassette("current_weather_429") do
            expected = {error: OpenWeatherMap::API::GENERIC_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end

      describe "500" do
        it "returns correct error message" do
          VCR.use_cassette("current_weather_500") do
            expected = {error: OpenWeatherMap::API::GENERIC_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end
    end

    describe "when request for forecast fails" do
      describe "401" do
        it "returns correct error message" do
          VCR.use_cassette("forecast_401") do
            expected = {error: OpenWeatherMap::API::GENERIC_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end

      describe "404" do
        it "returns correct error message" do
          VCR.use_cassette("forecast_404") do
            expected = {error: OpenWeatherMap::API::BAD_ADDRESS_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end

      describe "429" do
        it "returns correct error message" do
          VCR.use_cassette("forecast_429") do
            expected = {error: OpenWeatherMap::API::GENERIC_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end

      describe "500" do
        it "returns correct error message" do
          VCR.use_cassette("forecast_500") do
            expected = {error: OpenWeatherMap::API::GENERIC_ERROR_MESSAGE}
            data = @owm.weather(50322)
            assert_equal(expected, data)
          end
        end
      end
    end
  end

  describe "geocode_by_postal_code" do
    before do
      @owm = OpenWeatherMap::API.new
    end

    describe "401" do
      it "Raises Faraday::UnauthorizedError" do
        VCR.use_cassette("geolocation_401") do
          assert_raises(Faraday::UnauthorizedError) { @owm.geocode_by_postal_code(50322) }
        end
      end
    end

    describe "404" do
      it "Raises Faraday::ResourceNotFound" do
        VCR.use_cassette("geolocation_404") do
          assert_raises(Faraday::ResourceNotFound) { @owm.geocode_by_postal_code(50322) }
        end
      end
    end

    describe "429" do
      it "Raises Faraday::TooManyRequestsError" do
        VCR.use_cassette("geolocation_429") do
          assert_raises(Faraday::TooManyRequestsError) { @owm.geocode_by_postal_code(50322) }
        end
      end
    end

    describe "500" do
      it "Raises Faraday::ServerError" do
        VCR.use_cassette("geolocation_500") do
          assert_raises(Faraday::ServerError) { @owm.geocode_by_postal_code(50322) }
        end
      end
    end
  end
end
