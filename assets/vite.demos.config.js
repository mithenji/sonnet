import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import react from '@vitejs/plugin-react'
import path from 'path'
import fs from 'fs'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

function getDemoEntries() {
  const demoDir = path.resolve(__dirname, 'demos')
  const entries = {}
  
  if (fs.existsSync(demoDir)) {
    const demos = fs.readdirSync(demoDir, { withFileTypes: true })
      .filter(dirent => dirent.isDirectory())
      .map(dirent => dirent.name)

    demos.forEach(demo => {
      const jsxPath = path.resolve(demoDir, demo, 'main.jsx')
      const jsPath = path.resolve(demoDir, demo, 'main.js')
      
      if (fs.existsSync(jsxPath)) {
        entries[`demos/${demo}`] = jsxPath
      } else if (fs.existsSync(jsPath)) {
        entries[`demos/${demo}`] = jsPath
      }
    })
  }

  return entries
}

export default defineConfig({
  plugins: [
    react(),
    vue()
  ],
  resolve: {
    extensions: ['.mjs', '.js', '.jsx', '.json', '.vue']
  },
  optimizeDeps: {
    include: ['react', 'react-dom']
  },
  esbuild: {
    loader: 'jsx',
    include: /.*\.jsx$/,
    exclude: [],
  },
  css: {
    postcss: {
      plugins: [
        tailwindcss(),
        autoprefixer()
      ]
    }
  },
  build: {
    target: 'esnext',
    outDir: '../priv/static/demos',
    emptyOutDir: true,
    rollupOptions: {
      input: getDemoEntries(),
      output: {
        entryFileNames: '[name]/[name]-[hash].js',
        chunkFileNames: '[name]/chunks/[name]-[hash].js',
        assetFileNames: '[name]/assets/[name]-[hash][extname]'
      }
    },
    assetsDir: 'assets',
  }
}) 