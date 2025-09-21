// path: src/stores/auth.ts
import { defineStore } from 'pinia';
import { supabase } from '@/lib/supabase';
import type { User } from '@supabase/supabase-js';

// CẬP NHẬT: Kiểu dữ liệu cho payload trả về từ RPC
type RoleForUI = {
  role_code: string;
  role_name: string;
  game_code: string | null;
  game_name: string | null;
  business_area_code: string | null;
  business_area_name: string | null;
};

type AuthContextPayload = {
  roles: RoleForUI[];
  permissions: { permission_code: string; game_code: string | null; business_area_code: string | null }[];
};

export const useAuth = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    loading: true,
    userPermissions: new Set<string>(),
    assignments: [] as RoleForUI[], // THÊM LẠI: Mảng để hiển thị UI
  }),

  getters: {
    isAuthenticated: (state) => !!state.user && !state.loading,
  },

  actions: {
    async init() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          this.user = session.user;
          await this.fetchUserContext();
        } else {
          this.user = null;
          this.userPermissions.clear();
          this.assignments = []; // CẬP NHẬT
        }
        supabase.auth.onAuthStateChange(async (_event, newSession) => {
          const userChanged = this.user?.id !== newSession?.user?.id;
          this.user = newSession?.user ?? null;
          if (this.user && userChanged) {
            await this.fetchUserContext();
          } else if (!this.user) {
            this.userPermissions.clear();
            this.assignments = []; // CẬP NHẬT
          }
        });
      } catch (error) {
        console.error("Lỗi trong quá trình khởi tạo Auth Store:", error);
        this.user = null;
        this.userPermissions.clear();
        this.assignments = []; // CẬP NHẬT
      } finally {
        this.loading = false;
      }
    },

    async fetchUserContext() {
      if (!this.user) return;
      
      const { data, error } = await supabase.rpc('get_user_auth_context_v1');
      if (error) {
        console.error("Không thể lấy context phân quyền:", error);
        this.userPermissions.clear();
        this.assignments = []; // CẬP NHẬT
        return;
      }

      const payload = data as AuthContextPayload;
      
      // 1. Lưu assignments để hiển thị UI
      this.assignments = payload?.roles || [];

      // 2. Xử lý permissions để kiểm tra quyền
      const newPermissions = new Set<string>();
      if (payload?.permissions) {
        payload.permissions.forEach(p => {
          const game = p.game_code || '*';
          const area = p.business_area_code || '*';
          newPermissions.add(`${p.permission_code}@${game}@${area}`);
        });
      }
      this.userPermissions = newPermissions;
    },

    async signIn(email: string, password: string) {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
      if (data.user) {
        this.user = data.user;
        await this.fetchUserContext();
      }
    },

    async signOut() {
      await supabase.auth.signOut();
      this.user = null;
      this.userPermissions.clear();
      this.assignments = []; // CẬP NHẬT
    },

    hasPermission(code: string, context?: { game_code?: string; business_area_code?: string }): boolean {
      if (this.loading || !code) return false;
      const game = context?.game_code || '*';
      const area = context?.business_area_code || '*';
      if (this.userPermissions.has(`${code}@${game}@${area}`)) return true;
      if (this.userPermissions.has(`${code}@${game}@*`)) return true;
      if (this.userPermissions.has(`${code}@*@${area}`)) return true;
      if (this.userPermissions.has(`${code}@*@*`)) return true;
      return false;
    }
  },
});