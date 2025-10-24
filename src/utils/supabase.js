// Supabase utilities
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// RPC call helper function
export const callRPC = async (functionName, params = {}) => {
  try {
    const { data, error } = await supabase.rpc(functionName, params)

    if (error) {
      console.error(`RPC call ${functionName} failed:`, error)
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
    console.error(`Unexpected error in RPC call ${functionName}:`, err)
    return {
      success: false,
      error: err.message,
      data: null,
    }
  }
}

// Realtime subscription helper
export const subscribeToTable = (tableName, callback, filter = {}) => {
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

// File upload helper
export const uploadFile = async (file, path, bucket = 'uploads') => {
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
    console.error('File upload failed:', error)
    return {
      success: false,
      error: error.message,
    }
  }
}

// Delete file helper
export const deleteFile = async (path, bucket = 'uploads') => {
  try {
    const { error } = await supabase.storage.from(bucket).remove([path])

    if (error) {
      throw error
    }

    return { success: true }
  } catch (error) {
    console.error('File deletion failed:', error)
    return {
      success: false,
      error: error.message,
    }
  }
}
