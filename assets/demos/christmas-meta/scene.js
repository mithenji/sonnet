// @ts-nocheck
import { Swiper } from 'swiper'
import { EffectFade } from 'swiper/modules'
import 'swiper/css'
import 'swiper/css/effect-fade'

import { Bullet } from './components/Bullet.js'

export class ChristmasScene {
  constructor(selector) {
    this.container = document.querySelector(selector)
    this.snowflakes = []
    this.decorations = ['🎈', '⭐', '🎁']
    this.swiper = null
    this.resizeObserver = null
    // 添加按钮元素引用
    this.bulletCommentBtn = null
    this.backIndexBtns = null
    this.registerUserBtn = null
  }

  init() {
    // 设置容器尺寸
    this.setupContainer()
    // 创建场景容器
    this.createSceneContainer()
    // 初始化 Swiper
    this.initSwiper()
    // 监听窗口大小变化
    this.setupResizeListener()
    // 初始化按钮事件
    this.initButtonEvents()
    // 初始化弹幕组件
    this.initBullet() 
  }

  setupContainer() {
    if (this.container) {
      // 初始设置容器尺寸
      this.updateContainerSize()
    }
  }

  updateContainerSize() {
    // 获取视口尺寸
    const vh = window.innerHeight
    const vw = window.innerWidth
    
    // 设置容器尺寸
    this.container.style.width = `${vw}px`
    this.container.style.height = `${vh}px`
    
    // 确保容器始终保持在视口中心
    this.container.style.position = 'fixed'
    this.container.style.top = '0'
    this.container.style.left = '0'
    this.container.style.overflow = 'hidden'
  }

  setupResizeListener() {
    // 使用 ResizeObserver 监听容器尺寸变化
    this.resizeObserver = new ResizeObserver(() => {
      this.updateContainerSize()
      // 如果 swiper 已初始化，则更新它
      if (this.swiper) {
        this.swiper.update()
      }
    })

    this.resizeObserver.observe(this.container)

    // 监听窗口大小变化
    window.addEventListener('resize', () => {
      this.updateContainerSize()
    })
  }

  createSceneContainer() {
    const container = document.createElement('div')
    container.className = 'scene-container'
    this.container.appendChild(container)
    this.sceneContainer = container
  }

  initButtonEvents() {
    // 获取弹幕按钮元素
    this.bulletCommentBtn = document.getElementById('bullet-comment')
    // 获取所有返回首页按钮元素
    this.backIndexBtns = document.querySelectorAll('.back-index')
    // 获取注册用户按钮元素
    this.registerUserBtn = document.getElementById('register-user')
    
    if (this.bulletCommentBtn) {
      this.bulletCommentBtn.addEventListener('click', () => {
        if (this.swiper) {
          this.swiper.slideTo(1, 800)
        }
      })
    }

    // 为所有返回首页按钮添加事件监听
    if (this.backIndexBtns.length > 0) {
      this.backIndexBtns.forEach(btn => {
        btn.addEventListener('click', () => {
          if (this.swiper) {
            this.swiper.slideTo(0, 800)
          }
        })
      })
    }

    if (this.registerUserBtn) {
      this.registerUserBtn.addEventListener('click', () => {
        if (this.swiper) {
          this.swiper.slideTo(2, 800)
        }
      })
    }
  }

  initSwiper() {
    this.swiper = new Swiper('.christmas-swiper', {
      modules: [EffectFade],
      direction: 'horizontal',
      loop: false,
      effect: 'fade',
      fadeEffect: {
        crossFade: true
      },
      // 默认禁用所有触摸相关功能
      allowTouchMove: false,
      touchRatio: 0,
      simulateTouch: false,
      touchEventsTarget: false,
      preventClicks: true,
      preventClicksPropagation: true,
      touchStartPreventDefault: false,
      passiveListeners: true,
      
      autoplay: false,
      speed: 800,
      slidesPerView: 1,
      spaceBetween: 0,
      
      // 简化事件监听
      on: {
        init: function(swiper) {
          // 只在首页启用触摸
          swiper.allowTouchMove = swiper.activeIndex === 0
        },
        slideChange: (swiper) => {
          // 动态设置触摸响应
          swiper.allowTouchMove = swiper.activeIndex === 0
          
          // 当滑动到第二页时（index === 1）
          if (swiper.activeIndex === 1) {
            console.log('swiper.activeIndex === 1', this.bullet, swiper.activeIndex)
            if (!this.bullet) {
              this.initBullet();
              window.setTimeout(() => {
                this.bullet.sendAction();
                this.bullet.emitDanmu('欢迎来到弹幕页面！');
              }, 100);
            } else {
              this.bullet.sendAction();
              this.bullet.emitDanmu('欢迎来到弹幕页面！');
            }
          } else {
            // 离开弹幕页面时
            if (this.bullet) {
              this.bullet.pauseBullet();
              this.bullet.destroy();
              this.bullet = null;
            }
          }
        }
      }
    })

    // 添加触摸事件委托到容器
    const swiperContainer = document.querySelector('.christmas-swiper')
    if (swiperContainer) {
      swiperContainer.addEventListener('touchstart', this.handleTouch.bind(this), { passive: true })
      swiperContainer.addEventListener('touchmove', this.handleTouch.bind(this), { passive: true })
      swiperContainer.addEventListener('touchend', this.handleTouch.bind(this), { passive: true })
    }
  }

  handleTouch(event) {
    // 只在非首页时阻止触摸
    if (this.swiper && this.swiper.activeIndex !== 0) {
      event.stopPropagation()
    }
  }
  

  initBullet() {
    this.bullet = new Bullet('.screen')
    this.bullet.init()
  }
} 