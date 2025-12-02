// path: src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL as string
const anon = import.meta.env.VITE_SUPABASE_ANON_KEY as string

export const supabase = createClient(url, anon, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
  global: {
    headers: { 'x-application-name': 'gegeteam' },
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
})

// File upload helper
export const uploadFile = async (file: File, path: string, bucket = 'uploads') => {
  try {
    const { data, error } = await supabase.storage.from(bucket).upload(path, file)

    if (error) {
      throw error
    }

    const {
      data: { publicUrl },
    } = supabase.storage.from(bucket).getPublicUrl(data.path)

    return {
      success: true,
      path: data.path,
      publicUrl,
    }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Upload failed',
    }
  }
}

// Delete file helper
export const deleteFile = async (path: string, bucket = 'uploads') => {
  try {
    const { error } = await supabase.storage.from(bucket).remove([path])

    if (error) {
      throw error
    }

    return { success: true }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Delete failed',
    }
  }
}

// RPC call helper function
export const callRPC = async (functionName: string, params = {}) => {
  try {
    const { data, error } = await supabase.rpc(functionName, params)

    if (error) {
      return {
        success: false,
        error: error.message,
        data: null,
      }
    }

    return {
      success: true,
      error: null,
      data: data,
    }
  } catch (err) {
    return {
      success: false,
      error: err instanceof Error ? err.message : 'RPC call failed',
      data: null,
    }
  }
}

// Realtime subscription helper
export const subscribeToTable = (
  tableName: string,
  callback: (payload: any) => void,
  filter = {}
) => {
  return supabase
    .channel(`${tableName}-changes`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: tableName,
        filter: filter,
      },
      (payload) => {
        callback(payload)
      }
    )
    .subscribe()
}

// Expose to window for debugging
if (typeof window !== 'undefined') {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  ;(window as any).supabase = supabase
}
