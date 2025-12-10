import { ref, computed } from 'vue'
import { useAuth } from '@/stores/auth'

export function usePermissions() {
  const authStore = useAuth()
  const user = computed(() => authStore.user)

  // Use auth store assignments instead of querying separately
  const userAssignments = computed(() => authStore.assignments || [])

  // Use auth store permissions instead of local state
  const permissions = computed(() => authStore.rawPermissions || [])
  const loading = computed(() => authStore.loading)
  const error = ref(null)

  // Computed properties
  const isAdmin = computed(() => {
    return userAssignments.value.some((assignment) => assignment.role_code === 'admin')
  })

  const isManager = computed(() => {
    return userAssignments.value.some((assignment) => assignment.role_code === 'manager')
  })

  const isMod = computed(() => {
    return userAssignments.value.some((assignment) => assignment.role_code === 'mod')
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
    return permissions.value.some((permission) => permission.permission_code === permissionCode)
  }

  // Check if user can access specific game
  const canAccessGame = (gameCode = null) => {
    // Admin/Mod have full access to all games
    if (isAdmin.value || isMod.value || isManager.value) return true

    // For specific game access
    if (gameCode) {
      // Check if user has access to this specific game
      return userAssignments.value.some(
        (assignment) =>
          assignment.game_name === gameCode ||
          assignment.game_code === gameCode ||
          assignment.game_code === null // null means access to all games
      )
    }

    // General game access - check if user has any game assignment
    return userAssignments.value.length > 0
  }

  // Check if user can manage specific game
  const canManageGame = (gameCode = null) => {
    // Admin/Mod have full management rights
    if (isAdmin.value || isMod.value || isManager.value) return true

    // For specific game management
    if (gameCode) {
      return userAssignments.value.some(
        (assignment) =>
          assignment.game_name === gameCode ||
          assignment.game_code === gameCode ||
          assignment.game_code === null
      )
    }

    return userAssignments.value.length > 0
  }

  // Check if user can access business area
  const canAccessBusinessArea = (areaCode) => {
    // Admin/Mod have full access to all areas
    if (isAdmin.value || isMod.value || isManager.value) return true

    // Check if user has access to this specific business area
    return userAssignments.value.some(
      (assignment) =>
        assignment.business_area_name === areaCode ||
        assignment.business_area_code === areaCode ||
        // NULL business area means access to all areas
        assignment.business_area_name === null ||
        assignment.business_area_code === null
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
    if (isAdmin.value || isMod.value || isManager.value) {
      // Admin/Mod can access all games
      return ['POE1', 'POE2', 'D4']
    }

    // For other roles, return games they have access to AND have Currency business area
    // Allow NULL business_area_attribute (full access) OR specific CURRENCY business area
    return userAssignments.value
      .filter((assignment) =>
        assignment.business_area_attribute?.code === 'CURRENCY' ||
        assignment.business_area_attribute === null  // NULL = full access
      )
      .map((assignment) => assignment.game_attribute?.code || '*')
      .filter((code, index, arr) => arr.indexOf(code) === index) // Remove duplicates
  }

  // Combined permission check with business area context
  const hasPermissionForCurrency = (permissionCode, gameCode = null) => {
    // Admin/Mod có toàn quyền
    if (isAdmin.value || isMod.value || isManager.value) return true

    
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
    if (isAdmin.value || isMod.value || isManager.value) return true

    return hasPermissionForCurrency('currency:create_transaction', gameCode)
  }

  const canManageCurrencyInventory = (gameCode = null) => {
    // Admin/Mod có toàn quyền
    if (isAdmin.value || isMod.value || isManager.value) return true

    return hasPermissionForCurrency('currency:manage_inventory', gameCode)
  }

  // === CURRENCY ORDER PERMISSIONS ===

  // View permissions
  const canViewCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:view_orders', gameCode)
  }

  const canViewCurrencyOrderDetails = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:view_order_details', gameCode)
  }

  // Create permissions
  const canCreateCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:create_orders', gameCode)
  }

  // Edit permissions
  const canEditCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:edit_orders', gameCode)
  }

  const canEditCurrencyOrderPrice = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:edit_price', gameCode)
  }

  const canEditCurrencyOrderDeadline = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:edit_deadline', gameCode)
  }

  const canEditCurrencyOrderNotes = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:edit_notes', gameCode)
  }

  // Order management permissions
  const canAssignCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:assign_orders', gameCode)
  }

  const canStartCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:start_orders', gameCode)
  }

  // Delivery and receiving permissions
  const canDeliverCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:deliver_orders', gameCode)
  }

  const canReceiveCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:receive_orders', gameCode)
  }

  // Exchange permissions
  const canExchangeCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:exchange_orders', gameCode)
  }

  // Cancellation permissions
  const canCancelCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:cancel_orders', gameCode)
  }

  // Completion permissions (existing)
  const canCompleteCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) {
      return true
    }
    // Fix: Use 'currency:complete_orders' instead of 'currency:complete' to match database
    return hasPermissionForCurrency('currency:complete_orders', gameCode)
  }

  // Management permissions
  const canManageAllCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:manage_all_orders', gameCode)
  }

  const canOverrideCurrencyOrders = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:override_orders', gameCode)
  }

  const canTransferCurrencyInventory = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:transfer_inventory', gameCode)
  }

  // Analytics permissions
  const canViewCurrencyInventory = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:view_inventory', gameCode)
  }

  const canViewCurrencyAnalytics = (gameCode = null) => {
    if (isAdmin.value || isManager.value) return true
    return hasPermissionForCurrency('currency:view_analytics', gameCode)
  }

  // Helper methods for common combinations
  const canManageCurrencyOrderLifecycle = (gameCode = null) => {
    return (
      canStartCurrencyOrders(gameCode) &&
      canDeliverCurrencyOrders(gameCode) &&
      canReceiveCurrencyOrders(gameCode) &&
      canCompleteCurrencyOrders(gameCode)
    )
  }

  const canModifyCurrencyOrderDetails = (gameCode = null) => {
    return (
      canEditCurrencyOrders(gameCode) &&
      canEditCurrencyOrderPrice(gameCode) &&
      canEditCurrencyOrderDeadline(gameCode) &&
      canEditCurrencyOrderNotes(gameCode)
    )
  }

  
  // Get user's primary role
  const primaryRole = computed(() => {
    if (isAdmin.value) return { code: 'admin', name: 'Admin' }
    if (isManager.value) return { code: 'manager', name: 'Manager' }
    if (isMod.value) return { code: 'mod', name: 'Moderator' }
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
    isMod,
    isTrader,
    isFarmer,
    accessibleGames,
    accessibleBusinessAreas,
    primaryRole,

    // Basic methods
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

    // === CURRENCY ORDER PERMISSIONS ===
    // View permissions
    canViewCurrencyOrders,
    canViewCurrencyOrderDetails,

    // Create permissions
    canCreateCurrencyOrders,

    // Edit permissions
    canEditCurrencyOrders,
    canEditCurrencyOrderPrice,
    canEditCurrencyOrderDeadline,
    canEditCurrencyOrderNotes,

    // Order management permissions
    canAssignCurrencyOrders,
    canStartCurrencyOrders,

    // Delivery and receiving permissions
    canDeliverCurrencyOrders,
    canReceiveCurrencyOrders,

    // Exchange permissions
    canExchangeCurrencyOrders,

    // Cancellation permissions
    canCancelCurrencyOrders,

    // Completion permissions
    canCompleteCurrencyOrders,

    // Management permissions
    canManageAllCurrencyOrders,
    canOverrideCurrencyOrders,
    canTransferCurrencyInventory,

    // Analytics permissions
    canViewCurrencyInventory,
    canViewCurrencyAnalytics,

    // Helper methods for common combinations
    canManageCurrencyOrderLifecycle,
    canModifyCurrencyOrderDetails,
  }
}
