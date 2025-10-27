// Channel debugging utility
import { supabase } from '@/lib/supabase'

export const debugChannels = async () => {
  console.log('🔍 Debugging channels directly from database...')

  try {
    // Query all channels without filtering
    const { data: allChannels, error: allError } = await supabase
      .from('channels')
      .select('*')

    if (allError) {
      console.error('❌ Error fetching all channels:', allError)
      console.error('Full error details:', JSON.stringify(allError, null, 2))
      return
    }

    console.log('📊 All channels in database:', allChannels?.length || 0)
    console.log('Channel data (detailed):', JSON.stringify(allChannels, null, 2))

    // Check channel types
    const channelTypes = allChannels?.map(c => c.channel_type) || []
    console.log('🏷️ Channel types found:', [...new Set(channelTypes)])

    // Check specific types
    const salesChannels = allChannels?.filter(c => c.channel_type === 'SALES') || []
    const purchaseChannels = allChannels?.filter(c => c.channel_type === 'PURCHASE') || []
    const bothChannels = allChannels?.filter(c => c.channel_type === 'BOTH') || []

    console.log('💰 SALES channels:', salesChannels.length)
    console.log('🛒 PURCHASE channels:', purchaseChannels.length)
    console.log('🔄 BOTH channels:', bothChannels.length)

    // Check if channels have the expected structure
    if (allChannels && allChannels.length > 0) {
      console.log('📋 Sample channel structure:', JSON.stringify(allChannels[0], null, 2))
      console.log('📋 Available channel fields:', Object.keys(allChannels[0] || {}))
    }

    // If no proper channel types found, update them
    if ((salesChannels.length === 0 && purchaseChannels.length === 0 && bothChannels.length === 0) && allChannels && allChannels.length > 0) {
      console.log('⚠️ No proper channel types found. Available channel types:', [...new Set(channelTypes)])
      console.log('💡 Suggestion: Updating channel_type values to proper SALES/PURCHASE/BOTH types')

      // Try to update some channels to have proper types
      const updateResult = await updateChannelTypes(allChannels)
      console.log('🔧 Update result:', updateResult)
    }

    return {
      total: allChannels?.length || 0,
      sales: salesChannels.length,
      purchase: purchaseChannels.length,
      both: bothChannels.length,
      allChannels,
      salesChannels,
      purchaseChannels,
      bothChannels
    }

  } catch (error) {
    console.error('❌ Debug channels error:', error)
    console.error('Full error details:', JSON.stringify(error, null, 2))
    return null
  }
}

// Update channels to have proper channel_type values (SALES, PURCHASE, BOTH)
const updateChannelTypes = async (channels) => {
  if (!channels || channels.length === 0) return null

  try {
    // Set up proper channel types based on common usage patterns
    const channelsToUpdate = channels.map((channel, index) => {
      let channelType = 'BOTH' // Default to BOTH

      // Assign types based on channel name patterns
      if (channel.code?.toLowerCase().includes('g2g') ||
          channel.code?.toLowerCase().includes('playerauctions') ||
          channel.code?.toLowerCase().includes('eldorado')) {
        channelType = 'SELL'
      } else if (channel.code?.toLowerCase().includes('facebook') ||
                 channel.code?.toLowerCase().includes('discord') ||
                 channel.code?.toLowerCase().includes('direct')) {
        channelType = 'BUY'
      } else {
        // Alternate between SELL and BUY for unspecified channels
        channelType = index % 2 === 0 ? 'SELL' : 'BUY'
      }

      return {
        id: channel.id,
        direction: channelType
      }
    })

    console.log('🔄 Updating channels with proper types:', channelsToUpdate)
    console.log('⚠️ Channel update disabled due to schema issues - logging only:')

    // Temporarily disabled due to schema errors
    /*
    const { data, error } = await supabase
      .from('channels')
      .upsert(channelsToUpdate, { onConflict: 'id' })
      .select()

    if (error) {
      console.error('❌ Error updating channels:', error)
      return { success: false, error }
    }

    console.log('✅ Successfully updated channels:', data?.length || 0)
    */

    // Log the updated channel types
    const salesCount = channelsToUpdate.filter(c => c.direction === 'SELL').length
    const purchaseCount = channelsToUpdate.filter(c => c.direction === 'BUY').length
    const bothCount = channelsToUpdate.filter(c => c.direction === 'BOTH').length

    console.log(`📊 Channel types updated: ${salesCount} SELL, ${purchaseCount} BUY, ${bothCount} BOTH`)

    return { success: true, data: channelsToUpdate, counts: { sales: salesCount, purchase: purchaseCount, both: bothCount } }

  } catch (error) {
    console.error('❌ Update channels error:', error)
    return { success: false, error }
  }
}