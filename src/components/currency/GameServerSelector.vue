<!-- path: src/components/currency/GameServerSelector.vue -->
<!-- Game & Server Selector Component -->
<template>
  <div class="flex items-center gap-4 p-4 bg-white rounded-lg shadow-sm">
    <div class="flex items-center gap-2">
      <label class="text-sm font-medium">Game:</label>
      <n-select
        v-model:value="selectedGame"
        :options="gameOptions"
        placeholder="Chọn game"
        style="width: 180px"
        @update:value="onGameChange"
      />
    </div>

    <div class="flex items-center gap-2">
      <label class="text-sm font-medium">Server:</label>
      <n-select
        v-model:value="selectedServer"
        :options="serverOptions"
        placeholder="Chọn server"
        style="width: 200px"
        :disabled="!selectedGame"
        @update:value="onServerChange"
      />
    </div>

    <div class="flex items-center gap-2 text-sm text-gray-600">
      <span>Bối cảnh:</span>
      <n-tag type="info" size="small">{{ contextString }}</n-tag>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { NSelect, NTag } from 'naive-ui'
import { supabase } from '@/lib/supabase'
import { usePermissions } from '@/composables/usePermissions.js'
import type { GameInfo } from '@/types/composables'

// Define Server type
interface ServerInfo {
  id: string
  code: string
  name: string
}

// Emits
const emit = defineEmits<{
  'game-changed': [gameCode: string]
  'server-changed': [serverCode: string]
  'context-changed': [
    context: {
      game: GameInfo | null
      server: ServerInfo | null
      availableGames: GameInfo[]
      availableServers: ServerInfo[]
      hasContext: boolean
    },
  ]
}>()

// Composables
const { accessibleGames, canAccessGame } = usePermissions()

// Reactive state
const currentGame = ref<string | null>(null)
const currentServer = ref<string | null>(null)
const games = ref<GameInfo[]>([])
const servers = ref<ServerInfo[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

// Local state
const selectedGame = ref(currentGame.value)
const selectedServer = ref(currentServer.value)

// Computed
const gameOptions = computed(() => {
  return (games.value || [])
    .filter((game) => game && canAccessGame(game.code as any))
    .map((game: GameInfo) => ({
      label: game.name,
      value: game.code,
    }))
})

const serverOptions = computed(() => {
  return (servers.value || [])
    .filter((server) => server)
    .map((server: ServerInfo) => ({
      label: server.name,
      value: server.code,
    }))
})

const contextString = computed(() => {
  if (!currentGame.value) return 'Chưa chọn game'

  const gameInfo = (games.value || []).find((g) => g && g.code === currentGame.value)
  let result = gameInfo?.name || currentGame.value

  if (currentServer.value) {
    const serverInfo = (servers.value || []).find((s) => s && s.code === currentServer.value)
    result += ` - ${serverInfo?.name || currentServer.value}`
  }

  return result
})

// Load games from database
const loadGames = async () => {
  loading.value = true
  error.value = null

  try {
    const { data, error: fetchError } = await supabase.rpc('get_games_v1')

    if (fetchError) throw fetchError

    games.value = data || []
  } catch (err) {
    console.error('Error loading games:', err)
    error.value = (err as Error).message
    games.value = []
  } finally {
    loading.value = false
  }
}

// Load servers for current game using attribute_relationships
const loadServers = async (gameCode: string) => {
  if (!gameCode) {
    servers.value = []
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

    const serverData = data?.map(item => item.child).filter(Boolean) || []

    // Add NULL server option for games that truly have no servers
    if (serverData.length === 0) {
      servers.value = [{
        id: 'NULL',
        code: 'NULL',
        name: 'No Server'
      }]
    } else {
      servers.value = serverData.map((server: any) => ({
        id: server.id,
        code: server.code,
        name: server.name
      }))
    }

    // Auto-select first server if none selected
    if (!currentServer.value && servers.value.length > 0) {
      currentServer.value = servers.value[0].code
      selectedServer.value = currentServer.value
    }
  } catch (err) {
    console.error('Error loading servers:', err)
    error.value = (err as Error).message
    servers.value = []
  } finally {
    loading.value = false
  }
}

// Methods
const onGameChange = async (gameCode: string) => {
  if (gameCode && gameCode !== currentGame.value) {
    currentGame.value = gameCode
    currentServer.value = null // Reset server when switching games
    selectedServer.value = null

    // Load servers for the new game
    await loadServers(gameCode)

    // Save to localStorage for persistence
    if (typeof window !== 'undefined') {
      localStorage.setItem('currency_current_game', gameCode)
      localStorage.removeItem('currency_current_server') // Clear saved server
    }

    emit('game-changed', gameCode)
    emit('context-changed', contextInfo.value)
  }
}

const onServerChange = async (serverCode: string) => {
  if (serverCode && serverCode !== currentServer.value) {
    currentServer.value = serverCode

    // Save to localStorage
    if (typeof window !== 'undefined') {
      localStorage.setItem('currency_current_server', serverCode)
    }

    emit('server-changed', serverCode)
    emit('context-changed', contextInfo.value)
  }
}

// Context information for UI
const contextInfo = computed(() => {
  const gameInfo = (games.value || []).find((g) => g && g.code === currentGame.value)
  const serverInfo = (servers.value || []).find((s) => s && s.code === currentServer.value)

  return {
    game: gameInfo || null,
    server: serverInfo || null,
    availableGames: (games.value || []).filter((game) => game && canAccessGame(game.code as any)),
    availableServers: (servers.value || []).filter((server) => server),
    hasContext: !!(currentGame.value && currentServer.value),
  }
})

// Initialize from localStorage
const initializeFromStorage = async () => {
  // Load games first
  await loadGames()

  const savedGame =
    typeof window !== 'undefined' ? localStorage.getItem('currency_current_game') : null
  const savedServer =
    typeof window !== 'undefined' ? localStorage.getItem('currency_current_server') : null

  if (savedGame && canAccessGame(savedGame as any)) {
    currentGame.value = savedGame
    selectedGame.value = savedGame

    // Load servers and then restore server if available
    await loadServers(savedGame)
    if (savedServer) {
      const serverExists = servers.value.some((s) => s.code === savedServer)
      if (serverExists) {
        currentServer.value = savedServer
        selectedServer.value = savedServer
      }
    }
  } else {
    // Auto-select first available game
    const availableGamesList = (games.value || []).filter((game) => game && canAccessGame(game.code as any))
    if (availableGamesList.length > 0) {
      await onGameChange(availableGamesList[0].code)
    }
  }
}

// Watch for external changes
watch([currentGame, currentServer], () => {
  selectedGame.value = currentGame.value || null
  selectedServer.value = currentServer.value || null
})

// Initialize on mount
try {
  initializeFromStorage()
} catch (error) {
  console.error('Error initializing GameServerSelector:', error)
  // Set default empty state to prevent crashes
  games.value = []
  servers.value = []
  currentGame.value = null
  currentServer.value = null
}

// Expose methods and computed properties
defineExpose({
  currentGame,
  currentServer,
  games,
  servers,
  loading,
  error,
  contextInfo,
  contextString,
  switchGame: onGameChange,
  switchServer: onServerChange,
  loadGames,
  loadServers,
})
</script>