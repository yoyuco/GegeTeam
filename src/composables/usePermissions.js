import { ref, computed } from 'vue'
import { useAuth } from '@/stores/auth'

export function usePermissions() {
  const authStore = useAuth()
  const user = computed(() => authStore.user)

  // Use auth store assignments instead of querying separately
  const userAssignments = computed(() => authStore.assignments || [])

  // Reactive state
  const permissions = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Computed properties
  const isAdmin = computed(() => {
    return userAssignments.value.some((assignment) => assignment.role_code === 'admin')
  })

  const isManager = computed(() => {
    return userAssignments.value.some((assignment) => assignment.role_code === 'manager')
  })

  const isTrader = computed(() => {
    return userAssignments.value.some(
      (assignment) =>
        assignment.role_code === 'trader1' ||
        assignment.role_code === 'trader2' ||
        assignment.role_code === 'trader3' ||
        assignment.role_code === 'trader_manager' ||
        assignment.role_code === 'trader_leader'
    )
  })

  const isFarmer = computed(() => {
    return userAssignments.value.some(
      (assignment) =>
        assignment.role_code === 'farmer' ||
        assignment.role_code === 'farmer_manager' ||
        assignment.role_code === 'farmer_leader'
    )
  })

  // Get accessible games based on permissions
  const accessibleGames = computed(() => {
    const gameCodes = new Set()

    userAssignments.value.forEach((assignment) => {
      if (assignment.game_name) {
        gameCodes.add(assignment.game_name)
      }
    })

    return Array.from(gameCodes)
  })

  // Get business areas user has access to
  const accessibleBusinessAreas = computed(() => {
    const areas = new Set()

    userAssignments.value.forEach((assignment) => {
      if (assignment.business_area_name) {
        areas.add(assignment.business_area_name)
      }
    })

    return Array.from(areas)
  })

  // Check if user has specific permission
  const hasPermission = (permissionCode) => {
    return permissions.value.some((permission) => permission.code === permissionCode)
  }

  // Check if user can access specific game
  const canAccessGame = (gameCode = null) => {
    // Admin/Mod have full access to all games
    if (isAdmin.value || isManager.value) return true

    // For specific game access
    if (gameCode) {
      // Check if user has access to this specific game
      return userAssignments.value.some(
        (assignment) => assignment.game_name === gameCode || assignment.game_code === null // null means access to all games
      )
    }

    // General game access - check if user has any game assignment
    return userAssignments.value.length > 0
  }

  // Check if user can manage specific game
  const canManageGame = (gameCode = null) => {
    // Admin/Mod have full management rights
    if (isAdmin.value || isManager.value) return true

    // For specific game management
    if (gameCode) {
      return userAssignments.value.some(
        (assignment) => assignment.game_name === gameCode || assignment.game_code === null
      )
    }

    return userAssignments.value.length > 0
  }

  // Check if user can access business area
  const canAccessBusinessArea = (areaCode) => {
    // Admin/Mod have full access to all areas
    if (isAdmin.value || isManager.value) return true

    // Check if user has access to this specific business area
    return userAssignments.value.some(
      (assignment) =>
        assignment.business_area_name === areaCode || assignment.business_area_code === areaCode
    )
  }

  // Check if user can access Currency business area
  const canAccessCurrencyArea = () => {
    return canAccessBusinessArea('CURRENCY')
  }

  // Check specific currency permissions based on game + business area access
  const canManageCurrency = (gameCode = null) => {
    return canAccessGame(gameCode) && canAccessCurrencyArea()
  }

  const canViewInventory = (gameCode = null) => {
    return canAccessGame(gameCode) && canAccessCurrencyArea()
  }

  const canCreateTransactions = (gameCode = null) => {
    return canAccessGame(gameCode) && canAccessCurrencyArea()
  }

  const canManageGameAccounts = (gameCode = null) => {
    return canManageGame(gameCode) && canAccessCurrencyArea()
  }

  // Get user's accessible games for Currency operations
  const getAccessibleCurrencyGames = () => {
    if (isAdmin.value || isManager.value) {
      // Admin/Mod can access all games
      return ['POE1', 'POE2', 'D4']
    }

    // For other roles, return games they have access to AND have Currency business area
    return userAssignments.value
      .filter((assignment) => assignment.business_area_attribute?.code === 'CURRENCY')
      .map((assignment) => assignment.game_attribute?.code || '*')
      .filter((code, index, arr) => arr.indexOf(code) === index) // Remove duplicates
  }

  // Combined permission check with business area context
  const hasPermissionForCurrency = (permissionCode, gameCode = null) => {
    // Admin/Mod có toàn quyền
    if (isAdmin.value || isManager.value) return true

    // Check basic permission
    if (!hasPermission(permissionCode)) return false

    // Check business area access - phải có CURRENCY area
    if (!canAccessCurrencyArea()) return false

    // Check game access nếu có yêu cầu
    if (gameCode && !canAccessGame(gameCode)) return false

    return true
  }

  // Specific combined permission checks for currency operations
  const canViewCurrencyOperations = (gameCode = null) => {
    // Admin/Mod có toàn quyền - không cần permission check
    if (isAdmin.value || isManager.value) return true

    // Check combined permission cho roles khác
    return hasPermissionForCurrency('currency:view', gameCode)
  }

  const canManageCurrencyOperations = (gameCode = null) => {
    // Admin/Mod có toàn quyền - không cần permission check
    if (isAdmin.value || isManager.value) return true

    // Check combined permission cho roles khác
    return hasPermissionForCurrency('currency:manage', gameCode)
  }

  const canCreateCurrencyTransactions = (gameCode = null) => {
    // Admin/Mod có toàn quyền
    if (isAdmin.value || isManager.value) return true

    return hasPermissionForCurrency('currency:create_transaction', gameCode)
  }

  const canManageCurrencyInventory = (gameCode = null) => {
    // Admin/Mod có toàn quyền
    if (isAdmin.value || isManager.value) return true

    return hasPermissionForCurrency('currency:manage_inventory', gameCode)
  }

  // Get user's primary role
  const primaryRole = computed(() => {
    if (isAdmin.value) return { code: 'admin', name: 'Admin' }
    if (isManager.value) return { code: 'manager', name: 'Manager' }
    if (isTrader.value) return { code: 'trader', name: 'Trader' }
    if (isFarmer.value) return { code: 'farmer', name: 'Farmer' }
    return { code: 'default', name: 'User' }
  })

  return {
    // State
    permissions,
    userAssignments,
    loading,
    error,
    user,

    // Computed
    isAdmin,
    isManager,
    isTrader,
    isFarmer,
    accessibleGames,
    accessibleBusinessAreas,
    primaryRole,

    // Methods
    hasPermission,
    canAccessGame,
    canManageGame,
    canAccessBusinessArea,
    canAccessCurrencyArea,
    canManageCurrency,
    canViewInventory,
    canCreateTransactions,
    canManageGameAccounts,
    getAccessibleCurrencyGames,

    // Combined permission methods
    hasPermissionForCurrency,
    canViewCurrencyOperations,
    canManageCurrencyOperations,
    canCreateCurrencyTransactions,
    canManageCurrencyInventory,
  }
}
