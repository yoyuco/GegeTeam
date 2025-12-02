import { ref } from 'vue'

// Cache TTL configuration
const CACHE_TTL = 5 * 60 * 1000 // 5 minutes

interface CacheItem<T> {
  data: T
  timestamp: number
}

interface GameServerItem {
  code: string
  name: string
}

// Generic cache storage
const cache = new Map<string, CacheItem<any>>()

// Helper function to check if cache is valid
const isCacheValid = (timestamp: number): boolean => {
  return Date.now() - timestamp < CACHE_TTL
}

// Helper function to get cached data
const getCachedData = <T>(key: string): T | null => {
  const cached = cache.get(key)
  if (cached && isCacheValid(cached.timestamp)) {
    return cached.data
  }
  cache.delete(key) // Remove expired cache
  return null
}

// Helper function to set cached data
const setCachedData = <T>(key: string, data: T): void => {
  cache.set(key, {
    data,
    timestamp: Date.now()
  })
}

// Debounce utility for search
export const useDebounce = <T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): ((...args: Parameters<T>) => void) => {
  let timeoutId: ReturnType<typeof setTimeout>

  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn(...args), delay)
  }
}

// Request deduplication utility
const pendingRequests = new Map<string, Promise<any>>()

export const useDedupedRequest = async <T>(
  key: string,
  requestFn: () => Promise<T>
): Promise<T> => {
  if (pendingRequests.has(key)) {
    return pendingRequests.get(key)!
  }

  const promise = requestFn()
  pendingRequests.set(key, promise)

  try {
    const result = await promise
    return result
  } finally {
    pendingRequests.delete(key)
  }
}

// Caching composable for frequently accessed data
export const useDataCache = () => {
  // Cache currency data
  const getCachedCurrencies = () => getCachedData<any[]>('currencies')
  const setCachedCurrencies = (data: any[]) => setCachedData('currencies', data)

  // Cache channels data
  const getCachedChannels = () => getCachedData<any[]>('channels')
  const setCachedChannels = (data: any[]) => setCachedData('channels', data)

  // Cache profiles data
  const getCachedProfiles = () => getCachedData<any[]>('profiles')
  const setCachedProfiles = (data: any[]) => setCachedData('profiles', data)

  // Cache game accounts data
  const getCachedGameAccounts = () => getCachedData<any[]>('game_accounts')
  const setCachedGameAccounts = (data: any[]) => setCachedData('game_accounts', data)

  // Cache game names
  const getCachedGameNames = () => getCachedData<Map<string, string>>('game_names')
  const setCachedGameNames = (data: Map<string, string>) => setCachedData('game_names', data)

  // Cache server names
  const getCachedServerNames = () => getCachedData<Map<string, string>>('server_names')
  const setCachedServerNames = (data: Map<string, string>) => setCachedData('server_names', data)

  // Clear all caches
  const clearAllCaches = () => {
    cache.clear()
  }

  // Preload commonly used data
  const preloadCommonData = async (supabase: any) => {
    try {
      // Check if data is already cached
      if (!getCachedCurrencies()) {
        const { data: currencies } = await supabase
          .from('attributes')
          .select('id, code, name, type')
          .in('type', ['CURRENCY', 'CURRENCY_FOREIGN'])

        if (currencies) {
          setCachedCurrencies(currencies)
        }
      }

      if (!getCachedChannels()) {
        const { data: channels } = await supabase
          .from('channels')
          .select('id, code, name')

        if (channels) {
          setCachedChannels(channels)
        }
      }

      if (!getCachedGameNames()) {
        const { data: games } = await supabase
          .from('attributes')
          .select('code, name')
          .eq('type', 'GAME')

        if (games) {
          const gameNameMap = new Map((games as GameServerItem[]).map((item: GameServerItem) => [item.code, item.name]))
          setCachedGameNames(gameNameMap)
        }
      }

      if (!getCachedServerNames()) {
        const { data: servers } = await supabase
          .from('attributes')
          .select('code, name')
          .in('type', ['SERVER', 'GAME_SERVER'])

        if (servers) {
          const serverNameMap = new Map((servers as GameServerItem[]).map((item: GameServerItem) => [item.code, item.name]))
          setCachedServerNames(serverNameMap)
        }
      }
    } catch (error) {
      console.error('Error preloading cache data:', error)
    }
  }

  return {
    // Getters
    getCachedCurrencies,
    getCachedChannels,
    getCachedProfiles,
    getCachedGameAccounts,
    getCachedGameNames,
    getCachedServerNames,

    // Setters
    setCachedCurrencies,
    setCachedChannels,
    setCachedProfiles,
    setCachedGameAccounts,
    setCachedGameNames,
    setCachedServerNames,

    // Utilities
    clearAllCaches,
    preloadCommonData,
    getCachedData,
    setCachedData
  }
}