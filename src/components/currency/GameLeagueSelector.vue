<!-- path: src/components/currency/GameLeagueSelector.vue -->
<!-- Game & League Selector Component -->
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
      <label class="text-sm font-medium">League:</label>
      <n-select
        v-model:value="selectedLeague"
        :options="leagueOptions"
        placeholder="Chọn league"
        style="width: 200px"
        :disabled="!selectedGame"
        @update:value="onLeagueChange"
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
import { useGameContext } from '@/composables/useGameContext.js'
import type { GameInfo, LeagueInfo } from '@/types/composables'

// Emits
const emit = defineEmits<{
  'game-changed': [gameCode: string]
  'league-changed': [leagueId: string]
  'context-changed': [
    context: {
      game: unknown
      league: unknown
      availableGames: unknown[]
      availableLeagues: unknown[]
      hasContext: boolean
    },
  ]
}>()

// Composables
const {
  currentGame,
  currentLeague,
  availableGames,
  availableLeagues,
  contextInfo,
  contextString,
  switchGame,
  switchLeague,
} = useGameContext()

// Local state
const selectedGame = ref(currentGame.value)
const selectedLeague = ref(currentLeague.value)

// Computed
const gameOptions = computed(() => {
  return availableGames.value.map((game: GameInfo) => ({
    label: game.name,
    value: game.code,
  }))
})

const leagueOptions = computed(() => {
  return availableLeagues.value.map((league: LeagueInfo) => ({
    label: league.name,
    value: league.id,
  }))
})

// Methods
const onGameChange = async (gameCode: string) => {
  if (gameCode && gameCode !== currentGame.value) {
    await switchGame(gameCode)
    selectedLeague.value = currentLeague.value
    emit('game-changed', gameCode)
    emit('context-changed', contextInfo.value)
  }
}

const onLeagueChange = async (leagueId: string) => {
  if (leagueId && leagueId !== currentLeague.value) {
    await switchLeague(leagueId)
    emit('league-changed', leagueId)
    emit('context-changed', contextInfo.value)
  }
}

// Watch for external changes
watch([currentGame, currentLeague], () => {
  selectedGame.value = currentGame.value
  selectedLeague.value = currentLeague.value
})
</script>
