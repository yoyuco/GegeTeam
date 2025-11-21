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
 * Get customer game tag with priority: new JSON structure > btag > login+pwd
 */
export function getCustomerGameTag(customer: SupplierCustomer, gameCode?: string): string {
  // For currency orders, get game tag from contact_info in parties table
  // customer_account table is only for boosting services

  if (customer.contact_info) {
    // Try to get game tag from contact_info JSON structure (new)
    if (customer.contact_info.gameTag) {
      return customer.contact_info.gameTag
    }

    // Fallback to old field names for backward compatibility
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
 * Create new supplier or customer with enhanced contact_info JSON
 */
export async function createSupplierOrCustomer(
  name: string,
  type: 'supplier' | 'customer',
  channelId: string,
  contact?: string,
  notes?: string,
  gameCode?: string,
  gameTag?: string,
  deliveryInfo?: string
): Promise<SupplierCustomer | null> {
  if (!name || !channelId) {
    return null
  }

  try {
    // First, check if party already exists
    const { data: existingParty, error: checkError } = await supabase
      .from('parties')
      .select('*')
      .eq('name', name)
      .eq('type', type)
      .eq('channel_id', channelId)
      .single()

    if (checkError && checkError.code !== 'PGRST116') { // PGRST116 = not found
      console.error(`Error checking existing ${type}:`, checkError)
      return null
    }

    // If party exists, update and return it
    if (existingParty) {
      console.log(`${type} "${name}" already exists, updating with new information`)

      // Build updated contact_info JSON, preserve existing data if not provided
      const updatedContactInfo: any = {
        ...existingParty.contact_info,
        contact: contact || existingParty.contact_info?.contact || ''
      }

      // Update gameTag and deliveryInfo if provided
      if (gameTag) {
        updatedContactInfo.gameTag = gameTag
      }

      if (deliveryInfo) {
        updatedContactInfo.deliveryInfo = deliveryInfo
      }

      // Update notes if provided
      const updatedNotes = notes || existingParty.notes

      // Update game code if provided
      const updatedGameCode = gameCode || existingParty.game_code

      const { data: updatedParty, error: updateError } = await supabase
        .from('parties')
        .update({
          contact_info: updatedContactInfo,
          notes: updatedNotes,
          game_code: updatedGameCode,
          channel_id: channelId, // Ensure channel_id is updated if changed
          updated_at: new Date().toISOString()
        })
        .eq('id', existingParty.id)
        .select()
        .single()

      if (updateError) {
        console.error(`Error updating existing ${type}:`, updateError)
        return existingParty // Return original if update fails
      }

      console.log(`Successfully updated existing ${type}:`, updatedParty)
      return updatedParty
    }

    // Build contact_info JSON with all fields
    const contactInfoJson: any = {
      contact: contact || ''
    }

    // Add gameTag and deliveryInfo if provided
    if (gameTag) {
      contactInfoJson.gameTag = gameTag
    }

    if (deliveryInfo) {
      contactInfoJson.deliveryInfo = deliveryInfo
    }

    const { data, error } = await supabase
      .from('parties')
      .insert({
        name,
        type,
        contact_info: contactInfoJson,
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

    console.log(`Successfully created new ${type}:`, data)
    return data
  } catch (error) {
    console.error(`Error in createSupplierOrCustomer:`, error)
    return null
  }
}

/**
 * Load existing party data by name and type for form pre-filling
 */
export async function loadPartyByNameType(
  name: string,
  type: 'supplier' | 'customer'
): Promise<SupplierCustomer | null> {
  if (!name) {
    return null
  }

  try {
    // Use the new RPC function
    const { data, error } = await supabase.rpc('get_party_by_name_type', {
      p_name: name,
      p_type: type
    })

    if (error) {
      console.error(`Error loading ${type} data:`, error)
      return null
    }

    if (data && data.length > 0) {
      const party = data[0]
      return {
        id: party.id,
        name: party.name,
        type: party.type as 'supplier' | 'customer',
        contact_info: party.contact_info,
        notes: party.notes,
        channel_id: party.channel_id,
        game_code: party.game_code
      }
    }

    return null
  } catch (error) {
    console.error(`Error in loadPartyByNameType:`, error)
    return null
  }
}

/**
 * Update existing party information
 */
export async function updatePartyInfo(
  partyId: string,
  updates: {
    name?: string
    contact_info?: any
    notes?: string
    channel_id?: string
  }
): Promise<{ success: boolean; message: string }> {
  if (!partyId) {
    return { success: false, message: 'Party ID is required' }
  }

  try {
    const { data, error } = await supabase.rpc('update_party_info', {
      p_party_id: partyId,
      p_name: updates.name || null,
      p_contact_info: updates.contact_info || null,
      p_notes: updates.notes || null,
      p_channel_id: updates.channel_id || null
    })

    if (error) {
      console.error('Error updating party info:', error)
      return { success: false, message: error.message }
    }

    if (data && data.length > 0) {
      const result = data[0]
      return {
        success: result.success,
        message: result.message
      }
    }

    return { success: false, message: 'Unknown error occurred' }
  } catch (error) {
    console.error('Error in updatePartyInfo:', error)
    return { success: false, message: 'Failed to update party information' }
  }
}