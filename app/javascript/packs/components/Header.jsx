import React from 'react'
import PropTypes from 'prop-types'

export const Header = ({ text }) => {
  return (
    <h1>{text}</h1>
  )
}

Header.propTypes = {
  text: PropTypes.string
}
