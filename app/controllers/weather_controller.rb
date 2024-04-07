class WeatherController < ApplicationController
  def show
    owm = OpenWeatherMapAPI.new

    # parse zip out of params[:q] to the best of my ability
    parsed_address = StreetAddress::US.parse(params[:q])
    postal_code = parsed_address&.postal_code

    data = if postal_code.present?
             owm.weather(postal_code)
           else
             # \b(\d{5})\b: Matches a ZIP code consisting of five digits with word boundaries.
             # (?!.*\b\d{5}\b): Negative lookahead assertion to ensure that there are no more occurrences of a ZIP code pattern (\b\d{5}\b) ahead in the string.
             five_digit_postal_code_regex = /\b(\d{5})\b(?!.*\b\d{5}\b)/

             postal_code = five_digit_postal_code_regex.match(params[:q])[0]
             owm.weather(postal_code)
           end

   render json: data
  end
end
