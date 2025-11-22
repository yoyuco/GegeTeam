<template>
  <div class="fixed inset-0 z-50 overflow-hidden">
    <!-- Backdrop -->
    <div
      class="absolute inset-0 bg-black bg-opacity-50 transition-opacity"
      @click="closeModal"
      style="z-index: 999997;"
    ></div>

    <!-- Modal Content -->
    <div class="absolute inset-0 bg-white shadow-xl" style="z-index: 999998;">
      <!-- Header -->
      <div class="sticky top-0 z-10 bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-5 shadow-lg">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center backdrop-blur">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
              </svg>
            </div>
            <div>
              <h2 class="text-2xl font-bold">Tổng quan Inventory</h2>
            </div>
          </div>
          <button
            @click="closeModal"
            class="p-2 text-white/80 hover:text-white hover:bg-white/20 rounded-lg transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <!-- Loading Status -->
        <div v-if="loading" class="mt-2 text-sm text-white/80">
          Đang tải dữ liệu...
        </div>

        <!-- Summary Stats -->
        <div v-if="!loading && inventoryData.length > 0" class="mt-4 grid grid-cols-3 gap-4">
          <div class="bg-white/10 backdrop-blur rounded-lg p-4 border border-white/20">
            <div class="flex items-center gap-3">
              <div class="w-4 h-4 bg-blue-400 rounded-full shadow-md"></div>
              <div>
                <p class="text-xs text-white/70 font-medium">Tổng Game</p>
                <p class="text-lg font-bold text-white">{{ uniqueGames.length }}</p>
              </div>
            </div>
          </div>
          <div class="bg-white/10 backdrop-blur rounded-lg p-4 border border-white/20">
            <div class="flex items-center gap-3">
              <div class="w-4 h-4 bg-green-400 rounded-full shadow-md"></div>
              <div>
                <p class="text-xs text-white/70 font-medium">Tổng Currency</p>
                <p class="text-lg font-bold text-white">{{ uniqueCurrencies }}</p>
              </div>
            </div>
          </div>
          <div class="bg-white/10 backdrop-blur rounded-lg p-4 border border-white/20">
            <div class="flex items-center gap-3">
              <div class="w-4 h-4 bg-purple-400 rounded-full shadow-md"></div>
              <div>
                <p class="text-xs text-white/70 font-medium">Tổng Tiền</p>
                <p class="text-lg font-bold text-white">{{ formatCurrency(getTotalValue(), 'VND') }} VNĐ</p>
              </div>
            </div>
          </div>
        </div>

        </div>

      <!-- Content Area -->
      <div class="h-full overflow-y-auto p-4">
        <div v-if="loading" class="flex items-center justify-center h-64">
          <div class="text-center">
            <svg class="animate-spin h-8 w-8 mx-auto text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="none" stroke="currentColor" stroke-width="4" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <p class="mt-2 text-gray-600">Đang tải inventory...</p>
          </div>
        </div>

        <div v-else-if="inventoryData.length === 0" class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Không có dữ liệu inventory</h3>
          <p class="mt-1 text-sm text-gray-500">Chưa có pool nào được tìm thấy</p>
        </div>

        <!-- Tree View Layout -->
        <div v-else class="h-full overflow-y-auto">
          <div class="flex gap-6 h-full">
            <!-- Game Column -->
            <div
              v-for="game in uniqueGames"
              :key="game"
              class="flex-shrink-0 w-96 bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden"
            >
              <!-- Game Header -->
              <div class="bg-gradient-to-r from-blue-500 to-indigo-600 text-white p-4">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                    </svg>
                    <div>
                      <h3 class="font-bold text-xl">{{ getGameDisplayName(game) }}</h3>
                    </div>
                  </div>
                  <div class="text-right">
                    <p class="text-white font-bold">{{ formatCurrency(getGameTotalValue(game), 'VND') }} VNĐ</p>
                  </div>
                </div>
              </div>

              <!-- Game Content -->
              <div class="divide-y divide-gray-200">
                <!-- Server Sections -->
                <div
                  v-for="server in getGameServers(game)"
                  :key="`${game}-${server}`"
                  class="bg-gray-50"
                >
                  <!-- Server Header -->
                  <div class="bg-gradient-to-r from-red-200 to-red-300 border-b border-red-400 px-4 py-3 cursor-pointer hover:from-red-300 hover:to-red-400 transition-all duration-200 shadow-md text-gray-800" @click="toggleServer(game, server)">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center gap-2">
                        <svg
                          :class="{ 'rotate-180': isServerExpanded(game, server) }"
                          class="w-4 h-4 text-gray-500 transition-transform duration-200"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                        </svg>
                        <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"></path>
                        </svg>
                        <div>
                          <span class="font-medium text-gray-900">{{ getServerDisplayName(server) }}</span>
                        </div>
                      </div>
                      <div class="text-xs text-gray-800 font-bold">
                        {{ formatCurrency(getServerTotalValue(game, server), 'VND') }} VNĐ
                      </div>
                    </div>
                  </div>

                  <!-- Server Content (Collapsible) -->
                  <div v-show="isServerExpanded(game, server)" class="divide-y divide-gray-100">
                    <!-- Currency Sections -->
                    <div
                      v-for="currency in getServerCurrencies(game, server)"
                      :key="`${game}-${server}-${currency.name}`"
                      class="bg-white"
                    >
                      <!-- Currency Header -->
                      <div class="px-6 py-3 cursor-pointer hover:bg-orange-200 transition-colors bg-orange-100" @click="toggleCurrency(game, server, currency.id)">
                        <div class="flex items-center justify-between">
                          <div class="flex items-center gap-2">
                            <svg
                              :class="{ 'rotate-180': isCurrencyExpanded(game, server, currency.id) }"
                              class="w-4 h-4 text-gray-500 transition-transform duration-200"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                            </svg>
                            <div class="w-6 h-6 rounded flex items-center justify-center text-white text-xs font-bold" :class="getCurrencyColorClass(currency.name)">
                              {{ currency.name.charAt(0) }}
                            </div>
                            <div>
                              <span class="font-medium text-gray-900">{{ currency.name }}</span>
                              <span class="text-xs text-blue-600 ml-2 font-bold">{{ formatQuantity(getServerCurrencyTotalAll(game, server, currency.name)) }}</span>
                            </div>
                          </div>
                          <div class="text-xs text-gray-800 font-bold">
                            {{ formatCurrency(getCurrencyTotalValue(game, server, currency.id), 'VND') }} VNĐ
                          </div>
                        </div>
                      </div>

                      <!-- Currency Content (Collapsible) -->
                      <div v-show="isCurrencyExpanded(game, server, currency.id)" class="divide-y divide-gray-100">
                        <!-- Cost Currency Sections -->
                        <div
                          v-for="costCurrency in getCostCurrenciesForServerCurrency(game, server, currency.name)"
                          :key="`${game}-${server}-${currency.name}-${costCurrency}`"
                          class="bg-yellow-50"
                        >
                          <!-- Cost Currency Header -->
                          <div class="px-8 py-3 cursor-pointer hover:bg-yellow-100 transition-colors" @click="toggleCostCurrency(game, server, currency.id, costCurrency)">
                            <div class="flex items-center justify-between">
                              <div class="flex items-center gap-2">
                                <svg
                                  :class="{ 'rotate-180': isCostCurrencyExpanded(game, server, currency.id, costCurrency) }"
                                  class="w-4 h-4 text-gray-600 transition-transform duration-200"
                                  fill="none"
                                  stroke="currentColor"
                                  viewBox="0 0 24 24"
                                >
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                </svg>
                                <div class="w-5 h-5 rounded flex items-center justify-center text-white text-xs font-bold" :class="getCostCurrencyBgClass(costCurrency)">
                                  {{ costCurrency }}
                                </div>
                                <div>
                                  <span class="font-medium text-gray-900">Kho {{ costCurrency }}</span>
                                  <span class="text-xs text-blue-600 ml-2 font-bold">
                                    {{ formatQuantity(getServerCurrencyTotal(game, server, currency.name, costCurrency)) }}
                                    <span v-if="getServerCurrencyReserved(game, server, currency.name, costCurrency) > 0" class="text-blue-800 font-bold">+{{ formatQuantity(getServerCurrencyReserved(game, server, currency.name, costCurrency)) }}</span>
                                  </span>
                                </div>
                              </div>
                              <div class="text-xs text-green-700 font-semibold">
                                Giá TB: {{ formatCurrency(getServerCurrencyAvgCost(game, server, currency.name, costCurrency), costCurrency) }} {{ costCurrency }}
                              </div>
                            </div>
                          </div>

                          <!-- Cost Currency Content (Account Details) -->
                          <div v-show="isCostCurrencyExpanded(game, server, currency.id, costCurrency)" class="bg-white divide-y divide-gray-50">
                            <!-- Account Rows -->
                            <div
                              v-for="pool in getPoolsForServerCurrency(game, server, currency.name, costCurrency)"
                              :key="pool.id"
                              v-show="pool.quantity > 0 || pool.reserved_quantity > 0"
                              class="px-10 py-2 hover:bg-gray-50 transition-colors border-b border-gray-200 last:border-b-0"
                            >
                              <div class="flex items-center justify-between">
                                <div class="flex-1 min-w-0">
                                  <p class="text-sm font-medium text-gray-900 truncate">{{ pool.account_name }}</p>
                                  <p class="text-xs text-gray-500">{{ pool.channel_name || 'No channel' }}</p>
                                </div>
                                <div class="text-right">
                                  <div class="text-sm font-bold text-blue-600">
                                    {{ formatQuantity(pool.quantity) }}
                                  </div>
                                  <div class="text-xs text-blue-800 font-bold">
                                    <span v-if="pool.reserved_quantity > 0">+{{ formatQuantity(pool.reserved_quantity) }}</span>
                                    <span v-else class="text-gray-400 font-medium">0</span>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useExchangeRates } from '@/composables/useExchangeRates'

// Props
const props = defineProps<{
  isOpen: boolean
}>()

// Emits
const emit = defineEmits<{
  close: []
}>()

// State
const loading = ref(false)
const inventoryData = reactive<any[]>([])

// Tree state management
const treeState = reactive<{ [key: string]: any }>({})

// Use exchange rates composable
const { exchangeRates, loadExchangeRates, convertToVND, convertFromVND, convertCurrency } = useExchangeRates()

// Initialize tree state
const initializeTreeState = () => {
  inventoryData.forEach((game: any) => {
    if (!treeState[game.game_code]) {
      treeState[game.game_code] = {
        servers: {}
      }
    }

    game.servers.forEach((server: any) => {
      if (!treeState[game.game_code].servers[server.server_attribute_code]) {
        treeState[game.game_code].servers[server.server_attribute_code] = {
          currencies: {}
        }
      }

      server.currencies.forEach((currency: any) => {
        if (!treeState[game.game_code].servers[server.server_attribute_code].currencies[currency.currency_id]) {
          treeState[game.game_code].servers[server.server_attribute_code].currencies[currency.currency_id] = {
            expanded: false, // Currency headers default to collapsed
            cost_currencies: {}
          }
        }

        currency.cost_currencies.forEach((costCurrency: any) => {
          if (!treeState[game.game_code].servers[server.server_attribute_code].currencies[currency.currency_id].cost_currencies[costCurrency.cost_currency]) {
            treeState[game.game_code].servers[server.server_attribute_code].currencies[currency.currency_id].cost_currencies[costCurrency.cost_currency] = {
              expanded: false // Cost currency headers default to collapsed
            }
          }
        })
      })
    })
  })
}

// Toggle functions
const toggleGame = (gameCode: string) => {
  if (!treeState[gameCode]) {
    treeState[gameCode] = { expanded: false }
  }
  treeState[gameCode].expanded = !treeState[gameCode].expanded
}

const toggleServer = (gameCode: string, serverCode: string) => {
  if (!treeState[gameCode]?.servers[serverCode]) {
    return
  }
  treeState[gameCode].servers[serverCode].expanded = !treeState[gameCode].servers[serverCode].expanded
}

const toggleCurrency = (gameCode: string, serverCode: string, currencyId: string) => {
  if (!treeState[gameCode]?.servers[serverCode]?.currencies[currencyId]) {
    return
  }
  // Use Vue.set-like pattern to ensure reactivity
  const currentExpanded = treeState[gameCode].servers[serverCode].currencies[currencyId].expanded
  treeState[gameCode].servers[serverCode].currencies[currencyId] = {
    ...treeState[gameCode].servers[serverCode].currencies[currencyId],
    expanded: !currentExpanded
  }
}

const toggleCostCurrency = (gameCode: string, serverCode: string, currencyId: string, costCurrency: string) => {
  if (!treeState[gameCode]?.servers[serverCode]?.currencies[currencyId]?.cost_currencies[costCurrency]) {
    return
  }
  // Use Vue.set-like pattern to ensure reactivity
  const currentExpanded = treeState[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[costCurrency].expanded
  treeState[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[costCurrency] = {
    ...treeState[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[costCurrency],
    expanded: !currentExpanded
  }
}

// Check expansion state
const isGameExpanded = (gameCode: string) => {
  return treeState[gameCode]?.expanded !== false // Default to expanded
}

const isServerExpanded = (gameCode: string, serverCode: string) => {
  return treeState[gameCode]?.servers[serverCode]?.expanded !== false // Default to expanded
}

const isCurrencyExpanded = (gameCode: string, serverCode: string, currencyId: string) => {
  return treeState[gameCode]?.servers[serverCode]?.currencies[currencyId]?.expanded !== false // Default to expanded
}

const isCostCurrencyExpanded = (gameCode: string, serverCode: string, currencyId: string, costCurrency: string) => {
  return treeState[gameCode]?.servers[serverCode]?.currencies[currencyId]?.cost_currencies[costCurrency]?.expanded !== false // Default to expanded
}


// Helper functions for calculations
const getTotalValue = () => {
  return inventoryData.reduce((total: number, game: any) => {
    return total + getGameTotalValue(game.game_code)
  }, 0)
}

const getGameTotalValue = (gameCode: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  return game.servers.reduce((serverTotal: number, server: any) => {
    return serverTotal + server.currencies.reduce((currencyTotal: number, currency: any) => {
      return currencyTotal + currency.cost_currencies.reduce((costCurrencyTotal: number, costCurrency: any) => {
        return costCurrencyTotal + costCurrency.pools.reduce((poolTotal: number, pool: any) => {
          const valueInCostCurrency = pool.quantity * pool.average_cost
          return poolTotal + convertToVND(valueInCostCurrency, costCurrency.cost_currency)
        }, 0)
      }, 0)
    }, 0)
  }, 0)
}

const getServerTotalValue = (gameCode: string, serverCode: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return 0

  return server.currencies.reduce((total: number, currency: any) => {
    return total + currency.cost_currencies.reduce((currencyTotal: number, costCurrency: any) => {
      return currencyTotal + costCurrency.pools.reduce((poolTotal: number, pool: any) => {
        const valueInCostCurrency = pool.quantity * pool.average_cost
        return poolTotal + convertToVND(valueInCostCurrency, costCurrency.cost_currency)
      }, 0)
    }, 0)
  }, 0)
}

const getCurrencyTotalValue = (gameCode: string, serverCode: string, currencyId: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return 0

  const currency = server.currencies.find((c: any) => c.currency_id === currencyId)
  if (!currency) return 0

  return currency.cost_currencies.reduce((total: number, costCurrency: any) => {
    return total + costCurrency.pools.reduce((poolTotal: number, pool: any) => {
      const valueInCostCurrency = pool.quantity * pool.average_cost
      return poolTotal + convertToVND(valueInCostCurrency, costCurrency.cost_currency)
    }, 0)
  }, 0)
}

const getCostCurrencyTotalValue = (costCurrency: any) => {
  return costCurrency.pools.reduce((total: number, pool: any) => {
    return total + (pool.quantity * pool.average_cost)
  }, 0)
}

const getCostCurrencyTotalQuantity = (costCurrency: any) => {
  return costCurrency.pools.reduce((total: number, pool: any) => {
    return total + pool.quantity
  }, 0)
}

// Computed properties
const uniqueGames = computed(() => {
  return inventoryData.map((game: any) => game.game_code)
})

const uniqueCurrencies = computed(() => {
  let totalCount = 0
  inventoryData.forEach((game: any) => {
    game.servers.forEach((server: any) => {
      server.currencies.forEach((currency: any) => {
        totalCount++
      })
    })
  })
  return totalCount
})

// Methods
const closeModal = () => {
  emit('close')
}

const formatQuantity = (amount: number) => {
  return new Intl.NumberFormat('vi-VN').format(Math.round(amount))
}

const formatCurrency = (amount: number, currencyCode = 'VND') => {
  if (!amount && amount !== 0) return '0'

  if (currencyCode === 'VND') {
    return new Intl.NumberFormat('vi-VN', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(Math.round(amount))
  } else {
    return new Intl.NumberFormat('vi-VN', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 5
    }).format(amount)
  }
}

// Get cost currency dot color
const getCostCurrencyColor = (costCurrency: string) => {
  const colors: { [key: string]: string } = {
    'VND': 'bg-red-500',
    'CNY': 'bg-yellow-500',
    'USD': 'bg-green-500',
    'EUR': 'bg-blue-500'
  }
  return colors[costCurrency] || 'bg-gray-500'
}

const getCurrencyColorClass = (currencyName: string) => {
  const colorMap: { [key: string]: string } = {
    'Chaos Orb': 'bg-gradient-to-r from-red-500 to-orange-600',
    'Exalted Orb': 'bg-gradient-to-r from-yellow-500 to-amber-600',
    'Divine Orb': 'bg-gradient-to-r from-purple-500 to-pink-600',
    'Mirror of Kalandra': 'bg-gradient-to-r from-teal-500 to-cyan-600',
    'Lifeforce': 'bg-gradient-to-r from-green-500 to-emerald-600',
    'Primalist': 'bg-gradient-to-r from-indigo-500 to-blue-600',
    'Ritual': 'bg-gradient-to-r from-violet-500 to-purple-600',
    'Delirium': 'bg-gradient-to-r from-pink-500 to-rose-600',
    'Breach': 'bg-gradient-to-r from-orange-500 to-red-600',
    'Essence': 'bg-gradient-to-r from-blue-500 to-indigo-600',
    'Mapping': 'bg-gradient-to-r from-emerald-500 to-green-600',
    'Metamorph': 'bg-gradient-to-r from-cyan-500 to-teal-600'
  }

  if (colorMap[currencyName]) {
    return colorMap[currencyName]
  }

  // Generate consistent color based on string hash
  let hash = 0
  for (let i = 0; i < currencyName.length; i++) {
    hash = currencyName.charCodeAt(i) + ((hash << 5) - hash)
  }

  const colorOptions = [
    'bg-gradient-to-r from-blue-500 to-indigo-600',
    'bg-gradient-to-r from-green-500 to-emerald-600',
    'bg-gradient-to-r from-purple-500 to-pink-600',
    'bg-gradient-to-r from-orange-500 to-red-600',
    'bg-gradient-to-r from-teal-500 to-cyan-600',
    'bg-gradient-to-r from-yellow-500 to-amber-600',
    'bg-gradient-to-r from-red-500 to-pink-600',
    'bg-gradient-to-r from-indigo-500-to-purple-600'
  ]

  return colorOptions[Math.abs(hash) % colorOptions.length]
}

// Reused function for cost currency backgrounds
const getCostCurrencyBgClass = (costCurrency: string) => {
  const bgClasses: { [key: string]: string } = {
    'VND': 'bg-gradient-to-br from-red-500 to-red-600',
    'CNY': 'bg-gradient-to-br from-yellow-500 to-yellow-600',
    'USD': 'bg-gradient-to-br from-green-500 to-green-600',
    'EUR': 'bg-gradient-to-br from-blue-500 to-blue-600'
  }
  return bgClasses[costCurrency] || 'bg-gradient-to-br from-gray-500 to-gray-600'
}

// State for attribute mappings
const gameNames = ref<{ [key: string]: string }>({})
const serverNames = ref<{ [key: string]: string }>({})

// Load attribute names
const loadAttributeNames = async () => {
  try {
    // Load game names
    const { data: gamesData } = await supabase
      .from('attributes')
      .select('code, name')
      .eq('type', 'GAME')
      .eq('is_active', true)

    if (gamesData) {
      gamesData.forEach((game: any) => {
        gameNames.value[game.code] = game.name
      })
    }

    // Load server names
    const { data: serversData } = await supabase
      .from('attributes')
      .select('code, name')
      .eq('type', 'GAME_SERVER')
      .eq('is_active', true)

    if (serversData) {
      serversData.forEach((server: any) => {
        serverNames.value[server.code] = server.name
      })
    }

  } catch (error) {
  }
}

// Get display names with fallback to code
const getGameDisplayName = (gameCode: string) => {
  return gameNames.value[gameCode] || gameCode
}

const getServerDisplayName = (serverCode: string) => {
  return serverNames.value[serverCode] || serverCode
}


const getGameServers = (gameCode: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return []
  return game.servers.map((server: any) => server.server_attribute_code)
}


const getServerCurrencies = (gameCode: string, serverCode: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return []

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return []

  return server.currencies.map((currency: any) => ({
    name: currency.currency_name,
    code: currency.currency_code,
    id: currency.currency_id
  }))
}

const getCurrencyAccountCount = (gameCode: string, serverCode: string, currencyName: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return 0

  const currency = server.currencies.find((c: any) => c.currency_name === currencyName)
  if (!currency) return 0

  let accountCount = 0
  currency.cost_currencies.forEach((costCurrency: any) => {
    accountCount += costCurrency.pools.length
  })
  return accountCount
}

const getCostCurrenciesForServerCurrency = (gameCode: string, serverCode: string, currencyName: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return []

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return []

  const currency = server.currencies.find((c: any) => c.currency_name === currencyName)
  if (!currency) return []

  return currency.cost_currencies.map((costCurrency: any) => costCurrency.cost_currency).sort()
}

const getServerCurrencyTotalAll = (gameCode: string, serverCode: string, currencyName: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return 0

  const currency = server.currencies.find((c: any) => c.currency_name === currencyName)
  if (!currency) return 0

  return currency.cost_currencies.reduce((total: number, costCurrency: any) => {
    return total + costCurrency.pools.reduce((poolTotal: number, pool: any) => {
      return poolTotal + pool.quantity
    }, 0)
  }, 0)
}

const getServerCurrencyTotal = (gameCode: string, serverCode: string, currencyName: string, costCurrency: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return 0

  const currency = server.currencies.find((c: any) => c.currency_name === currencyName)
  if (!currency) return 0

  const costCurrencyData = currency.cost_currencies.find((cc: any) => cc.cost_currency === costCurrency)
  if (!costCurrencyData) return 0

  return costCurrencyData.pools.reduce((total: number, pool: any) => total + pool.quantity, 0)
}

const getServerCurrencyReserved = (gameCode: string, serverCode: string, currencyName: string, costCurrency: string) => {
  // Reserved quantity not available in current data structure
  return 0
}

const getServerCurrencyAvgCost = (gameCode: string, serverCode: string, currencyName: string, costCurrency: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return 0

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return 0

  const currency = server.currencies.find((c: any) => c.currency_name === currencyName)
  if (!currency) return 0

  const costCurrencyData = currency.cost_currencies.find((cc: any) => cc.cost_currency === costCurrency)
  if (!costCurrencyData || costCurrencyData.pools.length === 0) return 0

  const totalValue = costCurrencyData.pools.reduce((total: number, pool: any) =>
    total + (pool.quantity * pool.average_cost), 0)
  const totalQuantity = costCurrencyData.pools.reduce((total: number, pool: any) =>
    total + pool.quantity, 0)

  return totalQuantity > 0 ? totalValue / totalQuantity : 0
}

const getPoolsForServerCurrency = (gameCode: string, serverCode: string, currencyName: string, costCurrency: string) => {
  const game = inventoryData.find((g: any) => g.game_code === gameCode)
  if (!game) return []

  const server = game.servers.find((s: any) => s.server_attribute_code === serverCode)
  if (!server) return []

  const currency = server.currencies.find((c: any) => c.currency_name === currencyName)
  if (!currency) return []

  const costCurrencyData = currency.cost_currencies.find((cc: any) => cc.cost_currency === costCurrency)
  if (!costCurrencyData) return []

  return costCurrencyData.pools.sort((a: any, b: any) => a.account_name.localeCompare(b.account_name))
}

const loadInventoryData = async () => {
  loading.value = true

  try {
    // Load exchange rates first
    await loadExchangeRates()

    // Load attribute names for games and servers
    await loadAttributeNames()

    // Use RPC function to ensure proper authentication
    const { data, error } = await supabase.rpc('get_all_inventory_pools')

    if (error) {
      throw error
    }

    // Transform data to hierarchical structure
    const transformedData = transformData(data || [])
    inventoryData.splice(0, inventoryData.length, ...transformedData)
    initializeTreeState()
  } finally {
    loading.value = false
  }
}

const transformData = (data: any[]) => {
  const groupedData: { [key: string]: any } = {}
  const accountPools: { [key: string]: any } = {}

  data.forEach(pool => {
    const gameCode = pool.game_code || 'unknown'
    const serverCode = pool.server_attribute_code || 'unknown'
    const currencyId = pool.currency_attribute_id || 'unknown'
    const currencyName = pool.currency_name || 'Unknown Currency'
    const currencyCode = pool.currency_code || 'UNK'
    const costCurrency = pool.cost_currency || 'VND'
    const accountKey = `${gameCode}|${serverCode}|${currencyId}|${pool.game_account_id}|${costCurrency}`

    if (!groupedData[gameCode]) {
      groupedData[gameCode] = {
        game_code: gameCode,
        servers: {}
      }
    }

    if (!groupedData[gameCode].servers[serverCode]) {
      groupedData[gameCode].servers[serverCode] = {
        server_attribute_code: serverCode,
        currencies: {}
      }
    }

    if (!groupedData[gameCode].servers[serverCode].currencies[currencyId]) {
      groupedData[gameCode].servers[serverCode].currencies[currencyId] = {
        currency_id: currencyId,
        currency_name: currencyName,
        currency_code: currencyCode,
        cost_currencies: {}
      }
    }

    if (!groupedData[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[costCurrency]) {
      groupedData[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[costCurrency] = {
        cost_currency: costCurrency,
        pools: []
      }
    }

    // Gộp các pool theo account và cost currency để tính trung bình
    if (!accountPools[accountKey]) {
      accountPools[accountKey] = {
        game_account_id: pool.game_account_id,
        account_name: pool.account_name || 'Unknown Account',
        cost_currency: costCurrency,
        total_quantity: 0,
        total_value: 0,
        total_reserved: 0,
        channels: []
      }
    }

    const quantity = parseFloat(pool.quantity || 0)
    const reserved_quantity = parseFloat(pool.reserved_quantity || 0)
    const average_cost = parseFloat(pool.average_cost || 0)
    const value = quantity * average_cost

    accountPools[accountKey].total_quantity += quantity
    accountPools[accountKey].total_reserved += reserved_quantity
    accountPools[accountKey].total_value += value

    // Lưu thông tin channel để hiển thị
    if (pool.channel_name && !accountPools[accountKey].channels.includes(pool.channel_name)) {
      accountPools[accountKey].channels.push(pool.channel_name)
    }
  })

  // Sau khi gộp, tạo các pool đã tính trung bình
  Object.keys(accountPools).forEach(accountKey => {
    const accountPool = accountPools[accountKey]
    // Tách accountKey đúng cách - format: gameCode|serverCode|currencyId|gameAccountId|costCurrency
    const parts = accountKey.split('|')
    const gameCode = parts[0]
    const serverCode = parts[1]
    const currencyId = parts[2] // UUID nguyên vẹn
    const costCurrency = parts[4] // Phần cuối cùng là costCurrency

    if (accountPool.total_quantity > 0 || accountPool.total_reserved > 0) {
      const average_cost = accountPool.total_quantity > 0 ?
        accountPool.total_value / accountPool.total_quantity : 0

      // Kiểm tra đường dẫn tồn tại trước khi thêm
      if (groupedData[gameCode] &&
          groupedData[gameCode].servers[serverCode] &&
          groupedData[gameCode].servers[serverCode].currencies[currencyId] &&
          groupedData[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[accountPool.cost_currency]) {

        const pooledData = {
          id: `merged-${accountPool.game_account_id}-${accountPool.cost_currency}`,
          game_account_id: accountPool.game_account_id,
          account_name: accountPool.account_name,
          quantity: accountPool.total_quantity,
          reserved_quantity: accountPool.total_reserved,
          average_cost: average_cost,
          channel_id: null, // Gộp nhiều channel nên không có channel_id cụ thể
          channel_name: accountPool.channels.length > 0 ? accountPool.channels.join(', ') : 'Unknown Channel',
          last_updated_at: new Date().toISOString()
        }

        groupedData[gameCode].servers[serverCode].currencies[currencyId].cost_currencies[accountPool.cost_currency].pools.push(pooledData)
      }
    }
  })

  // Transform to array format with proper structure
  const result = Object.values(groupedData).map((game: any) => ({
    game_code: game.game_code,
    servers: Object.values(game.servers).map((server: any) => ({
      server_attribute_code: server.server_attribute_code,
      currencies: Object.values(server.currencies).map((currency: any) => ({
        currency_id: currency.currency_id,
        currency_name: currency.currency_name,
        currency_code: currency.currency_code,
        cost_currencies: Object.values(currency.cost_currencies)
      }))
    }))
  }))

  return result
}

// Load data when modal opens
watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    loadInventoryData()
  }
})

// Load data on mount if modal is opened immediately
onMounted(() => {
  if (props.isOpen) {
    loadInventoryData()
  }
})
</script>

<style scoped>
/* Custom scrollbar */
.overflow-y-auto::-webkit-scrollbar {
  width: 8px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>