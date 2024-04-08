import React from 'react'
import ClipLoader from 'react-spinners/ClipLoader'

import { useLoadingState } from './context_providers/LoadingState'
import { useUnitState } from './context_providers/UnitState'

import { CurrentWeather } from './CurrentWeather'
import { FiveDayForecast } from './FiveDayForecast'

export const WeatherBox = () => {
  const [loadingState] = useLoadingState()
  const [unitState] = useUnitState()

  return (
    <>
      {loadingState.isLoading &&
        <ClipLoader loading={loadingState.isLoading} />
      }
      {loadingState.loaded &&
        <>
          <CurrentWeather unit={unitState}/>
          <FiveDayForecast unit={unitState}/>
        </>
      }
    </>
  )
}
