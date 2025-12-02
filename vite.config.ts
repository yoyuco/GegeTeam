import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import path from 'node:path'

export default defineConfig({
  plugins: [vue(), tailwindcss()],
  resolve: {
    alias: { '@': path.resolve(__dirname, 'src') },
  },
  // Suppress Vite console logs
  server: {
    hmr: {
      overlay: false
    }
  },
  // Disable console logs for HMR updates
  clearScreen: false,
  logLevel: 'error' // Only show errors, suppress info and warnings
})
