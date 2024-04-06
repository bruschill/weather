import React from 'react';
import ReactDOM from 'react-dom';
import "./weather_app.css";

// const GOOGLE_PLACES_API_KEY = process.env.GOOGLE_PLACES_API_KEY

const WeatherApp = () => {
  return (
    <div className="container">
      <div></div>

      <div>
        <h1>Weather</h1>
      </div>

      <div></div>
    </div>
  );
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <WeatherApp />,
    document.body.appendChild(document.createElement('div')),
  )
})
