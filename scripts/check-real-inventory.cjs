// Check real inventory status in the database
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

async function checkRealInventory() {
  console.log('🔍 Checking Real Inventory Status')
  console.log('=================================')

  try {
    // Step 1: Check total inventory records
    console.log('\n📊 Step 1: Total inventory records')

    const { count: totalInventory, error: countError } = await supabase
      .from('currency_inventory')
      .select('*', { count: 'exact', head: true })

    if (countError) {
      console.log('❌ Error counting inventory:', countError.message)
    } else {
      console.log(`Total inventory records: ${totalInventory || 0}`)
    }

    // Step 2: Check all game accounts
    console.log('\n📊 Step 2: All game accounts')

    const { data: accounts, error: accountsError } = await supabase
      .from('game_accounts')
      .select(`
        id,
        game_code,
        account_name,
        purpose,
        created_at
      `)
      .order('created_at', { ascending: false })

    if (accountsError) {
      console.log('❌ Error fetching accounts:', accountsError.message)
    } else {
      console.log(`Found ${accounts.length} game accounts:`)

      accounts.forEach((account, index) => {
        console.log(`\n${index + 1}. ${account.account_name}`)
        console.log(`   Game: ${account.game_code}`)
        console.log(`   Purpose: ${account.purpose}`)
        console.log(`   Created: ${account.created_at}`)
      })
    }

    // Step 3: Check inventory for each account
    console.log('\n📊 Step 3: Inventory by account')

    for (const account of (accounts || [])) {
      const { data: inventory, error: inventoryError } = await supabase
        .from('currency_inventory')
        .select(`
          quantity,
          attributes:currency_attribute_id (name, code, type)
        `)
        .eq('game_account_id', account.id)

      if (inventoryError) {
        console.log(`\n❌ Error checking inventory for ${account.account_name}:`, inventoryError.message)
      } else {
        console.log(`\n💰 Inventory for ${account.account_name} (${account.game_code}):`)
        if (inventory.length === 0) {
          console.log(`   📭 No inventory records`)
        } else {
          inventory.forEach((record, idx) => {
            console.log(`   ${idx + 1}. ${record.attributes.name} (${record.attributes.code}) - Qty: ${record.quantity}`)
          })
        }
      }
    }

    // Step 4: Test trigger by creating a real DIABLO_4 account
    console.log('\n🧪 Step 4: Testing trigger with real DIABLO_4 account')

    // Get D4 league
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

    console.log(`✅ Using league: ${leagues[0].name}`)

    // Create unique test account
    const uniqueId = Math.random().toString(36).substr(2, 9)
    const testAccountName = `DIABLO4_RealTest_${uniqueId}`

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
      console.log('   This might indicate the trigger is failing!')
      return
    }

    console.log(`✅ Account created: ${newAccount.id}`)

    // Wait for trigger
    await new Promise(resolve => setTimeout(resolve, 3000))

    // Check inventory immediately
    const { data: newInventory, error: newInventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        quantity,
        attributes:currency_attribute_id (name, code, type)
      `)
      .eq('game_account_id', newAccount.id)

    if (newInventoryError) {
      console.log('❌ Error checking new inventory:', newInventoryError.message)
    } else {
      console.log(`\n💰 Inventory for new account ${testAccountName}:`)
      if (newInventory.length === 0) {
        console.log('   📭 NO INVENTORY RECORDS CREATED!')
        console.log('   ❌ Trigger did NOT work')
      } else {
        console.log(`   ✅ Found ${newInventory.length} inventory records:`)
        newInventory.forEach((record, idx) => {
          console.log(`   ${idx + 1}. ${record.attributes.name} (${record.attributes.code}) - Qty: ${record.quantity}`)
        })
        console.log('   ✅ Trigger worked!')
      }
    }

    // Check total inventory count again
    const { count: newTotalInventory } = await supabase
      .from('currency_inventory')
      .select('*', { count: 'exact', head: true })

    console.log(`\n📊 Total inventory after test: ${newTotalInventory || 0}`)

    // Don't cleanup so you can verify manually
    console.log(`\n📝 Test account ${testAccountName} left for manual verification`)

  } catch (error) {
    console.error('❌ Check failed:', error.message)
  }
}

checkRealInventory()