// Test account deletion with zero stock but no inventory records
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

async function testZeroStockDeletion() {
  console.log('🧪 Testing Account Deletion with Zero Stock')
  console.log('==========================================')

  try {
    // Step 1: Find an account with inventory to test with
    console.log('\n📋 Step 1: Finding account with inventory records...')

    const { data: accounts, error: accountsError } = await supabase
      .from('game_accounts')
      .select(`
        id,
        account_name,
        game_code,
        currency_inventory (
          id,
          quantity,
          reserved_quantity,
          attributes:currency_attribute_id (name, code)
        )
      `)
      .eq('purpose', 'INVENTORY')

    if (accountsError) {
      console.log('❌ Error finding accounts:', accountsError.message)
      return
    }

    if (!accounts || accounts.length === 0) {
      console.log('❌ No accounts found')
      return
    }

    const testAccount = accounts[0]
    console.log(`✅ Found test account: ${testAccount.account_name} (${testAccount.game_code})`)

    if (testAccount.currency_inventory && testAccount.currency_inventory.length > 0) {
      const inventory = testAccount.currency_inventory[0]
      const totalStock = inventory.quantity + inventory.reserved_quantity
      console.log(`   Current inventory: ${inventory.attributes.name}`)
      console.log(`   Stock: Qty=${inventory.quantity}, Reserved=${inventory.reserved_quantity}, Total=${totalStock}`)

      // Step 2: Set stock to exactly zero
      console.log('\n📋 Step 2: Setting stock to zero...')

      const { data: updatedInventory, error: updateError } = await supabase
        .from('currency_inventory')
        .update({
          quantity: 0,
          reserved_quantity: 0,
          last_updated_at: new Date().toISOString()
        })
        .eq('id', inventory.id)
        .select()
        .single()

      if (updateError) {
        console.log('❌ Failed to set stock to zero:', updateError.message)
        return
      }

      console.log(`✅ Set stock to zero: Qty=${updatedInventory.quantity}, Reserved=${updatedInventory.reserved_quantity}`)

      // Step 3: Try to delete account with zero stock
      console.log('\n📋 Step 3: Attempting to delete account with zero stock...')

      const { error: deleteError } = await supabase
        .from('game_accounts')
        .delete()
        .eq('id', testAccount.id)

      if (deleteError) {
        console.log('❌ Account deletion was blocked!')
        console.log(`   Error message: ${deleteError.message}`)
        console.log('   This might be too restrictive - accounts with zero stock should be deletable')

        // Check what inventory records still exist
        const { data: remainingInventory } = await supabase
          .from('currency_inventory')
          .select('*')
          .eq('game_account_id', testAccount.id)

        if (remainingInventory && remainingInventory.length > 0) {
          console.log(`   📊 Found ${remainingInventory.length} inventory records still:`)
          remainingInventory.forEach((record, index) => {
            console.log(`   ${index + 1}. Currency ID: ${record.currency_attribute_id}, Qty: ${record.quantity}, Reserved: ${record.reserved_quantity}`)
          })
          console.log('   Issue: Trigger is checking for ANY inventory records, not just non-zero stock')
        }
      } else {
        console.log('✅ SUCCESS: Account with zero stock was deleted!')
        console.log('   This is the expected behavior')
      }
    }

    // Step 4: Test account with no inventory records at all
    console.log('\n📋 Step 4: Testing account with no inventory records...')

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
    const noInventoryAccountName = `NO_INVENTORY_Test_${uniqueId}`

    // Create account but manually delete its inventory
    const { data: noInventoryAccount, error: createError } = await supabase
      .from('game_accounts')
      .insert({
        game_code: 'DIABLO_4',
        league_attribute_id: leagues[0].id,
        account_name: noInventoryAccountName,
        purpose: 'INVENTORY'
      })
      .select()
      .single()

    if (createError) {
      console.log('❌ Failed to create test account:', createError.message)
      return
    }

    console.log(`✅ Created account: ${noInventoryAccount.account_name}`)

    // Wait for trigger to create inventory
    await new Promise(resolve => setTimeout(resolve, 3000))

    // Delete the inventory manually
    const { error: inventoryDeleteError } = await supabase
      .from('currency_inventory')
      .delete()
      .eq('game_account_id', noInventoryAccount.id)

    if (inventoryDeleteError) {
      console.log('⚠️  Could not delete inventory manually:', inventoryDeleteError.message)
    } else {
      console.log('✅ Deleted inventory records manually')

      // Now try to delete the account
      console.log('\n📋 Step 5: Attempting to delete account with no inventory records...')

      const { error: noInventoryDeleteError } = await supabase
        .from('game_accounts')
        .delete()
        .eq('id', noInventoryAccount.id)

      if (noInventoryDeleteError) {
        console.log('❌ Account deletion was blocked!')
        console.log(`   Error: ${noInventoryDeleteError.message}`)
        console.log('   This means the trigger is too restrictive')
      } else {
        console.log('✅ SUCCESS: Account with no inventory records was deleted!')
      }
    }

    console.log('\n🎯 ANALYSIS:')
    console.log('   Expected behavior:')
    console.log('   ✅ Account with no inventory records: Should be deletable')
    console.log('   ✅ Account with zero stock (0,0): Should be deletable')
    console.log('   ❌ Account with non-zero stock: Should be blocked')
    console.log('')
    console.log('   Current trigger may be too strict if zero-stock accounts are blocked')

  } catch (error) {
    console.error('❌ Test failed:', error.message)
  }
}

testZeroStockDeletion()