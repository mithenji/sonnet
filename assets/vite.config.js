import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import fs from 'fs'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

// 自动扫描 demos 目录获取所有入口
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
    react({
      jsxRuntime: 'automatic',
    }),
    vue()
  ],
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
    outDir: '../priv/static',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        app: path.resolve(__dirname, 'main/app.js'),
        ...getDemoEntries()
      },
      output: {
        entryFileNames: (chunkInfo) => {
          if (chunkInfo.facadeModuleId.includes('demos/')) {
            const demoName = chunkInfo.facadeModuleId.match(/demos\/([^/]+)/)[1]
            return `assets/demos/${demoName}/${demoName}-[hash].js`
          }
          return 'assets/main/main-[hash].js'
        },
        chunkFileNames: (chunkInfo) => {
          if (chunkInfo.facadeModuleId.includes('demos/')) {
            const demoName = chunkInfo.facadeModuleId.match(/demos\/([^/]+)/)[1]
            return `assets/demos/${demoName}/chunks/${demoName}-[hash].js`
          }
          return 'assets/main/chunks/main-[hash].js'
        },
        assetFileNames: (assetInfo) => {
          if (assetInfo.fileName && assetInfo.fileName.includes('demos/')) {
            const demoName = assetInfo.fileName.match(/demos\/([^/]+)/)[1]
            return `assets/demos/${demoName}/${demoName}-[hash][extname]`
          }
          return 'assets/main/main-[hash][extname]'
        }
      }
    }
  },
  server: {
    origin: 'http://localhost:5175',
    strictPort: true,
    port: 5175,
    hmr: {
      host: 'localhost',
      protocol: 'ws',
      timeout: 30000,
      overlay: true,
      clientPort: 5175
    },
    watch: {
      usePolling: true,
      interval: 1000
    },
    process: {
      on: (event) => {
        if (event === 'SIGTERM' || event === 'SIGINT') {
          process.kill(process.pid, 'SIGTERM')
          setTimeout(() => {
            process.exit(0)
          }, 100)
        }
      }
    }
  }
}) 