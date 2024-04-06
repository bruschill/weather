class WeatherController < ApplicationController
  def show
    owm = OpenWeatherMapAPI.new

    data = owm.current_weather(50322)

    render json: data
  end
end
