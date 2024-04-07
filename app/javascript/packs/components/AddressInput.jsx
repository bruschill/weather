import React, { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'

import { useAppState } from './context_providers/AppState'
import { useLoadingState } from './context_providers/LoadingState'

export const AddressInput = () => {
  const [_loadingState, setLoadingState] = useLoadingState()
  const [_state, setState] = useAppState()
  const [address, setAddress] = useState(null)
  const {
    handleSubmit,
    formState: { errors },
    register,
    reset
  } = useForm({
    defaultValues: address,
    mode: 'onSubmit'
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

  return (
    <div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <input
          {...register('q')}
          type="text"
          id="q"
          name="q"
          placeholder="Enter your address"
        />
      </form>
    </div>
  )
}
