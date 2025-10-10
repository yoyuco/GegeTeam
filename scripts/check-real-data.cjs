// Check real data in staging database
const { createClient } = require('@supabase/supabase-js')
const fs = require('fs')

// Load environment from .env.staging
function loadEnvFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8')
    const env = {}

    content.split('\n').forEach(line => {
      const trimmed = line.trim()
      if (trimmed && !trimmed.startsWith('#')) {
        const match = trimmed.match(/^([^=]+)=(.*)$/)
        if (match) {
          let value = match[2]
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.slice(1, -1)
          }
          env[match[1]] = value
        }
      }
    })

    return env
  } catch (error) {
    console.error('Error loading env file:', error.message)
    return {}
  }
}

const env = loadEnvFile('.env.staging')
const supabaseUrl = env.VITE_SUPABASE_URL
const serviceRoleKey = env.VITE_SERVICE_ROLE_KEY

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
})

async function checkRealData() {
  console.log('🔍 Checking Real Data in Staging Database')
  console.log('=========================================')

  try {
    // Check game_codes in game_accounts
    console.log('\n📋 1. Game codes in game_accounts:')
    const { data: gameAccounts, error: gameError } = await supabase
      .from('game_accounts')
      .select('game_code')

    if (gameError) {
      console.error('❌ Error:', gameError.message)
    } else {
      const gameCodes = [...new Set(gameAccounts?.map(d => d.game_code))]
      console.log('   Available game_codes:', gameCodes)
    }

    // Check CURRENCY_D4 items
    console.log('\n📋 2. CURRENCY_D4 items:')
    const { data: d4Items, error: d4Error } = await supabase
      .from('attributes')
      .select('name, code, type, is_active')
      .eq('type', 'CURRENCY_D4')
      .limit(10)

    if (d4Error) {
      console.error('❌ Error:', d4Error.message)
    } else {
      console.log(`   Found ${d4Items.length} CURRENCY_D4 items`)
      d4Items.forEach((item, index) => {
        console.log(`   ${index + 1}. ${item.name} (${item.code}) - Active: ${item.is_active}`)
      })
    }

    // Check other currency types
    console.log('\n📋 3. All currency types:')
    const { data: currencyTypes, error: typesError } = await supabase
      .from('attributes')
      .select('type')
      .like('type', 'CURRENCY_%')
      .group('type')
      .order('type')

    if (typesError) {
      console.error('❌ Error:', typesError.message)
    } else {
      console.log('   Available currency types:')
      currencyTypes.forEach(type => {
        console.log(`   - ${type.type}`)
      })
    }

    // Check POE_2 currencies
    console.log('\n📋 4. POE_2 currencies count:')
    const { count, error: poe2Error } = await supabase
      .from('attributes')
      .select('*', { count: 'exact', head: true })
      .eq('type', 'CURRENCY_POE2')
      .eq('is_active', true)

    if (poe2Error) {
      console.error('❌ Error:', poe2Error.message)
    } else {
      console.log(`   Active CURRENCY_POE2 count: ${count}`)
    }

    // Check game_code enum definition
    console.log('\n📋 5. Game code enum check:')
    try {
      // Try to insert with DIABLO_4 to see the actual enum value
      const { data: testInsert, error: insertError } = await supabase
        .from('game_accounts')
        .insert({
          game_code: 'DIABLO_4',
          league_attribute_id: null,
          account_name: 'Enum_Test_Delete_Me',
          purpose: 'INVENTORY'
        })
        .select('game_code')
        .single()

      if (insertError) {
        console.log('   Enum test failed:', insertError.message)
        console.log('   This shows the actual enum constraint')
      } else {
        console.log('   DIABLO_4 is valid in enum')
      }

      // Cleanup
      if (!insertError) {
        await supabase
          .from('game_accounts')
          .delete()
          .eq('account_name', 'Enum_Test_Delete_Me')
      }
    } catch (err) {
      console.log('   Enum test error:', err.message)
    }

  } catch (error) {
    console.error('❌ Script failed:', error.message)
  }
}

checkRealData()