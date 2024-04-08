import React from 'react'
import PropTypes from 'prop-types'

import { useAppState } from './context_providers/AppState'

import { Header } from './Header'

export const FiveDayForecast = ({ unit }) => {
  const [state] = useAppState()
  const forecastData = state.forecast

  return (
    <>
      <Header text="Five-day Forecast"/>
      {
        Object.entries(forecastData).map(([key, value], index) => {
          const temperatureValues = unit === 'f' ? value.fahrenheit : value.celsius

          return (
            <div key={index}>
              {/* {value.day_name} -&gt; H:{value.fahrenheit.temp_max}° L:{value.fahrenheit.temp_min}° */}
              {value.day_name} -&gt; H:{temperatureValues.temp_max}° L:{temperatureValues.temp_min}°
            </div>
          )
        })
      }
    </>
  )
}

FiveDayForecast.propTypes = {
  unit: PropTypes.string.isRequired
}
