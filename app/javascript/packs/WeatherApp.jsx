import React from 'react';

import { AppProvider } from "./components/context_providers/AppState";
import { LoadingProvider } from "./components/context_providers/LoadingState";

import { Header } from "./components/Header";
import { AddressInput } from "./components/AddressInput";
import { WeatherBox } from "./components/WeatherBox";

import "./weather_app.css";
import { createRoot } from "react-dom/client";

const WeatherApp = () => {
  return (
    <div className="container">
      <div></div>

      <div>
        <AppProvider>
          <Header/>
          <LoadingProvider>
            <AddressInput/>
            <WeatherBox/>
          </LoadingProvider>
        </AppProvider>
      </div>

      <div></div>
    </div>
  );
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.body.appendChild(document.createElement('div'))
  const root = createRoot(container)

  root.render(<WeatherApp/>)
})
