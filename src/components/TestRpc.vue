<!-- path: src/components/TestRpc.vue -->
<template>
  <div class="p-4">
    <h2>RPC Functions Test</h2>

    <div class="space-y-4">
      <div>
        <h3>Games Test</h3>
        <n-button :loading="loadingGames" @click="testGetGames"> Test get_games_v1() </n-button>
        <pre v-if="gamesData" class="mt-2 p-2 bg-gray-100 rounded">{{
          JSON.stringify(gamesData, null, 2)
        }}</pre>
      </div>

      <div>
        <h3>Game Leagues Test</h3>
        <n-button :loading="loadingLeagues" @click="testGetLeagues">
          Test get_game_leagues_v1('POE_1')
        </n-button>
        <pre v-if="leaguesData" class="mt-2 p-2 bg-gray-100 rounded">{{
          JSON.stringify(leaguesData, null, 2)
        }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { NButton } from 'naive-ui'
import { supabase } from '@/lib/supabase'

interface GameData {
  id: string
  code: string
  name: string
  icon: string
  description: string
  sort_order: number
  is_active: boolean
  currency_prefix: string
  league_prefix: string
}

interface LeagueData {
  id: string
  code: string
  name: string
  sort_order: number
  is_active: boolean
}

interface ErrorData {
  error: string
}

const loadingGames = ref(false)
const loadingLeagues = ref(false)
const gamesData = ref<GameData[] | ErrorData | null>(null)
const leaguesData = ref<LeagueData[] | ErrorData | null>(null)

const testGetGames = async () => {
  loadingGames.value = true
  try {
    const { data, error } = await supabase.rpc('get_games_v1')
    if (error) {
      console.error('RPC Error:', error)
      gamesData.value = { error: error.message }
    } else {
      console.log('Games data:', data)
      gamesData.value = data
    }
  } catch (err) {
    console.error('Test error:', err)
    const errorMessage = err instanceof Error ? err.message : 'Unknown error'
    gamesData.value = { error: errorMessage }
  } finally {
    loadingGames.value = false
  }
}

const testGetLeagues = async () => {
  loadingLeagues.value = true
  try {
    const { data, error } = await supabase.rpc('get_game_leagues_v1', {
      p_game_code: 'POE_1',
    })
    if (error) {
      console.error('RPC Error:', error)
      leaguesData.value = { error: error.message }
    } else {
      console.log('Leagues data:', data)
      leaguesData.value = data
    }
  } catch (err) {
    console.error('Test error:', err)
    const errorMessage = err instanceof Error ? err.message : 'Unknown error'
    leaguesData.value = { error: errorMessage }
  } finally {
    loadingLeagues.value = false
  }
}
</script>
