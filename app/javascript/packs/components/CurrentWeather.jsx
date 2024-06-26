import React from 'react'
import PropTypes from 'prop-types'

import { useAppState } from './context_providers/AppState'

import { Header } from './Header'

export const CurrentWeather = ({ unit }) => {
  const [state] = useAppState()
  const currentData = state.data.current
  const currentMetadata = state.metadata
  const locationName = state.location
  const currentConditions = state.data.current.current_conditions
  const temperatureData = unit === 'f' ? currentData.temperature.fahrenheit : currentData.temperature.celsius
  const cachedData = currentMetadata.cached

  return (
    <>
      <span>
        <Header text={`My Location${cachedData ? '*' : ''}`}/>
      </span>
      <div className="location-name">
        {locationName}
      </div>
      <div className="temperature-container">
        <div className="current-temperature">
          {temperatureData.temp}°
        </div>
        <div className="current_conditions">
          {currentConditions}
        </div>
        <div className="feels-like-temperature">
          Feels like {temperatureData.temp}°
        </div>
        <div className="high-low-temperature">
          H:{temperatureData.temp_max}° L:{temperatureData.temp_min}°
        </div>
      </div>
    </>
  )
}

CurrentWeather.propTypes = {
  unit: PropTypes.string.isRequired
}
