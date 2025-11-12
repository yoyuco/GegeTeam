/* global localStorage */
import { ref, computed, watch } from 'vue'
import { supabase } from '@/lib/supabase'
import { usePermissions } from '@/composables/usePermissions.js'

// Global singleton state for games (shared across all instances)
const globalGames = ref([])
const globalLoading = ref(false)
const globalError = ref(null)

// Global singleton state for current game/server (shared across all instances)
const globalCurrentGame = ref(null)
const globalCurrentServer = ref(null)
const globalLoadingGame = ref(false)
const globalErrorGame = ref(null)
const globalAvailableServers = ref([])

// Store the singleton instance
let gameContextInstance = null

export function useGameContext() {
  // Return existing instance if already created
  if (gameContextInstance) {
    return gameContextInstance
  }

  // Create new instance only once
  const { accessibleGames, canAccessGame } = usePermissions()

  // Use global state (shared across all instances)
  const currentGame = globalCurrentGame
  const currentServer = globalCurrentServer
  const loading = globalLoadingGame
  const error = globalErrorGame
  const availableServers = globalAvailableServers

  // Use global games state (shared across instances)
  const games = globalGames

  // Computed properties
  const currentGameInfo = computed(() => {
    return (games.value || []).find((game) => game && game.code === currentGame.value)
  })

  const currentServerInfo = computed(() => {
    return (availableServers.value || []).find((server) => server && server.code === currentServer.value)
  })

  const availableGames = computed(() => {
    return (games.value || []).filter((game) => game && canAccessGame(game.code))
  })

  // Load games from database
  const loadGames = async () => {
    globalLoading.value = true
    globalError.value = null

    try {
      const { data, error: fetchError } = await supabase.rpc('get_games_v1')

      if (fetchError) throw fetchError

      const newGames = data || []
      games.value = newGames
    } catch (err) {
      console.error('Error loading games:', err)
      globalError.value = err.message
      // Only reset if we don't already have games (to prevent other instances from clearing data)
      if (games.value.length === 0) {
        games.value = []
      }
    } finally {
      globalLoading.value = false
    }
  }

  // Load servers for current game
  const loadServers = async (gameCode) => {
    if (!gameCode) {
      availableServers.value = []
      return
    }

    loading.value = true
    error.value = null

    try {
      // First get the game attribute ID
      const { data: gameData, error: gameError } = await supabase
        .from('attributes')
        .select('id')
        .eq('code', gameCode)
        .eq('type', 'GAME')
        .single()

      if (gameError) throw gameError
      if (!gameData) throw new Error(`Game ${gameCode} not found`)

      // Load GAME_SERVER attributes for the selected game using attribute_relationships
      const { data, error: fetchError } = await supabase
        .from('attribute_relationships')
        .select(`
          child:attributes!attribute_relationships_child_attribute_id_fkey (
            id,
            code,
            name,
            type,
            is_active
          )
        `)
        .eq('parent_attribute_id', gameData.id)
        .eq('child.type', 'GAME_SERVER')
        .eq('child.is_active', true)

      if (fetchError) throw fetchError

      const serverData = data?.map(item => item.child).filter(child => child && child.id) || []

      // Add NULL server option for games that truly have no servers
      if (serverData.length === 0) {
        availableServers.value = [{
          id: 'NULL',
          code: 'NULL',
          name: 'No Server'
        }]
      } else {
        availableServers.value = serverData
          .filter(server => server && server.id && server.code && server.name)
          .map((server) => ({
            id: server.id,
            code: server.code,
            name: server.name || server.code || 'Unknown Server'
          }))
      }

      // Auto-select first server if none selected
      if (!currentServer.value && availableServers.value.length > 0) {
        currentServer.value = availableServers.value[0].code
      }
    } catch (err) {
      console.error('Error loading servers:', err)
      error.value = err.message
      availableServers.value = []
    } finally {
      loading.value = false
    }
  }

  // Switch to different game
  const switchGame = async (gameCode) => {
    if (!gameCode || !canAccessGame(gameCode)) {
      console.warn(`Cannot access game: ${gameCode}`)
      return false
    }

    currentGame.value = gameCode
    currentServer.value = null // Reset server when switching games

    // Load servers for the new game
    await loadServers(gameCode)

    // Save to localStorage for persistence
    if (typeof window !== 'undefined') {
      localStorage.setItem('currency_current_game', gameCode)
      localStorage.removeItem('currency_current_server') // Clear saved server
    }

    return true
  }

  // Switch to different server
  const switchServer = (serverCode) => {
    if (!serverCode) return false

    // Check if server exists in available servers
    const server = availableServers.value.find((s) => s.code === serverCode)
    if (!server) {
      console.warn(`Server not found: ${serverCode}`)
      return false
    }

    currentServer.value = serverCode

    // Save to localStorage
    if (typeof window !== 'undefined') {
      localStorage.setItem('currency_current_server', serverCode)
    }

    return true
  }

  // Get currency type for current game
  const getCurrencyType = (currencyCode) => {
    const gameInfo = currentGameInfo.value
    if (!gameInfo) return null

    return `${gameInfo.currencyPrefix}_${currencyCode.toUpperCase()}`
  }

  // Check if currency belongs to current game
  const isCurrentGameCurrency = (currency) => {
    const gameInfo = currentGameInfo.value
    if (!gameInfo || !currency) return false

    return currency.type === gameInfo.currencyPrefix
  }

  // Load currencies for current game
  const loadCurrencies = async () => {
    if (!currentGame.value) return []

    loading.value = true

    try {
      const gameInfo = currentGameInfo.value
      console.log('🔍 Debug gameInfo:', gameInfo)
      console.log('🔍 Current game value:', currentGame.value)

      // Use correct currency prefix mapping
      let currencyType = null
      if (currentGame.value === 'POE_2') {
        currencyType = 'CURRENCY_POE2'
      } else if (currentGame.value === 'POE_1') {
        currencyType = 'CURRENCY_POE1'
      } else if (currentGame.value === 'DIABLO_4') {
        currencyType = 'CURRENCY_D4'
      }

      console.log('🔍 Using currency type:', currencyType)

      const { data, error: fetchError } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', currencyType)
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (fetchError) throw fetchError

      return data || []
    } catch (err) {
      console.error('Error loading currencies:', err)
      error.value = err.message
      return []
    } finally {
      loading.value = false
    }
  }

  // Load game accounts for current game and server
  const loadGameAccounts = async (purpose = null) => {
    if (!currentGame.value || !currentServer.value) return []

    loading.value = true

    try {
      let query = supabase
        .from('game_accounts')
        .select('*')
        .eq('game_code', currentGame.value)
        .eq('server_attribute_code', currentServer.value)

      if (purpose) {
        query = query.eq('purpose', purpose)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError

      return data || []
    } catch (err) {
      console.error('Error loading game accounts:', err)
      error.value = err.message
      return []
    } finally {
      loading.value = false
    }
  }

  // Initialize from localStorage
  const initializeFromStorage = async () => {
    // Load games first
    await loadGames()

    const savedGame =
      typeof window !== 'undefined' ? localStorage.getItem('currency_current_game') : null
    const savedServer =
      typeof window !== 'undefined' ? localStorage.getItem('currency_current_server') : null

    if (savedGame && canAccessGame(savedGame)) {
      currentGame.value = savedGame

      // Load servers and then restore server if available
      await loadServers(savedGame)
      if (savedServer) {
        const serverExists = availableServers.value.some((s) => s.code === savedServer)
        if (serverExists) {
          currentServer.value = savedServer
        }
      }
    } else {
      // Auto-select first available game
      if (availableGames.value.length > 0) {
        await switchGame(availableGames.value[0].code)
      }
    }
  }

  // Watch for permissions changes
  watch(
    accessibleGames,
    (newGames) => {
      if (newGames.length > 0 && !currentGame.value) {
        initializeFromStorage()
      } else if (currentGame.value && !newGames.includes(currentGame.value)) {
        // Current game is no longer accessible, switch to first available
        if (newGames.length > 0) {
          switchGame(newGames[0])
        } else {
          currentGame.value = null
          currentServer.value = null
        }
      }
    },
    { immediate: true }
  )

  // Watch current game changes
  watch(currentGame, (newGame) => {
    if (newGame) {
      loadServers(newGame)
    } else {
      availableServers.value = []
      currentServer.value = null
    }
  })

  // Context information for UI
  const contextInfo = computed(() => {
    return {
      game: currentGameInfo.value,
      server: currentServerInfo.value,
      availableGames: availableGames.value,
      availableServers: availableServers.value,
      hasContext: !!(currentGame.value && currentServer.value),
    }
  })

  // Generate context string for display - computed property using global state
  const contextString = computed(() => {
    const gameInfo = currentGameInfo.value
    if (!gameInfo) return 'Chưa chọn game'

    let result = gameInfo.name || 'Unknown Game'

    const serverInfo = currentServerInfo.value
    if (serverInfo && serverInfo.name) {
      result += ` - ${serverInfo.name}`
    }

    return result
  })

  // Store the instance for future calls
  const instance = {
    // State
    currentGame,
    currentServer,
    games,
    availableServers,
    loading,
    error,

    // Computed
    currentGameInfo,
    currentServerInfo,
    availableGames,
    contextInfo,
    contextString,

    // Methods
    switchGame,
    switchServer,
    loadGames,
    loadServers,
    loadCurrencies,
    loadGameAccounts,
    getCurrencyType,
    isCurrentGameCurrency,
    initializeFromStorage,
  }

  // Store the instance for future calls
  gameContextInstance = instance
  return instance
}
