// Check for existing inventory conflicts
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

async function checkInventoryConflict() {
  console.log('🔍 Checking Inventory Conflicts')
  console.log('===============================')

  try {
    // Step 1: Get CURRENCY_D4 items
    console.log('\n📋 Step 1: Getting CURRENCY_D4 items...')

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
      console.log(`   ${index + 1}. ${item.name} (${item.code}) - ID: ${item.id}`)
    })

    // Step 2: Check existing inventory records for each CURRENCY_D4
    console.log('\n📋 Step 2: Checking existing inventory records...')

    for (const currency of d4Currencies) {
      const { data: inventory, error: inventoryError } = await supabase
        .from('currency_inventory')
        .select(`
          *,
          game_accounts:game_account_id (id, game_code, account_name)
        `)
        .eq('currency_attribute_id', currency.id)

      if (inventoryError) {
        console.log(`❌ Error checking inventory for ${currency.code}:`, inventoryError.message)
      } else {
        console.log(`\n📊 Inventory records for ${currency.name} (${currency.code}):`)
        if (inventory.length === 0) {
          console.log(`   ✅ No existing records - can create new ones`)
        } else {
          console.log(`   ⚠️  Found ${inventory.length} existing records:`)
          inventory.forEach((record, index) => {
            console.log(`   ${index + 1}. Account: ${record.game_accounts.account_name} (${record.game_accounts.game_code}) - Qty: ${record.quantity}`)
          })
        }
      }
    }

    // Step 3: Try to manually create inventory to test constraint
    console.log('\n📋 Step 3: Testing manual inventory creation...')

    const d4Currency = d4Currencies[0] // Use first currency
    const uniqueId = Math.random().toString(36).substr(2, 9)
    const testAccountName = `DIABLO4_ManualTest_${uniqueId}`

    // First, get a D4 league
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

    // Create account without trigger
    console.log(`\n📝 Creating account: ${testAccountName}`)

    const { data: newAccount, error: accountError } = await supabase
      .from('game_accounts')
      .insert({
        game_code: 'DIABLO_4',
        league_attribute_id: leagues[0].id,
        account_name: testAccountName,
        purpose: 'INVENTORY'
      })
      .select()
      .single()

    if (accountError) {
      console.log('❌ Account creation failed:', accountError.message)
      return
    }

    console.log(`✅ Account created: ${newAccount.id}`)

    // Wait to see if trigger creates inventory
    await new Promise(resolve => setTimeout(resolve, 2000))

    // Check if trigger already created inventory
    const { data: existingInventory } = await supabase
      .from('currency_inventory')
      .select('*')
      .eq('game_account_id', newAccount.id)
      .eq('currency_attribute_id', d4Currency.id)

    if (existingInventory && existingInventory.length > 0) {
      console.log('✅ Trigger already created inventory record!')
      console.log('   This confirms trigger is working for DIABLO_4')
    } else {
      console.log('⚠️  Trigger did not create inventory - trying manual creation...')

      // Try to create inventory manually
      const { data: manualInventory, error: manualError } = await supabase
        .from('currency_inventory')
        .insert({
          game_account_id: newAccount.id,
          currency_attribute_id: d4Currency.id,
          quantity: 0,
          reserved_quantity: 0,
          avg_buy_price_vnd: 0,
          avg_buy_price_usd: 0,
          last_updated_at: new Date().toISOString()
        })
        .select()
        .single()

      if (manualError) {
        console.log('❌ Manual inventory creation failed:', manualError.message)
      } else {
        console.log('✅ Manual inventory creation successful')
      }
    }

    // Cleanup
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
    console.error('❌ Check failed:', error.message)
  }
}

checkInventoryConflict()