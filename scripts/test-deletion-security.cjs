// Test account deletion security with stock
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

async function testDeletionSecurity() {
  console.log('🧪 Testing Account Deletion Security')
  console.log('=====================================')

  try {
    // Step 1: Get the existing test account
    console.log('\n📋 Step 1: Finding existing test account...')

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
      console.log(`   Inventory: ${inventory.attributes.name} - Qty: ${inventory.quantity}, Reserved: ${inventory.reserved_quantity}, Total: ${totalStock}`)
    }

    // Step 2: Set positive stock
    console.log('\n📋 Step 2: Setting positive stock to test deletion protection...')

    if (testAccount.currency_inventory && testAccount.currency_inventory.length > 0) {
      const inventoryRecord = testAccount.currency_inventory[0]

      const { data: updatedInventory, error: updateError } = await supabase
        .from('currency_inventory')
        .update({
          quantity: 15,
          reserved_quantity: 5,
          last_updated_at: new Date().toISOString()
        })
        .eq('id', inventoryRecord.id)
        .select()
        .single()

      if (updateError) {
        console.log('❌ Failed to set positive stock:', updateError.message)
      } else {
        const newTotalStock = updatedInventory.quantity + updatedInventory.reserved_quantity
        console.log(`✅ Set positive stock: Qty=${updatedInventory.quantity}, Reserved=${updatedInventory.reserved_quantity}, Total=${newTotalStock}`)

        // Step 3: Try to delete account with stock
        console.log('\n📋 Step 3: Attempting to delete account with positive stock...')

        const { error: deleteError } = await supabase
          .from('game_accounts')
          .delete()
          .eq('id', testAccount.id)

        if (deleteError) {
          console.log('✅ SUCCESS: Account deletion was BLOCKED!')
          console.log(`   Error message: ${deleteError.message}`)
          console.log('   This is SAFE - system prevents deletion of accounts with stock')
        } else {
          console.log('❌ DANGER: Account with stock was DELETED!')
          console.log('   This is UNSAFE - need to add protection trigger!')
          console.log('   Stock value was lost!')
        }
      }
    }

    // Step 4: Create new account and test with negative stock
    console.log('\n📋 Step 4: Testing with negative stock...')

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
    const negativeTestName = `NEGATIVE_DeleteTest_${uniqueId}`

    // Create account
    const { data: negativeAccount, error: createError } = await supabase
      .from('game_accounts')
      .insert({
        game_code: 'DIABLO_4',
        league_attribute_id: leagues[0].id,
        account_name: negativeTestName,
        purpose: 'INVENTORY'
      })
      .select()
      .single()

    if (createError) {
      console.log('❌ Failed to create negative test account:', createError.message)
      return
    }

    console.log(`✅ Created negative test account: ${negativeAccount.account_name}`)

    // Wait for trigger
    await new Promise(resolve => setTimeout(resolve, 3000))

    // Get inventory and set negative stock
    const { data: negativeInventory } = await supabase
      .from('currency_inventory')
      .select('id')
      .eq('game_account_id', negativeAccount.id)
      .limit(1)

    if (negativeInventory && negativeInventory.length > 0) {
      await supabase
        .from('currency_inventory')
        .update({
          quantity: -25,
          last_updated_at: new Date().toISOString()
        })
        .eq('id', negativeInventory[0].id)

      console.log('✅ Set negative stock: -25')

      // Try to delete account with negative stock
      console.log('\n📋 Step 5: Attempting to delete account with negative stock...')

      const { error: negativeDeleteError } = await supabase
        .from('game_accounts')
        .delete()
        .eq('id', negativeAccount.id)

      if (negativeDeleteError) {
        console.log('✅ SUCCESS: Account with negative stock deletion was BLOCKED!')
        console.log(`   Error: ${negativeDeleteError.message}`)
      } else {
        console.log('❌ DANGER: Account with negative stock was DELETED!')
        console.log('   This means even negative stock accounts can be deleted - RISKY!')
      }
    }

    console.log('\n🎯 SECURITY ASSESSMENT:')
    console.log('   ✅ Safe: Account deletions are blocked when stock ≠ 0')
    console.log('   ❌ Unsafe: Account deletions succeed regardless of stock value')
    console.log('   📋 Recommendation: Add trigger to prevent deletion of accounts with non-zero total stock')

  } catch (error) {
    console.error('❌ Test failed:', error.message)
  }
}

testDeletionSecurity()