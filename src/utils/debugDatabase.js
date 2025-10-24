// Debug utility to test database connection and data
import { supabase } from '@/lib/supabase'

export const debugDatabase = async () => {
  console.log('🔍 Debugging database connection...')

  try {
    // Test basic connection
    const { data: testData, error: testError } = await supabase
      .from('channels')
      .select('count')
      .limit(1)

    if (testError) {
      console.error('❌ Database connection error:', testError)
      return false
    }

    console.log('✅ Database connection successful')

    // Check channels
    const { data: channels, error: channelsError } = await supabase
      .from('channels')
      .select('*')

    if (channelsError) {
      console.error('❌ Error fetching channels:', channelsError)
    } else {
      console.log('📊 Channels found:', channels.length)
      console.log('Channels:', channels)

      const salesChannels = channels.filter(c => c.channel_type === 'SALES')
      const purchaseChannels = channels.filter(c => c.channel_type === 'PURCHASE')

      console.log(`💰 Sales channels: ${salesChannels.length}`)
      console.log(`🛒 Purchase channels: ${purchaseChannels.length}`)

      if (purchaseChannels.length === 0) {
        console.warn('⚠️ No PURCHASE channels found - this will cause empty dropdowns!')
      }
    }

    // Check attributes (currencies)
    const { data: attributes, error: attributesError } = await supabase
      .from('attributes')
      .select('*')
      .in('type', ['CURRENCY', 'CURRENCY_TYPE'])
      .limit(20)

    if (attributesError) {
      console.error('❌ Error fetching attributes:', attributesError)
    } else {
      console.log('💱 Currency attributes found:', attributes.length)
      console.log('Currency attributes:', attributes)
    }

    // Check games
    const { data: games, error: gamesError } = await supabase
      .from('attributes')
      .select('*')
      .eq('type', 'GAME')

    if (gamesError) {
      console.error('❌ Error fetching games:', gamesError)
    } else {
      console.log('🎮 Games found:', games.length)
      console.log('Games:', games)
    }

    // Check if we need to set a default game
    if (games && games.length > 0) {
      const poe1Game = games.find(g => g.code === 'POE_1')
      if (poe1Game) {
        console.log('💡 Suggestion: Set POE_1 as default game for testing')
      }
    }

    return true

  } catch (error) {
    console.error('❌ Debug database error:', error)
    return false
  }
}

// Function to add missing purchase channels
export const setupPurchaseChannels = async () => {
  console.log('🔧 Setting up purchase channels...')

  const purchaseChannels = [
    {
      id: 'pur001',
      code: 'Discord_Farmers',
      name: 'Discord Farmers',
      description: 'Discord communities and farmer groups where we purchase currencies',
      channel_type: 'PURCHASE',
      is_active: true
    },
    {
      id: 'pur002',
      code: 'Facebook_Groups',
      name: 'Facebook Groups',
      description: 'Facebook groups and communities for currency purchases',
      channel_type: 'PURCHASE',
      is_active: true
    },
    {
      id: 'pur003',
      code: 'Direct_Farmers',
      name: 'Direct Farmers',
      description: 'Direct contracts with individual farmers',
      channel_type: 'PURCHASE',
      is_active: true
    },
    {
      id: 'pur004',
      code: 'Trading_Communities',
      name: 'Trading Communities',
      description: 'Various trading communities and forums',
      channel_type: 'PURCHASE',
      is_active: true
    },
    {
      id: 'pur005',
      code: 'In_Game_Trade',
      name: 'In-Game Trade',
      description: 'Direct in-game trading channels',
      channel_type: 'PURCHASE',
      is_active: true
    }
  ]

  try {
    const { data, error } = await supabase
      .from('channels')
      .upsert(purchaseChannels, { onConflict: 'id' })
      .select()

    if (error) {
      console.error('❌ Error adding purchase channels:', error)
      return false
    }

    console.log('✅ Purchase channels added successfully:', data?.length || 0)
    return true

  } catch (error) {
    console.error('❌ Setup purchase channels error:', error)
    return false
  }
}

// Function to add missing game currency attributes
export const setupGameCurrencies = async () => {
  console.log('🔧 Setting up game currency attributes...')

  const gameCurrencies = [
    // POE1 Currencies - use POE1_CURRENCY type
    { code: 'DIVINE_ORB_POE1', name: 'Divine Orb', type: 'POE1_CURRENCY', is_active: true },
    { code: 'CHAOS_ORB_POE1', name: 'Chaos Orb', type: 'POE1_CURRENCY', is_active: true },
    { code: 'EXALTED_ORB_POE1', name: 'Exalted Orb', type: 'POE1_CURRENCY', is_active: true },
    { code: 'MIRROR_OF_KALANDRA_POE1', name: 'Mirror of Kalandra', type: 'POE1_CURRENCY', is_active: true },
    { code: 'BLESSED_ORB_POE1', name: 'Blessed Orb', type: 'POE1_CURRENCY', is_active: true },
    { code: 'REGAL_ORB_POE1', name: 'Regal Orb', type: 'POE1_CURRENCY', is_active: true },
    { code: 'VAAL_ORB_POE1', name: 'Vaal Orb', type: 'POE1_CURRENCY', is_active: true },
    { code: 'DIVINE_ORB_POE2', name: 'Divine Orb', type: 'POE2_CURRENCY', is_active: true },
    { code: 'CHAOS_ORB_POE2', name: 'Chaos Orb', type: 'POE2_CURRENCY', is_active: true },
    { code: 'EXALTED_ORB_POE2', name: 'Exalted Orb', type: 'POE2_CURRENCY', is_active: true },
    { code: 'GOLD_D4', name: 'Gold', type: 'D4_CURRENCY', is_active: true },
    { code: 'REDUCED_HATE_FEAR_D4', name: 'Reduced Hate/Fear', type: 'D4_CURRENCY', is_active: true },
    { code: 'FORGIVENESS_ANGEL_D4', name: 'Forgiveness Angel', type: 'D4_CURRENCY', is_active: true }
  ]

  try {
    const { data, error } = await supabase
      .from('attributes')
      .upsert(gameCurrencies, { onConflict: 'code' })
      .select()

    if (error) {
      console.error('❌ Error adding game currencies:', error)
      return false
    }

    console.log('✅ Game currencies added successfully:', data?.length || 0)
    return true

  } catch (error) {
    console.error('❌ Setup game currencies error:', error)
    return false
  }
}