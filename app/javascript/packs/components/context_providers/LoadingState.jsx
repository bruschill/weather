import React, { createContext, useContext, useState } from 'react'
import PropTypes from 'prop-types'

export const LoadingStateContext = createContext({})

export function LoadingProvider ({ children }) {
  const value = useState({ isLoading: false, loaded: false })
  return (
    <LoadingStateContext.Provider value={value}>
      {children}
    </LoadingStateContext.Provider>
  )
}

export function useLoadingState () {
  const context = useContext(LoadingStateContext)
  if (!context) {
    throw new Error('useAppState must be used within the AppProvider')
  }
  return context
}

LoadingProvider.propTypes = {
  children: PropTypes.node
}
