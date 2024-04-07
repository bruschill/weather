import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom';

import "./weather_app.css";
import { useForm } from "react-hook-form";

const WeatherApp = () => {
  return (
    <div className="container">
      <div></div>

      <div>
        <Header/>
        <AddressInput/>
        <CurrentWeather/>
        <FiveDayForecast/>
      </div>

      <div></div>
    </div>
  );
}

const Header = ({ text }) => {
  return (
    <h1>{text}</h1>
  )
}

const AddressInput = () => {
  const [address, setAddress] = useState(null);
  const {
    handleSubmit,
    formState: { errors },
    register
  } = useForm({ defaultValues: address, mode: "onSubmit" });

  useEffect(() => {
    const requestOptions = {
      headers: {
        "Content-Type": "application/json"
      }
    }

    if (address) {
      console.log(address)
      fetch(`/weather?q=${address}`, requestOptions)
        .then((response) => response.json())
        .then((data) => {
          console.log(data)
        })
        .catch((error) => console.log(error));
    }
  }, [address])

  const onSubmit = (data) => {
    setAddress(data['q'])
  }

  return (
    <div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <input
          {...register('q')}
          type="text"
          id="q"
          name="q"
          placeholder="Enter your address"
        />
      </form>
    </div>
  )
}

const CurrentWeather = () => {
  return (
    <Header text="Current Weather"/>
  )
}

const FiveDayForecast = () => {
  return (
    <Header text="Five-day Forecast"/>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <WeatherApp/>,
    document.body.appendChild(document.createElement('div')),
  )
})
