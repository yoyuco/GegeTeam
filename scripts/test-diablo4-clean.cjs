// Clean test for DIABLO_4 trigger functionality
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

async function testDiablo4Trigger() {
  console.log('🧪 Testing DIABLO_4 Trigger Functionality')
  console.log('==========================================')

  try {
    // Step 1: Get D4 league
    console.log('\n📋 Step 1: Getting D4 league...')

    const { data: leagues } = await supabase
      .from('attributes')
      .select('id, name')
      .eq('type', 'SEASON_D4')
      .eq('is_active', true)
      .limit(1)

    if (!leagues || leagues.length === 0) {
      console.log('❌ No D4 leagues found')
      return
    }

    console.log(`✅ Found D4 league: ${leagues[0].name}`)

    // Step 2: Get CURRENCY_D4 items
    console.log('\n📋 Step 2: Getting CURRENCY_D4 items...')

    const { data: d4Currencies } = await supabase
      .from('attributes')
      .select('id, name, code')
      .eq('type', 'CURRENCY_D4')
      .eq('is_active', true)

    if (!d4Currencies || d4Currencies.length === 0) {
      console.log('❌ No CURRENCY_D4 items found')
      return
    }

    console.log(`✅ Found ${d4Currencies.length} CURRENCY_D4 items:`)
    d4Currencies.forEach((item, index) => {
      console.log(`   ${index + 1}. ${item.name} (${item.code})`)
    })

    // Step 3: Create unique test account
    const uniqueId = Math.random().toString(36).substr(2, 9)
    const testAccountName = `DIABLO4_CleanTest_${uniqueId}`

    console.log(`\n📋 Step 3: Creating DIABLO_4 account: ${testAccountName}`)

    const { data: newAccount, error: insertError } = await supabase
      .from('game_accounts')
      .insert({
        game_code: 'DIABLO_4',
        league_attribute_id: leagues[0].id,
        account_name: testAccountName,
        purpose: 'INVENTORY'
      })
      .select()
      .single()

    if (insertError) {
      console.log('❌ Account creation failed:', insertError.message)
      return
    }

    console.log(`✅ Account created: ${newAccount.account_name} (ID: ${newAccount.id})`)

    // Step 4: Wait for trigger to execute
    console.log('\n📋 Step 4: Waiting for trigger to execute...')
    await new Promise(resolve => setTimeout(resolve, 3000))

    // Step 5: Check inventory records
    console.log('\n📋 Step 5: Checking inventory records...')

    const { data: inventory, error: inventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        *,
        attributes:currency_attribute_id (name, code, type)
      `)
      .eq('game_account_id', newAccount.id)

    if (inventoryError) {
      console.log('❌ Error checking inventory:', inventoryError.message)
    } else {
      console.log(`📊 Found ${inventory.length} inventory records:`)

      let d4Count = 0
      inventory.forEach((record, index) => {
        console.log(`   ${index + 1}. ${record.attributes.name} (${record.attributes.code}) - Quantity: ${record.quantity}`)
        if (record.attributes.type === 'CURRENCY_D4') {
          d4Count++
        }
      })

      console.log(`\n🎯 RESULTS:`)
      console.log(`   Total inventory records: ${inventory.length}`)
      console.log(`   CURRENCY_D4 records: ${d4Count}`)
      console.log(`   Expected CURRENCY_D4 items: ${d4Currencies.length}`)

      if (d4Count === d4Currencies.length) {
        console.log('✅ SUCCESS: Trigger created inventory for all CURRENCY_D4 items!')
      } else {
        console.log('⚠️  PARTIAL: Trigger created some inventory records but not all')
      }
    }

    // Step 6: Cleanup
    console.log('\n📋 Step 6: Cleaning up test data...')

    await supabase
      .from('currency_inventory')
      .delete()
      .eq('game_account_id', newAccount.id)

    await supabase
      .from('game_accounts')
      .delete()
      .eq('id', newAccount.id)

    console.log('✅ Cleanup completed')

  } catch (error) {
    console.error('❌ Test failed:', error.message)
  }
}

testDiablo4Trigger()