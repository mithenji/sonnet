import { defineConfig } from 'vite'
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
      const entryPath = path.resolve(demoDir, demo, 'main.js')
      if (fs.existsSync(entryPath)) {
        entries[demo] = entryPath
      }
    })
  }

  return entries
}

export default defineConfig({
  plugins: [vue()],
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
        main: path.resolve(__dirname, 'ECMAScript/app.js'),
        // admin: path.resolve(__dirname, 'ECMAScript/admin.js'),
        ...getDemoEntries()
      },
      output: {
        // 根据入口名称生成目录结构
        entryFileNames: (chunkInfo) => {
          const name = chunkInfo.name
          if (name.startsWith('demos/')) {
            return `assets/${name}/[name]-[hash].js`
          }
          return 'assets/[name]-[hash].js'
        },
        chunkFileNames: (chunkInfo) => {
          const name = chunkInfo.name
          if (name.startsWith('demos/')) {
            return `assets/${name}/chunks/[name]-[hash].js`
          }
          return 'assets/chunks/[name]-[hash].js'
        },
        assetFileNames: (assetInfo) => {
          const name = assetInfo.name
          if (name && name.startsWith('demos/')) {
            return `assets/${name}/[name]-[hash][extname]`
          }
          return 'assets/[name]-[hash][extname]'
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