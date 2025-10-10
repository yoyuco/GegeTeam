// Test cascade deletion for game_accounts -> currency_inventory
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

async function testCascadeDeletion() {
  console.log('🧪 Testing Cascade Deletion')
  console.log('============================')

  try {
    // Step 1: Get D4 league and create test account
    console.log('\n📋 Step 1: Creating test account for deletion test...')

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
    const testAccountName = `DELETE_Test_${uniqueId}`

    // Create account (trigger will auto-create inventory)
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
      console.log('❌ Account creation failed:', accountError.message)
      return
    }

    console.log(`✅ Account created: ${testAccount.account_name} (ID: ${testAccount.id})`)

    // Wait for trigger to create inventory
    await new Promise(resolve => setTimeout(resolve, 3000))

    // Step 2: Check inventory before deletion
    console.log('\n📋 Step 2: Checking inventory before deletion...')

    const { data: inventoryBefore, error: inventoryError } = await supabase
      .from('currency_inventory')
      .select(`
        id,
        quantity,
        reserved_quantity,
        attributes:currency_attribute_id (name, code)
      `)
      .eq('game_account_id', testAccount.id)

    if (inventoryError) {
      console.log('❌ Error checking inventory:', inventoryError.message)
      return
    }

    console.log(`📊 Found ${inventoryBefore.length} inventory records:`)
    inventoryBefore.forEach((record, index) => {
      const totalQty = record.quantity + record.reserved_quantity
      console.log(`   ${index + 1}. ${record.attributes.name} - Total: ${totalQty} (Qty: ${record.quantity}, Reserved: ${record.reserved_quantity})`)
    })

    // Check if any records have non-zero stock
    const hasStock = inventoryBefore.some(record =>
      (record.quantity + record.reserved_quantity) > 0
    )

    if (hasStock) {
      console.log('\n⚠️  WARNING: Account has non-zero stock!')
      console.log('   For safety test, we should only delete accounts with zero stock')

      // Don't delete if has stock - just show the concept
      console.log('\n📋 Step 3: Skipping deletion (safety for non-zero stock)')
      console.log('   In production, you might want to:')
      console.log('   - Block deletion of accounts with stock')
      console.log('   - Or transfer stock before deletion')

    } else {
      // Step 3: Delete the account
      console.log('\n📋 Step 3: Deleting account...')

      const { error: deleteError } = await supabase
        .from('game_accounts')
        .delete()
        .eq('id', testAccount.id)

      if (deleteError) {
        console.log('❌ Account deletion failed:', deleteError.message)
        console.log('   This might indicate foreign key constraints prevent cascade deletion')
        return
      }

      console.log('✅ Account deleted successfully')

      // Step 4: Check inventory after deletion
      console.log('\n📋 Step 4: Checking inventory after deletion...')

      const { data: inventoryAfter, error: afterError } = await supabase
        .from('currency_inventory')
        .select('*')
        .eq('game_account_id', testAccount.id)

      if (afterError) {
        console.log('❌ Error checking inventory after deletion:', afterError.message)
      } else {
        if (inventoryAfter.length === 0) {
          console.log('✅ SUCCESS: All inventory records were automatically deleted!')
          console.log('   This confirms CASCADE DELETE is working')
        } else {
          console.log(`⚠️  WARNING: Found ${inventoryAfter.length} orphaned inventory records:`)
          inventoryAfter.forEach((record, index) => {
            console.log(`   ${index + 1}. ID: ${record.id} - Currency ID: ${record.currency_attribute_id}`)
          })
          console.log('   This indicates CASCADE DELETE is NOT working')
          console.log('   Orphaned records need manual cleanup')
        }
      }
    }

    // Step 5: Check foreign key constraints
    console.log('\n📋 Step 5: Checking foreign key constraints...')

    // Note: We can't directly query constraint info via Supabase client
    // But we can check the behavior
    console.log('📊 Cascade Deletion Test Results:')
    console.log('   - Account with zero stock: Should be deletable')
    console.log('   - Inventory records: Should be auto-deleted via CASCADE')
    console.log('   - Account with non-zero stock: Should be blocked for safety')

  } catch (error) {
    console.error('❌ Test failed:', error.message)
  }
}

testCascadeDeletion()