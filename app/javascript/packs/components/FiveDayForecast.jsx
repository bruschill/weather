import React from "react";

import { useAppState } from "./context_providers/AppState";

import { Header } from "./Header";

export const FiveDayForecast = () => {
  const [state] = useAppState();
  const forecastData = state["forecast"]

  return (
    <>
      <Header text="Five-day Forecast"/>
      {
        Object.entries(forecastData).map(([key, value]) => {
          return (
            <div>
              {value["day_name"]} -> H:{value["fahrenheit"]["temp_max"]}° L:{value["fahrenheit"]["temp_min"]}°
            </div>
          )
        })
      }

    </>
  )
}
