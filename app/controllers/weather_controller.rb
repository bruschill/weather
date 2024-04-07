class WeatherController < ApplicationController
  def show
    owm = OpenWeatherMapAPI.new

    # parse zip out of params[:q] to the best of my ability
    data = owm.weather(params[:q])

    render json: data
  end
end
