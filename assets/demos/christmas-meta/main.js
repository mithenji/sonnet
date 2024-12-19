import './styles/index.css'
import { ChristmasScene } from './scene.js'

// 等待 DOM 加载完成
document.addEventListener('DOMContentLoaded', () => {
    const app = new ChristmasScene('#container-christmas-meta')
    app.init()

    // 获取表单元素
    const registerUserForm = document.getElementById('registerUserForm')
    const submitButton = document.getElementById('submitButton')
    const termsCheckbox = document.getElementById('terms')

    // 初始禁用提交按钮
    submitButton.disabled = true

    // 监听表单字段和复选框的变化
    const formFields = ['nickname', 'email', 'country', 'phone']
    formFields.forEach(field => {
        document.getElementById(field).addEventListener('input', validateForm)
    })
    termsCheckbox.addEventListener('change', validateForm)

    // 表单验证函数
    function validateForm() {
        const nickname = document.getElementById('nickname').value.trim()
        const email = document.getElementById('email').value.trim()
        const country = document.getElementById('country').value.trim()
        const phone = document.getElementById('phone').value.trim()
        const termsAccepted = termsCheckbox.checked

        // 简单校验：检查字段是否为空
        const isFormValid = nickname && email && country && phone && termsAccepted

        // 启用或禁用提交按钮
        submitButton.disabled = !isFormValid
    }

    // 监听表单提交事件
    registerUserForm.addEventListener('submit', (event) => {
        event.preventDefault() // 阻止默认提交行为

        // 获取表单字段的值
        const nickname = document.getElementById('nickname').value
        const email = document.getElementById('email').value
        const country = document.getElementById('country').value
        const phone = document.getElementById('phone').value
        const terms = document.getElementById('terms').checked

        // 打印表单字段的值
        console.log('Nickname:', nickname)
        console.log('Email:', email)
        console.log('Country:', country)
        console.log('Phone:', phone)
        console.log('Terms accepted:', terms)

        // 在这里可以添加进一步的处理逻辑，例如发送数据到服务器
    });
}) 