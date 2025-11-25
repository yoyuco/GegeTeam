// path: src/types/composables.d.ts
// Type declarations for composables
import { Ref } from 'vue'

// Game Context types
export interface GameInfo {
  code: string
  name: string
  icon: string
  description: string
  currencyPrefix: string
}

export interface ServerInfo {
  id: string
  code: string
  name: string
  type: string
  is_active: boolean
}

export interface ContextInfo {
  game: GameInfo | null
  server: ServerInfo | null
  availableGames: GameInfo[]
  availableServers: ServerInfo[]
  hasContext: boolean
}

export interface UseGameContext {
  // State
  currentGame: Ref<string | null>
  currentServer: Ref<string | null>
  games: Ref<GameInfo[]>
  availableServers: Ref<ServerInfo[]>
  loading: Ref<boolean>
  error: Ref<string | null>

  // Computed
  currentGameInfo: Ref<GameInfo | null>
  currentServerInfo: Ref<ServerInfo | null>
  availableGames: Ref<GameInfo[]>
  contextInfo: Ref<ContextInfo>
  contextString: Ref<string>

  // Methods
  switchGame: (gameCode: string) => Promise<boolean>
  switchServer: (serverCode: string) => boolean
  loadServers: (gameCode: string) => Promise<void>
  loadCurrencies: () => Promise<LeagueInfo[]>
  loadGameAccounts: (purpose?: string) => Promise<GameAccount[]>
  getCurrencyType: (currencyCode: string) => string | null
  isCurrentGameCurrency: (currency: { type?: string }) => boolean
  initializeFromStorage: () => void
}

export interface GameAccount {
  id: string
  account_name: string
  game_code: string
  purpose: string
  server_attribute_code?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Transaction {
  id: string
  channel_id: string
  currency_id: string
  game_account_id: string
  transaction_type: string
  amount: number
  fee_amount?: number
  reference_id?: string
  description?: string
  metadata?: Record<string, unknown>
  created_at: string
}

export interface TransactionFilters {
  channelId?: string
  currencyId?: string
  gameAccountId?: string
  startDate?: string
  endDate?: string
  limit?: number
}

export interface UseCurrency {
  // State
  currencies: Ref<Currency[]>
  exchangeRates: Ref<Record<string, number>>
  channels: Ref<Channel[]>
  loading: Ref<boolean>
  error: Ref<string | null>

  // Computed
  activeCurrencies: Ref<Currency[]>
  currenciesByCode: Ref<Record<string, Currency>>
  salesChannels: Ref<Channel[]>
  purchaseChannels: Ref<Channel[]>
  allCurrencies: Ref<Currency[]>
  getChannelsWithFeeChains: Ref<Channel[]>

  // Methods
  getCurrencyByCode: (code: string) => Currency | null
  getExchangeRate: (fromCurrency: string, toCurrency: string) => number | null
  convertCurrency: (amount: number, fromCurrency: string, toCurrency: string) => number | null
  loadAvailableCurrencies: () => Promise<void>
  loadAllCurrencies: () => Promise<void>
  loadExchangeRates: () => Promise<void>
  loadChannels: () => Promise<void>
  getChannelById: (channelId: string) => Channel | null
  createTransaction: (transactionData: Record<string, unknown>) => Promise<unknown>
  getTransactionHistory: (filters: TransactionFilters) => Promise<Transaction[]>
  getAccountBalance: (accountId: string, currencyId: string) => Promise<number>
  updateExchangeRate: (fromCurrency: string, toCurrency: string, rate: number) => Promise<void>
  calculateFee: (
    amount: number,
    channelId: string,
    fromCurrency: string,
    toCurrency: string
  ) => Promise<number>
  formatCurrencyAmount: (amount: number, currencyCode: string) => string
  validateTransaction: (transactionData: Record<string, unknown>) => string[]
  initialize: () => Promise<void>
}

export interface Currency {
  id: string
  code: string
  name: string
  type: string
  is_active?: boolean
  gameVersion?: string
  sort_order?: number
  description?: string
  displayName?: string
}

export interface Channel {
  id: string
  code: string
  name: string
  displayName?: string
  channel_type: string
  description: string
  website_url?: string
  is_active: boolean
  direction: 'BUY' | 'SELL' | 'BOTH'
  created_at?: string
  updated_at?: string
  created_by?: string
  updated_by?: string
  purchase_fee_rate?: number
  purchase_fee_fixed?: number
  purchase_fee_currency?: string
  sale_fee_rate?: number
  sale_fee_fixed?: number
  sale_fee_currency?: string
  fee_updated_at?: string
  fee_updated_by?: string
}

export interface InventoryItem {
  id: string
  game_account_id: string
  currency_attribute_id: string
  currency: Currency
  game_account: GameAccount
  manager: { display_name: string; email: string } | null
  quantity: number
  reserved_quantity: number
  avg_price_vnd?: number
  avg_price_usd?: number
  total_value_vnd?: number
  total_value_usd?: number
  created_at: string
  updated_at: string
}

export interface CurrencyInventoryGroup {
  currencyId: string
  currencyCode: string
  currencyName: string
  totalQuantity: number
  totalReserved: number
  avgPriceVnd: number
  avgPriceUsd: number
  totalValueVnd: number
  accounts: InventoryItem[]
}

export interface InventorySummary {
  totalItems: number
  totalValueVnd: number
  totalValueUsd: number
  lowStockCount: number
  emptyCount: number
  lastUpdated: Date | null
}

export interface UseInventory {
  // State
  inventory: Ref<InventoryItem[]>
  gameAccounts: Ref<GameAccount[]>
  loading: Ref<boolean>
  error: Ref<string | null>

  // Computed
  totalInventoryValue: Ref<number>
  inventoryByCurrency: Ref<CurrencyInventoryGroup[]>
  availableInventory: Ref<CurrencyInventoryGroup[]>
  lowStockItems: Ref<CurrencyInventoryGroup[]>
  emptyInventory: Ref<CurrencyInventoryGroup[]>
  getInventorySummary: Ref<InventorySummary>

  // Methods
  loadAccounts: () => Promise<void>
  loadInventory: (accountId?: string) => Promise<void>
  getInventoryByAccount: (accountId: string) => InventoryItem[]
  getAvailableQuantity: (currencyId: string, accountId?: string) => number
  getReservedQuantity: (currencyId: string, accountId?: string) => number
  hasSufficientInventory: (currencyId: string, quantity: number, accountId?: string) => boolean
  createGameAccount: (accountData: Record<string, unknown>) => Promise<GameAccount>
  updateGameAccount: (accountId: string, updates: Record<string, unknown>) => Promise<GameAccount>
  deleteGameAccount: (accountId: string) => Promise<void>
  reserveInventory: (currencyId: string, quantity: number, accountId?: string) => Promise<void>
  releaseInventory: (currencyId: string, quantity: number, accountId?: string) => Promise<void>
  updateInventoryItem: (itemId: string, updates: Record<string, unknown>) => Promise<InventoryItem>
  deleteInventoryItem: (itemId: string) => Promise<void>
  refreshInventory: () => Promise<void>
}

export interface UseCurrencyTransfer {
  // State
  loading: Ref<boolean>
  error: Ref<string | null>

  // Methods
  transferCurrency: (transferData: {
    sourceAccountId: string
    targetAccountId: string
    currencyId: string
    quantity: number
    gameCode: string
    serverCode: string
    notes?: string
  }) => Promise<{
      target: any
      transferredQuantity: number
      transferredValue: number
      poolsUsed: Array<{
        poolId: string
        quantityTaken: number
        averageCost: number
        costCurrency: string
        channelId: string
      }>
      weightedAverageCost: number
    }>
  getTransferHistory: (filters?: {
    gameCode?: string
    serverCode?: string
    sourceAccountId?: string
    targetAccountId?: string
    currencyId?: string
    transactionType?: string
    limit?: number
  }) => Promise<CurrencyTransfer[]>
  validateTransfer: (sourceAccountId: string, currencyId: string, quantity: number) => Promise<{
    valid: boolean
    availableQuantity?: number
    reason?: string
  }>
}

export interface FeeStep {
  step_number: number
  from_amount: number
  to_amount: number
  from_currency: string
  to_currency: string
  fee_type: string
  fee_amount: number
  fee_currency: string
  description: string
  cumulative_amount: number
}

export interface CurrencyTransfer {
  id: string
  game_account_id: string
  game_code: string
  server_attribute_code: string
  source_account_id?: string
  target_account_id?: string
  transaction_type: string
  currency_attribute_id: string
  quantity: number
  transfer_value?: number
  source_avg_cost?: number
  target_new_avg_cost?: number
  unit_price: number
  currency_code: string
  notes?: string
  transferred_by?: string
  proofs?: any
  created_at: string
  game_account?: {
    account_name: string
  }
  currency?: {
    name: string
    code: string
  }
  transferred_by_user?: {
    id: string
    display_name: string
  }
}
