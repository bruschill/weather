import React from 'react';

import { useAppState } from "./context_providers/AppState";

import { Header } from "./Header";

export const CurrentWeather = () => {
  const [state] = useAppState();
  const currentData = state["current"]
  console.log(currentData)

  return (
    <Header text="Current Weather"/>
  )
}
