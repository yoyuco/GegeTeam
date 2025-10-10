// Test account deletion with non-zero stock
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

async function testDeleteWithStock() {
  console.log('🧪 Testing Account Deletion with Stock')
  console.log('======================================')

  try {
    // Step 1: Find an inventory record to modify
    console.log('\n📋 Step 1: Finding inventory record to test with stock...')

    const { data: inventory, error: inventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        id,
        quantity,
        reserved_quantity,
        game_accounts:game_account_id (id, account_name, game_code),
        attributes:currency_attribute_id (name, code)
      `)
      .eq('quantity', 0)
      .limit(1)

    if (inventoryError) {
      console.log('❌ Error finding inventory:', inventoryError.message)
      return
    }

    if (!inventory || inventory.length === 0) {
      console.log('❌ No inventory records found')
      return
    }

    const testRecord = inventory[0]
    console.log(`✅ Found inventory record:`)
    console.log(`   Account: ${testRecord.game_accounts.account_name} (${testRecord.game_accounts.game_code})`)
    console.log(`   Currency: ${testRecord.attributes.name}`)
    console.log(`   Current stock: ${testRecord.quantity + testRecord.reserved_quantity}`)

    // Step 2: Set non-zero stock (positive)
    console.log('\n📋 Step 2: Setting positive stock to test deletion protection...')

    const { data: updatedInventory, error: updateError } = await supabase
      .from('currency_inventory')
      .update({
        quantity: 10,
        reserved_quantity: 5,
        last_updated_at: new Date().toISOString()
      })
      .eq('id', testRecord.id)
      .select()
      .single()

    if (updateError) {
      console.log('❌ Failed to set positive stock:', updateError.message)
      return
    }

    const totalStock = updatedInventory.quantity + updatedInventory.reserved_quantity
    console.log(`✅ Set stock: Quantity=${updatedInventory.quantity}, Reserved=${updatedInventory.reserved_quantity}, Total=${totalStock}`)

    // Step 3: Try to delete the account with stock
    console.log('\n📋 Step 3: Attempting to delete account with non-zero stock...')

    const { error: deleteError } = await supabase
      .from('game_accounts')
      .delete()
      .eq('id', testRecord.game_accounts.id)

    if (deleteError) {
      console.log('✅ SUCCESS: Account deletion was blocked!')
      console.log(`   Error: ${deleteError.message}`)
      console.log('   This means the system is protecting against deleting accounts with stock')
    } else {
      console.log('❌ DANGER: Account deletion succeeded!')
      console.log('   This means account with stock can be deleted - RISKY!')
      console.log('   Need to add protection trigger to prevent this')

      // Check if inventory was also deleted
      const { data: remainingInventory } = await supabase
        .from('currency_inventory')
        .select('*')
        .eq('id', testRecord.id)

      if (remainingInventory && remainingInventory.length === 0) {
        console.log('   ❌ Inventory records were also deleted - DATA LOSS!')
      } else {
        console.log('   ⚠️  Inventory records still exist - potential orphaned data')
      }
    }

    // Step 4: Test with negative stock
    console.log('\n📋 Step 4: Testing with negative stock...')

    // Create a new test account for negative stock test
    const { data: leagues } = await supabase
      .from('attributes')
      .select('id, name')
      .eq('type', 'SEASON_D4')
      .eq('is_active', true)
      .limit(1)

    if (leagues && leagues.length > 0) {
      const uniqueId = Math.random().toString(36).substr(2, 9)
      const negativeTestAccountName = `NegativeStock_Test_${uniqueId}`

      const { data: negativeTestAccount, error: negativeAccountError } = await supabase
        .from('game_accounts')
        .insert({
          game_code: 'DIABLO_4',
          league_attribute_id: leagues[0].id,
          account_name: negativeTestAccountName,
          purpose: 'INVENTORY'
        })
        .select()
        .single()

      if (!negativeAccountError && negativeTestAccount) {
        console.log(`✅ Created negative test account: ${negativeTestAccount.account_name}`)

        // Wait for trigger
        await new Promise(resolve => setTimeout(resolve, 3000))

        // Get inventory record and set negative stock
        const { data: negativeInventory } = await supabase
          .from('currency_inventory')
          .select('id')
          .eq('game_account_id', negativeTestAccount.id)
          .limit(1)

        if (negativeInventory && negativeInventory.length > 0) {
          await supabase
            .from('currency_inventory')
            .update({
              quantity: -10,
              last_updated_at: new Date().toISOString()
            })
            .eq('id', negativeInventory[0].id)

          console.log('✅ Set negative stock: -10')

          // Try to delete account with negative stock
          const { error: negativeDeleteError } = await supabase
            .from('game_accounts')
            .delete()
            .eq('id', negativeTestAccount.id)

          if (negativeDeleteError) {
            console.log('✅ SUCCESS: Account with negative stock deletion was blocked')
          } else {
            console.log('❌ DANGER: Account with negative stock was allowed to be deleted!')
          }
        }
      }
    }

    console.log('\n🎯 CONCLUSION:')
    console.log('   If deletions were blocked: ✅ System is safe')
    console.log('   If deletions succeeded: ❌ Need to add protection trigger!')
    console.log('   Business rule: Accounts with non-zero total stock should NOT be deletable')

  } catch (error) {
    console.error('❌ Test failed:', error.message)
  }
}

testDeleteWithStock()