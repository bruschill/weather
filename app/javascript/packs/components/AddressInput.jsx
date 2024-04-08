import React, { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { ErrorMessage } from '@hookform/error-message'

import { INITIAL_APP_STATE, useAppState } from './context_providers/AppState'
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
    mode: 'onSubmit',
    reValidateMode: 'onSubmit'
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
        .then(({ data, metadata }) => {
          setState({data, metadata})

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
    setState(INITIAL_APP_STATE)
    clearErrors('q')
  }

  return (
    <div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <input
          {...register('q', {
            pattern: {
              value: /\b(\d{5})\b(?!.*\b\d{5}\b)/,
              message: 'Please try again with an address that has a postal code'
            }
          })}
          type="text"
          id="q"
          name="q"
          placeholder="Enter your address, making sure to include at least the postal code"
          onClick={addressInputOnClick}
        />
        <UnitToggle onChange={handleUnitChange} value={unitState}/>
        <div>
          <ErrorMessage errors={errors} name="q"/>
        </div>
      </form>
    </div>
  )
}
