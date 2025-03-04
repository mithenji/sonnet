import React, { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
// import '../styles/base.css'  // 使用共享样式
import App from './App'

createRoot(document.getElementById('demo-react')).render(
  <StrictMode>
    <App />
  </StrictMode>
)
