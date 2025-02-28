import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import fs from 'fs'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

// 自动扫描指定目录获取所有入口
function getEntries(directories = ['demos']) {
  const entries = {}
  
  directories.forEach(dir => {
    const fullPath = path.resolve(__dirname, dir)
    
    if (fs.existsSync(fullPath)) {
      const subDirs = fs.readdirSync(fullPath, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name)

      subDirs.forEach(subDir => {
        const jsxPath = path.resolve(fullPath, subDir, 'main.jsx')
        const jsPath = path.resolve(fullPath, subDir, 'main.js')
        
        if (fs.existsSync(jsxPath)) {
          entries[`${dir}/${subDir}`] = jsxPath
        } else if (fs.existsSync(jsPath)) {
          entries[`${dir}/${subDir}`] = jsPath
        }
      })
    }
  })

  return entries
}

// 配置需要扫描的目录
const scanDirectories = ['demos', 'main']

// 创建一个映射表，用于在构建时识别文件所属的模块
function createModuleMap() {
  const moduleMap = new Map()
  
  scanDirectories.forEach(dir => {
    const fullPath = path.resolve(__dirname, dir)
    
    if (fs.existsSync(fullPath)) {
      const subDirs = fs.readdirSync(fullPath, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name)
        
      subDirs.forEach(subDir => {
        // 将模块路径添加到映射表中
        moduleMap.set(`${dir}/${subDir}`, {
          dir,
          subDir
        })
      })
    }
  })
  
  return moduleMap
}

const moduleMap = createModuleMap()

// 辅助函数：根据文件名或路径确定所属模块
function getModuleInfo(filePath) {
  if (!filePath) return null
  
  // 尝试从路径中匹配模块信息
  for (const [modulePath, info] of moduleMap.entries()) {
    if (filePath.includes(modulePath)) {
      return info
    }
  }
  
  return null
}

export default defineConfig({
  plugins: [
    react(),
    vue(),
    // 添加自定义插件，用于收集和处理模块信息
    {
      name: 'vite-plugin-module-assets',
      apply: 'build',
      configResolved(config) {
        console.log('构建配置已解析，扫描目录:', scanDirectories);
      },
      buildStart() {
        console.log('构建开始，模块映射表大小:', moduleMap.size);
        for (const [key, value] of moduleMap.entries()) {
          console.log(`- 模块: ${key}, 目录: ${value.dir}, 子目录: ${value.subDir}`);
        }
      },
      // 在生成资源文件时，记录资源文件与模块的关系
      generateBundle(options, bundle) {
        console.log('生成bundle, 资源文件数量:', Object.keys(bundle).length);
      }
    }
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
    assetsDir: '',
    cssCodeSplit: true,
    manifest: true,
    sourcemap: true,
    rollupOptions: {
      input: {
        ...getEntries(scanDirectories)
      },
      output: {
        entryFileNames: (chunkInfo) => {
          if (chunkInfo.facadeModuleId) {
            const moduleInfo = getModuleInfo(chunkInfo.facadeModuleId)
            if (moduleInfo) {
              const { dir, subDir } = moduleInfo
              return `${dir}/${subDir}/${subDir}-[hash].js`
            }
          }
          return 'assets/main-[hash].js'
        },
        chunkFileNames: (chunkInfo) => {
          if (chunkInfo.facadeModuleId) {
            const moduleInfo = getModuleInfo(chunkInfo.facadeModuleId)
            if (moduleInfo) {
              const { dir, subDir } = moduleInfo
              return `${dir}/${subDir}/chunks/${subDir}-[hash].js`
            }
          }
          return 'assets/chunks/main-[hash].js'
        },
        assetFileNames: (assetInfo) => {
          // 获取文件扩展名
          let extType = '';
          
          // 简化日志输出，只记录关键信息
          console.log('处理资源:', {
            names: assetInfo.names,
            type: assetInfo.type,
            hasOriginalFileNames: !!assetInfo.originalFileNames?.length
          });
          
          // 从文件名获取扩展名 - 优先使用标准属性
          if (assetInfo.names && assetInfo.names.length > 0) {
            const name = assetInfo.names[0];
            const extMatch = name.match(/\.([^.]+)$/);
            if (extMatch) {
              extType = extMatch[1];
            }
          }
          
          // 尝试识别资源所属的模块
          let moduleDir = '';
          let moduleSubDir = '';
          
          // 从多种信息识别模块 - 优先使用originalFileNames
          const identifyModule = () => {
            // 1. 从originalFileNames识别 (Rollup 4.20.0+)
            if (assetInfo.originalFileNames && assetInfo.originalFileNames.length > 0) {
              const originalPath = assetInfo.originalFileNames[0];
              for (const [modulePath, info] of moduleMap.entries()) {
                if (originalPath.includes(`/${info.dir}/${info.subDir}/`)) {
                  moduleDir = info.dir;
                  moduleSubDir = info.subDir;
                  console.log(`模块识别成功: ${moduleDir}/${moduleSubDir} (通过originalFileNames)`);
                  return true;
                }
              }
            }
            
            // 2. 从moduleId识别 (兼容性方法)
            if (assetInfo.moduleId) {
              const moduleInfo = getModuleInfo(assetInfo.moduleId);
              if (moduleInfo) {
                moduleDir = moduleInfo.dir;
                moduleSubDir = moduleInfo.subDir;
                console.log(`模块识别成功: ${moduleDir}/${moduleSubDir} (通过moduleId)`);
                return true;
              }
            }
            
            // 3. 从names识别 (标准方法)
            if (assetInfo.names && assetInfo.names.length > 0) {
              for (const name of assetInfo.names) {
                for (const [modulePath, info] of moduleMap.entries()) {
                  if (name.includes(info.subDir)) {
                    moduleDir = info.dir;
                    moduleSubDir = info.subDir;
                    console.log(`模块识别成功: ${moduleDir}/${moduleSubDir} (通过names)`);
                    return true;
                  }
                }
              }
            }
            
            return false;
          };
          
          // 识别模块
          const moduleIdentified = identifyModule();
          
          // 根据文件类型和模块信息构建输出路径
          // 使用标准占位符: [name], [hash], [ext], [extname]
          
          // CSS 文件
          if (/css/.test(extType)) {
            if (moduleIdentified) {
              return `${moduleDir}/${moduleSubDir}/styles/${moduleSubDir}-[hash][extname]`;
            }
            return 'assets/styles/[name]-[hash][extname]';
          }
          
          // 媒体文件
          if (/mp4|webm|ogg/.test(extType)) {
            if (moduleIdentified) {
              return `${moduleDir}/${moduleSubDir}/media/[name]-[hash][extname]`;
            }
            return 'assets/media/[name]-[hash][extname]';
          }
          
          // 图片文件
          if (/png|jpe?g|gif|svg|webp|avif/.test(extType)) {
            if (moduleIdentified) {
              return `${moduleDir}/${moduleSubDir}/images/[name]-[hash][extname]`;
            }
            return 'assets/images/[name]-[hash][extname]';
          }
          
          // 字体文件
          if (/woff2?|eot|ttf|otf/.test(extType)) {
            if (moduleIdentified) {
              return `${moduleDir}/${moduleSubDir}/fonts/[name]-[hash][extname]`;
            }
            return 'assets/fonts/[name]-[hash][extname]';
          }
          
          // 其他文件 - 使用标准占位符
          if (moduleIdentified) {
            return `${moduleDir}/${moduleSubDir}/assets/[name]-[hash][extname]`;
          }
          
          // 默认输出路径 - 使用Rollup默认模式
          return 'assets/[name]-[hash][extname]';
        }
      }
    }
  },
  server: {
    origin: 'http://0.0.0.0:5175',
    strictPort: true,
    port: 5175,
    hmr: {
      host: '0.0.0.0',
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