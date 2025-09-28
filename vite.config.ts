import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import path from 'node:path'

export default defineConfig({
  plugins: [vue(), tailwindcss()],
  css: { transformer: 'postcss' },
  resolve: { alias: { '@': path.resolve(__dirname, 'src') } },
})
