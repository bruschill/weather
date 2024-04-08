import React, { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { ErrorMessage } from '@hookform/error-message'

import { useAppState } from './context_providers/AppState'
import { useLoadingState } from './context_providers/LoadingState'

import { UnitToggle } from './UnitToggle'
import { useUnitState } from './context_providers/UnitState'

export const AddressInput = () => {
  const [_state, setState] = useAppState()
  const [_loadingState, setLoadingState] = useLoadingState()
  const [unitState, setUnitState] = useUnitState()
  const [address, setAddress] = useState(null)
  const {
    clearErrors,
    handleSubmit,
    formState: { errors },
    register,
    reset
  } = useForm({
    defaultValues: address,
    mode: "onSubmit",
    reValidateMode: "onSubmit",
  })

  useEffect(() => {
    const requestOptions = {
      headers: {
        'Content-Type': 'application/json'
      }
    }

    if (address) {
      setLoadingState({ loading: true, loaded: false })

      fetch(`/weather?q=${address}`, requestOptions)
        .then((response) => response.json())
        .then(({ data }) => {
          // this is the data blob we end up using to render content via context state in CurrentWeather, FiveDayForecast
          setState(data)

          setLoadingState({ loading: false, loaded: true })
        })
        .catch((error) => console.log(error))
    }
  }, [address])

  const onSubmit = (data) => {
    setAddress(data.q)
    reset()
  }

  const handleUnitChange = ({ target: { value } }) => {
    if (value === 'f') {
      value = 'c'
      setUnitState(value)
    } else {
      value = 'f'
      setUnitState(value)
    }
  }

  const addressInputOnClick = (e) => {
    e.target.value = ''
    clearErrors('q')
  }

  return (
    <div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <input
          {...register('q', {
            pattern: {
              value: /\b(\d{5})\b(?!.*\b\d{5}\b)/,
              message: 'Bad address'
            }
          })}
          type="text"
          id="q"
          name="q"
          placeholder="Enter your address"
          onClick={addressInputOnClick}
        />
        <UnitToggle onChange={handleUnitChange} value={unitState}/>
        <input type="submit"/>
        <div>
          <ErrorMessage errors={errors} name="q"/>
        </div>
      </form>
    </div>
  )
}
