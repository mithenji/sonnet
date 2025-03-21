import React, { useState } from 'react';
import reactLogo from '/static/images/react.svg'
import viteLogo from '/static/images/vite.svg'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="demo-container">
      <div className="flex flex-row items-center justify-center">
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="demo-card">
        <button className="demo-button" onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p className="mt-4">
          Edit <code>src/App.jsx</code> and save to test HMR
        </p>
      </div>
      <p className="mt-4 text-gray-600">
        Click on the Vite and React logos to learn more
      </p>
    </div>
  )
}

export default App
