import React from 'react'

import { useAppState } from './context_providers/AppState'

import { Header } from './Header'

export const CurrentWeather = () => {
  const [state] = useAppState()
  const currentData = state.current
  const locationName = state.location
  const currentConditions = currentData.current_conditions
  const temperatureData = currentData.temperature.fahrenheit

  return (
    <>
      <Header text="My Location"/>
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
