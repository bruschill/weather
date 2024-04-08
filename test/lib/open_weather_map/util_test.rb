require "test_helper"

describe "OpenWeatherMap::UtilTest" do
  describe "#convert_fahrenheit_temperature_data_to_celsius" do
    it "converts the hash's fields' values to celsius" do
      hash_to_convert = {"temp" => 47, "feels_like" => 43, "temp_min" => 45, "temp_max" => 49}
      converted_hash = OpenWeatherMap::Util.convert_fahrenheit_temperature_data_to_celsius(hash_to_convert)

      converted_hash.each do |key, value|
        converted_value = OpenWeatherMap::Util.convert_fahrenheit_to_celsius(hash_to_convert[key])
        assert_equal(value, converted_value)
      end
    end
  end

  describe "#convert_fahrenheit_to_celsius" do
    it "converts correctly" do
      assert_equal(OpenWeatherMap::Util.convert_fahrenheit_to_celsius(0), -18)
      assert_equal(OpenWeatherMap::Util.convert_fahrenheit_to_celsius(32), 0)
      assert_equal(OpenWeatherMap::Util.convert_fahrenheit_to_celsius(100), 38)
    end
  end
end
