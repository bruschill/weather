require 'test_helper'

class OpenWeatherMapAPITest < ActiveSupport::TestCase
  setup do
    @owm = OpenWeatherMapAPI.new
  end

  test "current_weather" do
    @owm.current_weather(50322)
  end

  test "five_day_forecast" do
    @owm.five_day_forecast(50322)
  end
end
