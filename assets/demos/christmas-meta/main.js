import './styles/index.css'
import { ChristmasScene } from './scene.js'

// 等待 DOM 加载完成
document.addEventListener('DOMContentLoaded', () => {
    const app = new ChristmasScene('#demo-christmas-meta')
    app.init()
}) 