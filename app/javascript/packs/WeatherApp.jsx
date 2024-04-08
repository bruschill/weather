import React from 'react'
import { createRoot } from 'react-dom/client'

import { AppProvider } from './components/context_providers/AppState'
import { LoadingProvider } from './components/context_providers/LoadingState'
import { UnitProvider } from './components/context_providers/UnitState'

import { Header } from './components/Header'
import { AddressInput } from './components/AddressInput'
import { WeatherBox } from './components/WeatherBox'

import './weather_app.css'

const WeatherApp = () => {
  return (
    <div className="container">
      <div></div>

      <div>
        <AppProvider>
          <Header/>
          <LoadingProvider>
            <UnitProvider>
              <AddressInput/>
              <WeatherBox/>
            </UnitProvider>
          </LoadingProvider>
        </AppProvider>
      </div>

      <div></div>
    </div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.body.appendChild(document.createElement('div'))
  const root = createRoot(container)

  root.render(<WeatherApp/>)
})
