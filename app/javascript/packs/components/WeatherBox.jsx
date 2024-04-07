import React from 'react'
import ClipLoader from 'react-spinners/ClipLoader'

import { useLoadingState } from './context_providers/LoadingState'

import { CurrentWeather } from './CurrentWeather'
import { FiveDayForecast } from './FiveDayForecast'

export const WeatherBox = () => {
  const [loadingState] = useLoadingState()

  return (
    <>
      {loadingState.isLoading &&
        <ClipLoader loading={loadingState.isLoading} />
      }
      {loadingState.loaded &&
        <>
          <CurrentWeather/>
          <FiveDayForecast/>
        </>
      }
    </>
  )
}
