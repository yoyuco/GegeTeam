// path: src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL as string
const anon = import.meta.env.VITE_SUPABASE_ANON_KEY as string

export const supabase = createClient(url, anon, {
  auth: {
    persistSession: true,        // LƯU SESSION vào storage
    autoRefreshToken: true,      // Tự refresh
    detectSessionInUrl: true,    // Lấy session khi OAuth redirect về
    storageKey: 'gege-auth'      // key riêng để tránh xung đột
  },
  global: {
    headers: { 'x-application-name': 'my-admin' }
  }
})
