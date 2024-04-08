import React, { createContext, useContext, useState } from 'react'
import PropTypes from 'prop-types'

export const INITIAL_APP_STATE = {}

export const AppStateContext = createContext({})

export function AppProvider ({ children }) {
  const value = useState(INITIAL_APP_STATE)
  return (
    <AppStateContext.Provider value={value}>
      {children}
    </AppStateContext.Provider>
  )
}

export function useAppState () {
  const context = useContext(AppStateContext)
  if (!context) {
    throw new Error('useAppState must be used within the AppProvider')
  }
  return context
}

AppProvider.propTypes = {
  children: PropTypes.node
}
