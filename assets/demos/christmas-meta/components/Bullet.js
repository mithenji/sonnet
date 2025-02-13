import { BulletJs } from '../../../vendor/BulletJs.esm'

const getRandom2 = (min, max) => parseInt(Math.random() * (max - min + 1)) + min;

const danmuList = [
    "🎄 圣诞快乐，愿你的愿望都成真！",
    "🎅 圣诞节来了，一起嗨起来！",
    "❄️ 白雪纷飞，幸福加倍！",
    "🌟 点亮奇迹，温暖每个人的心！",
    "🎁 礼物满满，快乐翻倍！",
    // ... 其他弹幕内容 ...
];

export class Bullet {
    constructor(selector) {
        this.container = document.querySelector(selector)
        this.sendDanmuDom = document.querySelector('#sendDanmu')
        this.danmuInputDom = document.querySelector('#danmuInput')
        this.danmuList = danmuList;
        this.handleSendDanmu = this.handleSendDanmu.bind(this)
    }

    init() {
        this.eventInit()
        this.screen = new BulletJs('.screen', {
            trackHeight: 35,
            speed: undefined,
            pauseOnClick: true,
            pauseOnHover: true,
        })
    }

    destroy() {
        if (this.handler) {
            clearInterval(this.handler)
            this.handler = null
        }
        
        if (this.sendDanmuDom) {
            this.sendDanmuDom.removeEventListener('click', this.handleSendDanmu)
            this.danmuInputDom.removeEventListener('keydown', this.handleKeydown)
        }
        
        if (this.screen) {
            this.screen.destroy()
            this.screen = null
        }

        this.container = null
        this.sendDanmuDom = null
        this.danmuInputDom = null
        this.danmuList = null
    }

    sendAction() {
        this.handler = setInterval(() => {
            const index = getRandom2(0, this.danmuList.length - 1)
            const str = this.danmuList[index]
            const dom = `<span>${str}</span>`
            this.screen.push(dom)
        }, 1000)
    }

    escapeHTML(value) {
        return value.replace(/[&<>"'/]/g, char => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;',
            '/': '&#x2F;'
        })[char])
    }

    pauseBullet() {
        this.screen?.pause()
    }

    resumeBullet() {
        this.screen?.resume()
    }

    emitDanmu(text) {
        if (!this.screen) {
            console.warn('Bullet screen is not initialized')
            return
        }
        
        const safeText = this.escapeHTML(text || this.danmuInputDom.value)
        const danmuHtml = `<span class="danmu-item" style="color: #F78AE0;">${safeText}</span>`
        
        this.screen.push(danmuHtml, {
            onStart: (id, danmu) => {
                // 弹幕开始回调
            },
            onEnd: (id, danmu) => {
                // 弹幕结束回调
            }
        }, true)
    }

    handleKeydown = (e) => {
        if (e.key === 'Enter') {
            this.handleSendDanmu()
        }
    }

    eventInit() {
        this.sendDanmuDom.addEventListener('click', this.handleSendDanmu)
        this.danmuInputDom.addEventListener('keydown', this.handleKeydown)
    }

    handleSendDanmu() {
        const value = this.danmuInputDom.value
        if (value) {
            this.emitDanmu(value)
            this.danmuInputDom.value = ''
        } else {
            alert("请输入要发送的弹幕")
        }
    }
} 