/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    '../demos/**/*.{js,jsx,ts,tsx,vue,html}',
    '../main/**/*.{js,jsx,ts,tsx,vue,html}',
    '../lib/**/*.{ex,heex}',
    '../src/**/*.{js,jsx,ts,tsx,vue,html}',
    '../../lib/**/*.{ex,heex}'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
  corePlugins: {
    preflight: true,
  }
}
