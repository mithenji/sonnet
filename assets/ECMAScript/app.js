import '../css/app.css'
import { createApp } from 'vue'
import App from './App.vue'
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

// Phoenix LiveView 设置
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()
window.liveSocket = liveSocket

// Vue 应用设置
const app = createApp(App)
app.mount('#app')

