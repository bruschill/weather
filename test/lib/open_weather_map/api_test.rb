require "test_helper"

class OpenWeatherMap::APITest < ActiveSupport::TestCase
  setup do
    @owm = OpenWeatherMap::API.new
  end

  test "weather" do
    @owm.weather(50322)
  end
end
