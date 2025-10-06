import { describe, it, expect, beforeEach, vi } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { useAuth } from '../auth'

describe('Auth Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('initializes with loading state', () => {
    const auth = useAuth()
    expect(auth.loading).toBe(true)
    expect(auth.user).toBe(null)
    expect(auth.profile).toBe(null)
    expect(auth.userPermissions.size).toBe(0)
    expect(auth.assignments).toEqual([])
  })

  it('handles authentication state correctly', async () => {
    const { supabase } = await import('@/lib/supabase')

    // Mock getSession response
    vi.mocked(supabase.auth.getSession).mockResolvedValue({
      data: { session: { user: { id: '123', email: 'test@example.com' } } },
      error: null,
    })

    // Mock RPC response for user context
    vi.mocked(supabase.rpc).mockResolvedValue({
      data: {
        roles: [],
        permissions: [],
      },
      error: null,
    })

    // Mock profiles query
    vi.mocked(supabase.from).mockReturnValue({
      select: vi.fn().mockReturnValue({
        eq: vi.fn().mockReturnValue({
          single: vi.fn().mockResolvedValue({
            data: { id: '123', display_name: 'Test User', status: 'active' },
            error: null,
          }),
        }),
      }),
    } as unknown as ReturnType<typeof vi.mocked<typeof supabase.from>>)

    // Mock onAuthStateChange
    const mockOnAuthStateChange = vi
      .fn()
      .mockReturnValue({ data: { subscription: { unsubscribe: vi.fn() } } })
    vi.mocked(supabase.auth.onAuthStateChange).mockImplementation(mockOnAuthStateChange)

    const auth = useAuth()
    await auth.init()

    expect(auth.loading).toBe(false)
    expect(auth.user).toEqual({ id: '123', email: 'test@example.com' })
    expect(auth.profile).toEqual({ id: '123', display_name: 'Test User', status: 'active' })
  })

  it('checks permissions correctly', () => {
    const auth = useAuth()

    // Set loading to false to allow permission checking
    auth.loading = false

    // Add permission to the Set
    auth.userPermissions.add('orders:view_all@*@*')

    expect(auth.hasPermission('orders:view_all')).toBe(true)
    expect(auth.hasPermission('orders:create')).toBe(false)
  })

  it('handles no session correctly', async () => {
    const { supabase } = await import('@/lib/supabase')

    // Mock no session
    vi.mocked(supabase.auth.getSession).mockResolvedValue({
      data: { session: null },
      error: null,
    })

    // Mock onAuthStateChange
    const mockOnAuthStateChange = vi
      .fn()
      .mockReturnValue({ data: { subscription: { unsubscribe: vi.fn() } } })
    vi.mocked(supabase.auth.onAuthStateChange).mockImplementation(mockOnAuthStateChange)

    const auth = useAuth()
    await auth.init()

    expect(auth.loading).toBe(false)
    expect(auth.user).toBe(null)
    expect(auth.profile).toBe(null)
    expect(auth.userPermissions.size).toBe(0)
    expect(auth.assignments).toEqual([])
  })

  it('signs out correctly', async () => {
    const { supabase } = await import('@/lib/supabase')

    // Mock signOut
    vi.mocked(supabase.auth.signOut).mockResolvedValue({ error: null })

    const auth = useAuth()

    // Set some initial state
    auth.user = { id: '123', email: 'test@example.com' } as { id: string; email: string }
    auth.profile = { id: '123', display_name: 'Test User', status: 'active' }
    auth.userPermissions.add('orders:view_all@*@*')
    auth.assignments = [
      { role_code: 'admin', role_name: 'Admin' } as { role_code: string; role_name: string },
    ]

    await auth.signOut()

    expect(auth.user).toBe(null)
    expect(auth.profile).toBe(null)
    expect(auth.userPermissions.size).toBe(0)
    expect(auth.assignments).toEqual([])
  })
})
