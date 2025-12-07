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

// Export createClient for admin operations
export { createClient }

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

// Work proofs upload helper - specialized for currency proof files
export const uploadWorkProof = async (
  file: File,
  path: string,
  metadata: Record<string, any> = {},
  ownerId?: string
) => {
  try {
    // Check if work-proofs bucket exists and is accessible (note: with dash)
    const { data: bucketData, error: bucketError } = await supabase.storage
      .getBucket('work-proofs')
      .catch(() => ({ data: null, error: { message: 'Bucket not found' } }))

    if (bucketError || !bucketData) {
      console.error('Work proofs bucket not accessible:', bucketError)
      return {
        success: false,
        error: 'Work proofs storage not available. Please contact administrator.',
      }
    }

    // Prepare metadata with required fields
    const enhancedMetadata = {
      ...metadata,
      owner_id: ownerId || supabase.auth.getUser()?.data.user?.id,
      uploaded_at: new Date().toISOString(),
      file_size: file.size,
      mime_type: file.type,
      file_name: file.name,
    }

    // Upload to work-proofs bucket with enhanced metadata (note: with dash)
    const { data, error } = await supabase.storage
      .from('work-proofs')
      .upload(path, file, {
        cacheControl: '3600',
        upsert: false,
        metadata: enhancedMetadata,
      })

    if (error) {
      console.error('Work proof upload failed:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    // Get public URL
    const {
      data: { publicUrl },
    } = supabase.storage.from('work-proofs').getPublicUrl(data.path)

    return {
      success: true,
      path: data.path,
      publicUrl,
      metadata: enhancedMetadata,
    }
  } catch (error) {
    console.error('Work proof upload error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Work proof upload failed',
    }
  }
}

// Get work proof public URL (note: with dash)
export const getWorkProofUrl = (path: string) => {
  return supabase.storage
    .from('work-proofs')
    .getPublicUrl(path)
}

// Delete work proof (note: with dash)
export const deleteWorkProof = async (path: string) => {
  try {
    const { error } = await supabase.storage.from('work-proofs').remove([path])

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
