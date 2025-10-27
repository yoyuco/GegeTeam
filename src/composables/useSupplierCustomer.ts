import { supabase } from '@/lib/supabase'

export interface SupplierCustomer {
  id: string
  name: string
  type: 'supplier' | 'customer'
  contact_info?: any
  notes?: string
  channel_id?: string
  game_code?: string
}

// CustomerAccount interface removed - customer_accounts table is only for boosting services
// For currency orders, use contact_info in parties table instead

export interface SupplierCustomerOption {
  label: string
  value: string
  data: SupplierCustomer
}

/**
 * Load suppliers or customers by channel ID
 */
export async function loadSuppliersOrCustomersByChannel(
  channelId: string,
  type: 'supplier' | 'customer' = 'supplier',
  gameCode?: string
): Promise<SupplierCustomerOption[]> {
  if (!channelId) {
    return []
  }

  try {
    let query = supabase
      .from('parties')
      .select('*')
      .eq('type', type)
      .eq('channel_id', channelId)
      .order('name')

    // For currency orders, we only need parties data, not customer_accounts
    // customer_accounts table is only for boosting services
    if (gameCode) {
      // Filter by game code if provided for both suppliers and customers
      query = supabase
        .from('parties')
        .select('*')
        .eq('type', type)
        .eq('channel_id', channelId)
        .eq('game_code', gameCode)
        .order('name')
    }

    const { data, error } = await query

    if (error) {
      console.error(`Error loading ${type}s by channel:`, error)
      return []
    }

    return (data || []).map((party: SupplierCustomer) => ({
      label: party.name,
      value: party.id,
      data: party
    }))
  } catch (error) {
    console.error(`Error in loadSuppliersOrCustomersByChannel:`, error)
    return []
  }
}

/**
 * Search suppliers/customers by name and channel
 */
export async function searchSuppliersOrCustomers(
  search: string,
  channelId: string,
  type: 'supplier' | 'customer' = 'supplier',
  gameCode?: string
): Promise<SupplierCustomerOption[]> {
  if (!search || !channelId) {
    return []
  }

  try {
    let query = supabase
      .from('parties')
      .select('*')
      .eq('type', type)
      .eq('channel_id', channelId)
      .ilike('name', `%${search}%`)
      .order('name')
      .limit(20)

    // For currency orders, filter by game code if provided (same as load function)
    if (gameCode) {
      query = supabase
        .from('parties')
        .select('*')
        .eq('type', type)
        .eq('channel_id', channelId)
        .eq('game_code', gameCode)
        .ilike('name', `%${search}%`)
        .order('name')
        .limit(20)
    }

    const { data, error } = await query

    if (error) {
      console.error(`Error searching ${type}s:`, error)
      return []
    }

    return (data || []).map((party: SupplierCustomer) => ({
      label: party.name,
      value: party.id,
      data: party
    }))
  } catch (error) {
    console.error(`Error in searchSuppliersOrCustomers:`, error)
    return []
  }
}

/**
 * Get customer game tag with priority: btag > login+pwd
 */
export function getCustomerGameTag(customer: SupplierCustomer, gameCode?: string): string {
  // For currency orders, get game tag from contact_info in parties table
  // customer_account table is only for boosting services

  if (customer.contact_info) {
    // Try to get game tag from contact_info
    if (customer.contact_info.game_tag) {
      return customer.contact_info.game_tag
    }
    if (customer.contact_info.character_name) {
      return customer.contact_info.character_name
    }
    if (customer.contact_info.contact) {
      return customer.contact_info.contact
    }
  }

  // Fallback: try to extract from notes if it contains game tag info
  if (customer.notes) {
    // Look for patterns like "btag: xxx", "character: xxx", etc.
    const btagMatch = customer.notes.match(/btag[:\s]+([^\n\r]+)/i)
    if (btagMatch && btagMatch[1]) {
      return btagMatch[1].trim()
    }

    const characterMatch = customer.notes.match(/character[:\s]+([^\n\r]+)/i)
    if (characterMatch && characterMatch[1]) {
      return characterMatch[1].trim()
    }
  }

  return ''
}

/**
 * Create new supplier or customer
 */
export async function createSupplierOrCustomer(
  name: string,
  type: 'supplier' | 'customer',
  channelId: string,
  contact?: string,
  notes?: string,
  gameCode?: string
): Promise<SupplierCustomer | null> {
  if (!name || !channelId) {
    return null
  }

  try {
    const { data, error } = await supabase
      .from('parties')
      .insert({
        name,
        type,
        contact_info: contact ? { contact } : {},
        notes: notes || `Auto-created for ${type} order`,
        channel_id: channelId,
        game_code: gameCode || 'DIABLO_4'
      })
      .select()
      .single()

    if (error) {
      console.error(`Error creating ${type}:`, error)
      return null
    }

    return data
  } catch (error) {
    console.error(`Error in createSupplierOrCustomer:`, error)
    return null
  }
}