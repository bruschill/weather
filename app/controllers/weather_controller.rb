class WeatherController < ApplicationController
  def show
    owm = OpenWeatherMap::API.new

    postal_code = params[:q]

    if postal_code.present? && postal_code.length === 5
      weather_data = owm.weather(postal_code)

      puts weather_data

      render json: weather_data
    else
      render json: {error: OpenWeatherMap::API::BAD_ADDRESS_ERROR_MESSAGE}, status: 400
    end
  end
end
