// Test negative inventory values
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

async function testNegativeInventory() {
  console.log('🧪 Testing Negative Inventory Values')
  console.log('====================================')

  try {
    // Step 1: Get an existing inventory record to test with
    console.log('\n📋 Step 1: Finding inventory record to test...')

    const { data: inventory, error: inventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        id,
        quantity,
        reserved_quantity,
        game_accounts:game_account_id (account_name, game_code),
        attributes:currency_attribute_id (name, code)
      `)
      .eq('quantity', 0) // Start with zero quantity record
      .limit(1)

    if (inventoryError) {
      console.log('❌ Error finding inventory:', inventoryError.message)
      return
    }

    if (!inventory || inventory.length === 0) {
      console.log('⚠️  No zero-quantity inventory records found. Creating test account...')

      // Create test account with inventory
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

      const uniqueId = Math.random().toString(36).substr(2, 9)
      const testAccountName = `NEGATIVE_Test_${uniqueId}`

      const { data: testAccount, error: accountError } = await supabase
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
        console.log('❌ Failed to create test account:', accountError.message)
        return
      }

      console.log(`✅ Created test account: ${testAccount.account_name}`)

      // Wait for trigger
      await new Promise(resolve => setTimeout(resolve, 3000))

      // Get the new inventory record
      const { data: newInventory } = await supabase
        .from('currency_inventory')
        .select(`
          id,
          quantity,
          reserved_quantity,
          game_accounts:game_account_id (account_name, game_code),
          attributes:currency_attribute_id (name, code)
        `)
        .eq('game_account_id', testAccount.id)

      if (!newInventory || newInventory.length === 0) {
        console.log('❌ Failed to get inventory for test account')
        return
      }

      inventory.push(...newInventory)
    }

    const testRecord = inventory[0]
    console.log(`✅ Found inventory record to test:`)
    console.log(`   Account: ${testRecord.game_accounts.account_name} (${testRecord.game_accounts.game_code})`)
    console.log(`   Currency: ${testRecord.attributes.name} (${testRecord.attributes.code})`)
    console.log(`   Current: Qty=${testRecord.quantity}, Reserved=${testRecord.reserved_quantity}`)

    // Step 2: Test negative quantity
    console.log('\n📋 Step 2: Testing negative quantity...')

    const { data: negativeResult, error: negativeError } = await supabase
      .from('currency_inventory')
      .update({
        quantity: -10,
        last_updated_at: new Date().toISOString()
      })
      .eq('id', testRecord.id)
      .select()
      .single()

    if (negativeError) {
      console.log('❌ Failed to set negative quantity:', negativeError.message)
      console.log('   This suggests negative quantities are NOT allowed')
    } else {
      console.log('✅ SUCCESS: Set negative quantity!')
      console.log(`   New quantity: ${negativeResult.quantity}`)
    }

    // Step 3: Test negative reserved_quantity
    console.log('\n📋 Step 3: Testing negative reserved_quantity...')

    const { data: negativeReservedResult, error: negativeReservedError } = await supabase
      .from('currency_inventory')
      .update({
        reserved_quantity: -5,
        last_updated_at: new Date().toISOString()
      })
      .eq('id', testRecord.id)
      .select()
      .single()

    if (negativeReservedError) {
      console.log('❌ Failed to set negative reserved_quantity:', negativeReservedError.message)
      console.log('   This suggests negative reserved quantities are NOT allowed')
    } else {
      console.log('✅ SUCCESS: Set negative reserved_quantity!')
      console.log(`   New reserved_quantity: ${negativeReservedResult.reserved_quantity}`)
    }

    // Step 4: Test both negative
    console.log('\n📋 Step 4: Testing both quantities negative...')

    const { data: bothNegativeResult, error: bothNegativeError } = await supabase
      .from('currency_inventory')
      .update({
        quantity: -20,
        reserved_quantity: -15,
        last_updated_at: new Date().toISOString()
      })
      .eq('id', testRecord.id)
      .select()
      .single()

    if (bothNegativeError) {
      console.log('❌ Failed to set both quantities negative:', bothNegativeError.message)
    } else {
      console.log('✅ SUCCESS: Set both quantities negative!')
      console.log(`   Quantity: ${bothNegativeResult.quantity}, Reserved: ${bothNegativeResult.reserved_quantity}`)
    }

    // Step 5: Check current state
    console.log('\n📋 Step 5: Checking final state...')

    const { data: finalState, error: finalError } = await supabase
      .from('currency_inventory')
      .select('quantity, reserved_quantity')
      .eq('id', testRecord.id)
      .single()

    if (finalError) {
      console.log('❌ Error checking final state:', finalError.message)
    } else {
      console.log(`📊 Final state:`)
      console.log(`   Quantity: ${finalState.quantity}`)
      console.log(`   Reserved: ${finalState.reserved_quantity}`)
      console.log(`   Total: ${finalState.quantity + finalState.reserved_quantity}`)
    }

    // Step 6: Reset to 0 for cleanup
    console.log('\n📋 Step 6: Resetting to 0 for cleanup...')

    const { error: resetError } = await supabase
      .from('currency_inventory')
      .update({
        quantity: 0,
        reserved_quantity: 0,
        last_updated_at: new Date().toISOString()
      })
      .eq('id', testRecord.id)

    if (resetError) {
      console.log('⚠️  Failed to reset to 0:', resetError.message)
    } else {
      console.log('✅ Reset to 0 completed')
    }

    console.log('\n🎯 CONCLUSION:')
    console.log('   If all tests succeeded: Negative inventory is ALLOWED ✅')
    console.log('   If any tests failed: Negative inventory is BLOCKED ❌')
    console.log('   If blocked: Need to update database constraints to allow negative values')

  } catch (error) {
    console.error('❌ Test failed:', error.message)
  }
}

testNegativeInventory()