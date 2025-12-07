// path: src/stores/auth.ts
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import type { User } from '@supabase/supabase-js'

// CẬP NHẬT: Kiểu dữ liệu cho payload trả về từ RPC
type RoleForUI = {
  role_code: string
  role_name: string
  game_code: string | null
  game_name: string | null
  business_area_code: string | null
  business_area_name: string | null
}

type AuthContextPayload = {
  roles: RoleForUI[]
  permissions: {
    permission_code: string
    game_code: string | null
    business_area_code: string | null
  }[]
}

type UserProfile = {
  id: string
  display_name: string | null
  status: string | null
  // Thêm các trường khác từ bảng profiles nếu cần
}

export const useAuth = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    profile: null as UserProfile | null, // <<< THÊM STATE MỚI
    loading: true,
    userPermissions: new Set<string>(),
    assignments: [] as RoleForUI[],
    // Add raw permissions array for usePermissions composable
    rawPermissions: [] as { permission_code: string; game_code: string | null; business_area_code: string | null }[],
  }),

  getters: {
    isAuthenticated: (state) => !!state.user && !state.loading,
  },

  actions: {
    async init() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession()
        if (session?.user) {
          this.user = session.user
          await this.fetchUserContext()
        } else {
          this.user = null
          this.userPermissions.clear()
          this.assignments = [] // CẬP NHẬT
          this.rawPermissions = [] // Reset raw permissions
        }
        supabase.auth.onAuthStateChange(async (_event, newSession) => {
          const userChanged = this.user?.id !== newSession?.user?.id
          this.user = newSession?.user ?? null
          if (this.user && userChanged) {
            await this.fetchUserContext()
          } else if (!this.user) {
            this.userPermissions.clear()
            this.assignments = [] // CẬP NHẬT
            this.rawPermissions = [] // Reset raw permissions
          }
        })
      } catch (error) {
        console.error('Lỗi trong quá trình khởi tạo Auth Store:', error)
        this.user = null
        this.userPermissions.clear()
        this.assignments = [] // CẬP NHẬT
        this.rawPermissions = [] // Reset raw permissions
      } finally {
        this.loading = false
      }
    },

    async fetchUserContext() {
      if (!this.user) return

      // Sử dụng Promise.all để thực hiện các truy vấn song song
      const [contextRes, profileRes] = await Promise.all([
        supabase.rpc('get_user_auth_context_v1'),
        supabase
          .from('profiles')
          .select('id, display_name, status')
          .eq('auth_id', this.user.id)
          .single(),
      ])

      // Xử lý context phân quyền (như cũ)
      const { data: contextData, error: contextError } = contextRes
      if (contextError) {
        console.error('Không thể lấy context phân quyền:', contextError)
        this.userPermissions.clear()
        this.assignments = []
        this.rawPermissions = []
      } else {
        const payload = contextData as AuthContextPayload

        // 1. Lưu assignments để hiển thị UI
        this.assignments = payload?.roles || []

        // 2. Store raw permissions for usePermissions composable
        this.rawPermissions = payload?.permissions || []

        // 3. Xử lý permissions để kiểm tra quyền (backward compatibility)
        const newPermissions = new Set<string>()
        if (payload?.permissions) {
          payload.permissions.forEach((p) => {
            const game = p.game_code || '*'
            const area = p.business_area_code || '*'
            newPermissions.add(`${p.permission_code}@${game}@${area}`)
          })
        }
        this.userPermissions = newPermissions
        const { data: profileData, error: profileError } = profileRes
        if (profileError) {
          console.error('Không thể lấy thông tin profile:', profileError)
          this.profile = null
        } else {
          this.profile = profileData as UserProfile
        }
      }
    },

    async signIn(email: string, password: string) {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password })
      if (error) throw error
      if (data.user) {
        this.user = data.user
        await this.fetchUserContext()
      }
    },

    async signOut() {
      await supabase.auth.signOut()
      this.user = null
      this.profile = null // <<< RESET PROFILE KHI ĐĂNG XUẤT
      this.userPermissions.clear()
      this.assignments = []
      this.rawPermissions = [] // Reset raw permissions on signout
    },

    hasPermission(
      code: string,
      context?: { game_code?: string; business_area_code?: string }
    ): boolean {
      if (this.loading || !code) return false
      const game = context?.game_code || '*'
      const area = context?.business_area_code || '*'
      if (this.userPermissions.has(`${code}@${game}@${area}`)) return true
      if (this.userPermissions.has(`${code}@${game}@*`)) return true
      if (this.userPermissions.has(`${code}@*@${area}`)) return true
      if (this.userPermissions.has(`${code}@*@*`)) return true
      return false
    },
  },
})
