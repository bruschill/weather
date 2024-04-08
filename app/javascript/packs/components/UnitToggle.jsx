import React from 'react'
import PropTypes from 'prop-types'
import { Switch } from '@mui/material'

export const UnitToggle = ({ onChange, value }) => {
  return (
    <>
      °F
      <Switch onChange={onChange} value={value}/>
      °C
    </>
  )
}

UnitToggle.propTypes = {
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired
}
