import { vi } from 'vitest'
import { config } from '@vue/test-utils'

// Mock Supabase client - define mock before importing
const mockSupabase = {
  auth: {
    getSession: vi.fn(),
    onAuthStateChange: vi.fn(),
    signInWithPassword: vi.fn(),
    signOut: vi.fn(),
  },
  from: vi.fn(),
  rpc: vi.fn(),
}

vi.mock('@/lib/supabase', () => ({
  supabase: mockSupabase,
}))

// Global test configuration
config.global.stubs = {
  'n-config-provider': true,
  'n-dialog-provider': true,
  'n-message-provider': true,
  'n-icon': true,
  'router-link': true,
  'router-view': true,
}
