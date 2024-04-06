import React from 'react';
import ReactDOM from 'react-dom';
import GooglePlacesAutocomplete from 'react-google-places-autocomplete';

import "./weather_app.css";

// const GOOGLE_PLACES_API_KEY = process.env.GOOGLE_PLACES_API_KEY

const WeatherApp = () => {
  return (
    <div className="container">
      <div></div>

      <div>
        <Header/>
        <AddressInput/>
        <CurrentWeather/>
        <FiveDayForecast/>
      </div>

      <div></div>
    </div>
  );
}

const Header = () => {
  return (
    <h1>Weather</h1>
  )
}

const AddressInput = () => {
  return (
    <div>
      <GooglePlacesAutocomplete
        apiKey="****"
      />
    </div>
  )
}

const CurrentWeather = () => {
  return (
    <h1>Current Weather</h1>
  )
}

const FiveDayForecast = () => {
  return (
    <h1>Five-day Forecast</h1>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <WeatherApp />,
    document.body.appendChild(document.createElement('div')),
  )
})
