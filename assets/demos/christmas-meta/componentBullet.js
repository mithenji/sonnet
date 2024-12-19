import { BulletJs } from '../../vendor/BulletJs.esm'

const getRandom2 = (min, max) => parseInt(Math.random() * (max - min + 1)) + min;

const danmuList = [
    "🎄 圣诞快乐，愿你的愿望都成真！",
    "🎅 圣诞节来了，一起嗨起来！",
    "❄️ 白雪纷飞，幸福加倍！",
    "🌟 点亮奇迹，温暖每个人的心！",
    "🎁 礼物满满，快乐翻倍！",
    "🍪 热可可配甜甜圈，甜蜜圣诞！",
    "🎶 圣诞歌声传遍每个角落！",
    "🌟 星星闪耀，圣诞奇迹就在眼前！",
    "🎄 圣诞树下的愿望都实现！",
    "🎅 驯鹿飞过，带来满满的幸福！",
    "🌟 每颗星都在为你许愿，圣诞快乐！",
    "❄️ 冬日暖阳，圣诞好时光！",
    "🎁 礼物拆不停，惊喜一整天！",
    "🎄 围着圣诞树，欢笑乐不停！",
    "🎅 圣诞老人带着祝福来了！",
    "🌟 闪烁的灯光点亮每一颗心！",
    "🍪 圣诞袜装满甜蜜，幸福直达心底！",
    "❄️ 冬夜里，圣诞的温暖融化冰雪！",
    "🎶 唱起圣诞歌，愿你快乐到永远！",
    "🎄 圣诞夜晚，奇迹从这里开始！",
]

// @ts-nocheck
export class ComponentBullet {
    constructor(selector) {
        this.container = document.querySelector(selector)
        this.sendDanmuDom = document.querySelector('#sendDanmu')
        this.danmuInputDom = document.querySelector('#danmuInput')
        this.danmuList = danmuList;
        this.handleSendDanmu = this.handleSendDanmu.bind(this)
    }

    init() {
        this.eventInit();
        this.screen = new BulletJs('.screen', {
            trackHeight: 35,
            speed: undefined,
            pauseOnClick: true,
            pauseOnHover: true,
        });
    }
    destroy() {
        if (this.handler) {
            clearInterval(this.handler)
            this.handler = null
        }
        
        if (this.sendDanmuDom) {
            this.sendDanmuDom.removeEventListener('click', this.handleSendDanmu)
            this.danmuInputDom.removeEventListener('keydown', (e) => {
                if (e.key === 'Enter') {
                    this.handleSendDanmu()
                }
            })
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
            const index = getRandom2(0, 19);
            const str = danmuList[index];
            const dom = `<span>${str}</span>`
            this.screen.push(dom)
        }, 1000);
    }
     // 新增的 escapeHTML 方法
    escapeHTML(value) {
        return value.replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/\"/g, '&quot;')
                    .replace(/\'/g, '&#39;')
                    .replace(/\//g, '&#x2F;');
    }

    pauseBullet() {
        if (this.screen) {
            this.screen.pause()
        }
    }

    resumeBullet() {
        if (this.screen) {
            this.screen.resume()
        }
    }

    // 新增的 emit 方法
    emitDanmu(escapeHTML) {
        if (!this.screen) {
            console.warn('Bullet screen is not initialized');
            return;
        }
        
        const text = escapeHTML ? this.escapeHTML(escapeHTML) : this.escapeHTML(this.danmuInputDom.value);
        const danmuHtml = `<span class="danmu-item" style="color: #F78AE0;">${text}</span>`;
        this.screen.push(danmuHtml, {
            onStart: (id, danmu) => {
                // console.log('实例的方法onStart----->', 'id------->', id, 'danmu-------->', danmu)
            },
            onEnd: (id, danmu) => {
                // console.log('实例的方法onEnd----->', 'id------->', id, 'danmu-------->', danmu)
            }
        }, true);
    }
    eventInit() {
        this.sendDanmuDom.addEventListener('click', this.handleSendDanmu)
        this.danmuInputDom.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                this.handleSendDanmu()
            }
        })
    }

    handleSendDanmu() {
        const value = this.danmuInputDom.value
        const escapeHTML = this.escapeHTML(value)
        console.log('escapeHTML--->', escapeHTML)
        if (value) {
            this.emitDanmu(escapeHTML)
            this.danmuInputDom.value = '';
        } else {
            alert("请输入要发送的弹幕")
        }
    }
}


