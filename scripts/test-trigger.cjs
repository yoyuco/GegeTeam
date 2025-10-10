// Quick test for trigger after migration
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

async function testTrigger() {
  console.log('🧪 Testing Trigger After Migration')
  console.log('==================================')

  try {
    // Get POE_2 league
    const { data: leagues } = await supabase
      .from('attributes')
      .select('id')
      .eq('type', 'LEAGUE_POE2')
      .limit(1)

    if (!leagues || leagues.length === 0) {
      console.log('❌ No POE_2 league found')
      return
    }

    const leagueId = leagues[0].id
    console.log(`✅ Using POE_2 league`)

    // Create test account
    const testAccountName = `Test_Trigger_${Date.now()}`
    console.log(`📝 Creating test account: ${testAccountName}`)

    const { data: newAccount, error: insertError } = await supabase
      .from('game_accounts')
      .insert({
        game_code: 'POE_2',
        league_attribute_id: leagueId,
        account_name: testAccountName,
        purpose: 'INVENTORY'
      })
      .select()
      .single()

    if (insertError) {
      console.error('❌ Error creating account:', insertError.message)
      return
    }

    console.log(`✅ Account created: ${newAccount.id}`)

    // Wait for trigger to execute
    await new Promise(resolve => setTimeout(resolve, 3000))

    // Check inventory records
    const { data: inventory, error: inventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        *,
        attributes:currency_attribute_id (name, code, type)
      `)
      .eq('game_account_id', newAccount.id)

    if (inventoryError) {
      console.error('❌ Error checking inventory:', inventoryError.message)
    } else {
      console.log(`📊 Found ${inventory.length} inventory records`)

      if (inventory.length > 0) {
        console.log('✅ SUCCESS: Trigger is working!')
        console.log(`   Created ${inventory.length} inventory records`)

        // Show first few records
        inventory.slice(0, 3).forEach((record, index) => {
          console.log(`   ${index + 1}. ${record.attributes.name} (${record.attributes.type})`)
        })

        // Check currency types
        const poe2Count = inventory.filter(r => r.attributes.type === 'CURRENCY_POE2').length
        const otherCount = inventory.length - poe2Count

        console.log(`📈 CURRENCY_POE2 records: ${poe2Count}`)
        console.log(`📈 Other currency types: ${otherCount}`)

        if (otherCount === 0) {
          console.log('✅ PERFECT: All records are CURRENCY_POE2!')
        } else {
          console.log('⚠️  Some records are not CURRENCY_POE2')
        }
      } else {
        console.log('❌ FAILED: No inventory records created')
        console.log('   Trigger is still not working')
      }
    }

    // Cleanup
    console.log('\n🧹 Cleaning up...')
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

testTrigger()