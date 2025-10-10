/* global localStorage */
import { ref, computed, watch } from 'vue'
import { supabase } from '@/lib/supabase'
import { usePermissions } from '@/composables/usePermissions.js'

// Global singleton state for games (shared across all instances)
const globalGames = ref([])
const globalLoading = ref(false)
const globalError = ref(null)

// Global singleton state for current game/league (shared across all instances)
const globalCurrentGame = ref(null)
const globalCurrentLeague = ref(null)
const globalLoadingGame = ref(false)
const globalErrorGame = ref(null)
const globalAvailableLeagues = ref([])

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
  const currentLeague = globalCurrentLeague
  const loading = globalLoadingGame
  const error = globalErrorGame
  const availableLeagues = globalAvailableLeagues

  // Use global games state (shared across instances)
  const games = globalGames

  // Computed properties
  const currentGameInfo = computed(() => {
    return games.value.find((game) => game.code === currentGame.value)
  })

  const currentLeagueInfo = computed(() => {
    return availableLeagues.value.find((league) => league.id === currentLeague.value)
  })

  const availableGames = computed(() => {
    return games.value.filter((game) => canAccessGame(game.code))
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

  // Load leagues for current game
  const loadLeagues = async (gameCode) => {
    if (!gameCode) {
      availableLeagues.value = []
      return
    }

    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase.rpc('get_game_leagues_v1', {
        p_game_code: gameCode,
      })

      if (fetchError) throw fetchError

      availableLeagues.value = data || []

      // Auto-select first league if none selected
      if (!currentLeague.value && availableLeagues.value.length > 0) {
        currentLeague.value = availableLeagues.value[0].id
      }
    } catch (err) {
      console.error('Error loading leagues:', err)
      error.value = err.message
      availableLeagues.value = []
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
    currentLeague.value = null // Reset league when switching games

    // Load leagues for the new game
    await loadLeagues(gameCode)

    // Save to localStorage for persistence
    if (typeof window !== 'undefined') {
      localStorage.setItem('currency_current_game', gameCode)
      localStorage.removeItem('currency_current_league') // Clear saved league
    }

    return true
  }

  // Switch to different league
  const switchLeague = (leagueId) => {
    if (!leagueId) return false

    // Check if league exists in available leagues
    const league = availableLeagues.value.find((l) => l.id === leagueId)
    if (!league) {
      console.warn(`League not found: ${leagueId}`)
      return false
    }

    currentLeague.value = leagueId

    // Save to localStorage
    if (typeof window !== 'undefined') {
      localStorage.setItem('currency_current_league', leagueId)
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
      const { data, error: fetchError } = await supabase
        .from('attributes')
        .select('*')
        .eq('type', gameInfo.currencyPrefix)
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

  // Load game accounts for current game and league
  const loadGameAccounts = async (purpose = null) => {
    if (!currentGame.value || !currentLeague.value) return []

    loading.value = true

    try {
      let query = supabase
        .from('game_accounts')
        .select(
          `
          *,
          league:attributes(id, code, name),
          manager:profiles(id, display_name)
        `
        )
        .eq('game_code', currentGame.value)
        .eq('league_attribute_id', currentLeague.value)

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
    const savedLeague =
      typeof window !== 'undefined' ? localStorage.getItem('currency_current_league') : null

    if (savedGame && canAccessGame(savedGame)) {
      currentGame.value = savedGame

      // Load leagues and then restore league if available
      await loadLeagues(savedGame)
      if (savedLeague) {
        const leagueExists = availableLeagues.value.some((l) => l.id === savedLeague)
        if (leagueExists) {
          currentLeague.value = savedLeague
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
          currentLeague.value = null
        }
      }
    },
    { immediate: true }
  )

  // Watch current game changes
  watch(currentGame, (newGame) => {
    if (newGame) {
      loadLeagues(newGame)
    } else {
      availableLeagues.value = []
      currentLeague.value = null
    }
  })

  // Context information for UI
  const contextInfo = computed(() => {
    return {
      game: currentGameInfo.value,
      league: currentLeagueInfo.value,
      availableGames: availableGames.value,
      availableLeagues: availableLeagues.value,
      hasContext: !!(currentGame.value && currentLeague.value),
    }
  })

  // Generate context string for display - computed property using global state
  const contextString = computed(() => {
    if (!currentGameInfo.value) return 'Chưa chọn game'

    let result = currentGameInfo.value.name

    if (currentLeagueInfo.value) {
      result += ` - ${currentLeagueInfo.value.name}`
    }

    return result
  })

  // Store the instance for future calls
  const instance = {
    // State
    currentGame,
    currentLeague,
    games,
    availableLeagues,
    loading,
    error,

    // Computed
    currentGameInfo,
    currentLeagueInfo,
    availableGames,
    contextInfo,
    contextString,

    // Methods
    switchGame,
    switchLeague,
    loadGames,
    loadLeagues,
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
