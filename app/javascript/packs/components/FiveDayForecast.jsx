import React from "react";

import { useAppState } from "./context_providers/AppState";

import { Header } from "./Header";

export const FiveDayForecast = () => {
  const [state] = useAppState();
  const forecastData = state["forecast"]
  console.log(forecastData);

  return (
    <Header text="Five-day Forecast"/>
  )
}
