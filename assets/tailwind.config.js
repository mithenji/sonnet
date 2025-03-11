/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './main/**/*.{js,jsx,ts,tsx,vue}',
    './lib/**/*.{ex,heex}',
    './src/**/*.{js,jsx,ts,tsx,vue}',
    '../lib/**/*.{ex,heex}'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
  // 启用 JIT 模式
  mode: 'jit'
}
