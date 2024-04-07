class WeatherController < ApplicationController
  def show
    owm = OpenWeatherMap::API.new

    # parse zip out of params[:q] to the best of my ability
    parsed_address = StreetAddress::US.parse(params[:q])

    postal_code = if parsed_address.present?
      parsed_address.postal_code
    else
      # \b(\d{5})\b: Matches a ZIP code consisting of five digits with word boundaries.
      # (?!.*\b\d{5}\b): Negative lookahead assertion to ensure that there are no more occurrences of a ZIP code pattern (\b\d{5}\b) ahead in the string.
      five_digit_postal_code_regex = /\b(\d{5})\b(?!.*\b\d{5}\b)/

      five_digit_postal_code_regex.match(params[:q])[0]
    end

    if postal_code.present?
      weather_data = owm.weather(postal_code)

      render json: weather_data
    else
      render json: {errors: ["something messed up"]}
    end
  end
end
