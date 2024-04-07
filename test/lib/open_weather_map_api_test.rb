require 'test_helper'

class OpenWeatherMapAPITest < ActiveSupport::TestCase
  setup do
    @owm = OpenWeatherMapAPI.new
  end

  test "weather" do
    @owm.weather(50322)
  end
end
