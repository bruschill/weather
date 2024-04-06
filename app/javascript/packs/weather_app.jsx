import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

// const GOOGLE_PLACES_API_KEY = process.env.GOOGLE_PLACES_API_KEY

const WeatherApp = () => {
  return (
    <h1>Weather</h1>
  );
}

WeatherApp.defaultProps = {
}

WeatherApp.propTypes = {
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <WeatherApp />,
    document.body.appendChild(document.createElement('div')),
  )
})
