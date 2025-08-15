// path: src/stores/auth.ts
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const useAuth = defineStore('auth', {
  state: () => ({
    user: null as any,
    session: null as any,
    loading: false
  }),
  actions: {
    async init() {
      // Khởi động: lấy session đã lưu
      const { data: { session } } = await supabase.auth.getSession()
      this.session = session
      this.user = session?.user ?? null

      // Lắng nghe thay đổi đăng nhập/đăng xuất
      supabase.auth.onAuthStateChange((_event, session) => {
        this.session = session
        this.user = session?.user ?? null
      })
    },

    async signOut() {
      this.loading = true
      try {
        await supabase.auth.signOut()
      } finally {
        this.loading = false
        // về trang đăng nhập
        window.location.href = '/login'
      }
    }
  }
})
