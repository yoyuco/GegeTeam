// src/stores/auth.ts
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import type { User, Session } from '@supabase/supabase-js'

export const useAuth = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    subscription: null as any, // giữ ref để huỷ nếu cần
  }),

  actions: {
    async init() {
      // lấy user hiện tại
      const { data: { user } } = await supabase.auth.getUser()
      this.user = user ?? null

      // lắng nghe thay đổi session (KHÔNG trả về giá trị)
      const { data: { subscription } } = supabase.auth.onAuthStateChange(
        (_event, session: Session | null) => {
          this.user = session?.user ?? null
        }
      )
      this.subscription = subscription
    },

    async signIn(email: string, password: string) {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password })
      if (error) throw error
      this.user = data.user
    },

    async signOut() {
      await supabase.auth.signOut()
      this.user = null
    },

    dispose() {
      this.subscription?.unsubscribe?.()
      this.subscription = null
    },
  },
})
