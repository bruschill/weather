require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "it works with just a valid postal code" do
    VCR.use_cassette("request_with_only_postal_code") do
      postal_code = "50322"
      get weather_path, params: { q: postal_code }, as: :json

      location = "Urbandale"
      assert_equal(location, JSON.parse(response.body)["data"]["location"])
    end
  end

  test "it works with just a valid postal code with extended 4 digits" do
    VCR.use_cassette("request_with_extended_postal_code") do
      get weather_path, params: { q: "50322-1234" }, as: :json

      location = "Urbandale"
      assert_equal(location, JSON.parse(response.body)["data"]["location"])
    end
  end

  test "it works with just a a full address" do
    full_address = "10600 N Tantau Ave, Cupertino, CA 95014-0708"
    VCR.use_cassette("request_with_full_address") do
      get weather_path, params: { q: full_address }, as: :json

      location = "Cupertino"
      assert_equal(location, JSON.parse(response.body)["data"]["location"])
    end
  end

  test "it doesn't work without a postal code" do
    address_with_no_postal_code = "7418 Beechwood Drive, Urbandale"

    VCR.use_cassette("request_without_postal_code") do
      expected_response = {
        "error" => OpenWeatherMap::API::BAD_ADDRESS_ERROR_MESSAGE
      }
      get weather_path, params: { q: address_with_no_postal_code }, as: :json

      assert_equal(expected_response, JSON.parse(response.body))

    end
  end
end
