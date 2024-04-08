import React, { createContext, useContext, useState } from 'react'
import PropTypes from 'prop-types'

export const UnitStateContext = createContext({})

export function UnitProvider ({ children }) {
  const value = useState('f')
  return (
    <UnitStateContext.Provider value={value}>
      {children}
    </UnitStateContext.Provider>
  )
}

export function useUnitState () {
  const context = useContext(UnitStateContext)
  if (!context) {
    throw new Error('useAppState must be used within the AppProvider')
  }
  return context
}

UnitProvider.propTypes = {
  children: PropTypes.node
}
