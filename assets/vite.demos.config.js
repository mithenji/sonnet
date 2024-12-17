import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import fs from 'fs'

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
        entries[`demos/${demo}`] = entryPath
      }
    })
  }

  return entries
}

export default defineConfig({
  plugins: [vue()],
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