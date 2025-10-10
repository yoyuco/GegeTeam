// Check results of manual trigger test
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

async function checkManualTest() {
  console.log('🔍 Checking Manual Trigger Test Results')
  console.log('=====================================')
  console.log('Account ID from manual test: 1ece72e8-c61d-4a65-8380-3a49e7b622eb')

  try {
    // Check inventory records for the manually created account
    const { data: inventory, error: inventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        *,
        attributes:currency_attribute_id (name, code, type, is_active)
      `)
      .eq('game_account_id', '1ece72e8-c61d-4a65-8380-3a49e7b622eb')

    if (inventoryError) {
      console.error('❌ Error checking inventory:', inventoryError.message)
      return
    }

    console.log(`📊 Found ${inventory.length} inventory records for manual test account`)

    if (inventory.length > 0) {
      console.log('\n✅ SUCCESS: Trigger IS working!')
      console.log(`   Created ${inventory.length} inventory records`)

      console.log('\n📋 Inventory Details:')
      inventory.forEach((record, index) => {
        console.log(`   ${index + 1}. ${record.attributes.name} (${record.attributes.code})`)
        console.log(`      Type: ${record.attributes.type}`)
        console.log(`      Active: ${record.attributes.is_active}`)
        console.log(`      Quantity: ${record.quantity}`)
      })

      // Check currency types
      const poe2Count = inventory.filter(r => r.attributes.type === 'CURRENCY_POE2').length
      const otherCount = inventory.length - poe2Count

      console.log(`\n📈 Currency Type Analysis:`)
      console.log(`   CURRENCY_POE2 records: ${poe2Count}`)
      console.log(`   Other currency types: ${otherCount}`)

      if (otherCount === 0 && poe2Count > 0) {
        console.log('\n✅ PERFECT: All records are CURRENCY_POE2!')
        console.log('✅ Trigger is working correctly now!')
      } else if (otherCount > 0) {
        console.log('\n⚠️  Mixed currency types found')
        const nonPoe2Records = inventory.filter(r => r.attributes.type !== 'CURRENCY_POE2')
        console.log('Non-POE2 currencies:')
        nonPoe2Records.forEach(record => {
          console.log(`   - ${record.attributes.name} (${record.attributes.type})`)
        })
      }
    } else {
      console.log('\n❌ PROBLEM: No inventory records created!')
      console.log('   Trigger exists but is not firing')
      console.log('\n🔧 Possible solutions:')
      console.log('   1. Check if trigger is enabled: ALTER TABLE game_accounts ENABLE TRIGGER trigger_auto_create_inventory_records')
      console.log('   2. Check trigger permissions: SELECT * FROM information_schema.triggers WHERE trigger_name = \'trigger_auto_create_inventory_records\'')
      console.log('   3. Check if there are any constraints preventing INSERT')
      console.log('   4. Check database logs for trigger errors')
    }

    // Also check the game account details
    const { data: account, error: accountError } = await supabase
      .from('game_accounts')
      .select('*')
      .eq('id', '1ece72e8-c61d-4a65-8380-3a49e7b622eb')
      .single()

    if (!accountError && account) {
      console.log('\n📋 Game Account Details:')
      console.log(`   Account Name: ${account.account_name}`)
      console.log(`   Game Code: ${account.game_code}`)
      console.log(`   Purpose: ${account.purpose}`)
      console.log(`   League ID: ${account.league_attribute_id}`)
      console.log(`   Is Active: ${account.is_active}`)
    }

  } catch (error) {
    console.error('❌ Check failed:', error.message)
  }
}

checkManualTest()