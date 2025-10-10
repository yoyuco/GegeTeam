// Backfill inventory records for existing accounts
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

async function backfillInventory() {
  console.log('🔧 Backfilling Inventory for Existing Accounts')
  console.log('==============================================')

  try {
    // Step 1: Get all INVENTORY accounts without inventory records
    console.log('\n📋 Step 1: Finding accounts needing inventory...')

    // First get all accounts with inventory
    const { data: accountsWithInventory } = await supabase
      .from('currency_inventory')
      .select('game_account_id')

    const accountIdsWithInventory = accountsWithInventory?.map(record => record.game_account_id) || []

    // Then get accounts without inventory
    const { data: accountsWithoutInventory, error: accountsError } = await supabase
      .from('game_accounts')
      .select(`
        id,
        game_code,
        account_name,
        purpose
      `)
      .eq('purpose', 'INVENTORY')

    // Filter out accounts that already have inventory
    const filteredAccounts = accountsWithoutInventory?.filter(
      account => !accountIdsWithInventory.includes(account.id)
    ) || []

    if (accountsError) {
      console.log('❌ Error finding accounts:', accountsError.message)
      return
    }

    if (!filteredAccounts || filteredAccounts.length === 0) {
      console.log('✅ All accounts already have inventory records')
      return
    }

    console.log(`Found ${filteredAccounts.length} accounts needing inventory:`)
    filteredAccounts.forEach((account, index) => {
      console.log(`${index + 1}. ${account.account_name} (${account.game_code})`)
    })

    // Step 2: Process each account
    console.log('\n📋 Step 2: Processing each account...')

    for (const account of filteredAccounts) {
      console.log(`\n🔧 Processing: ${account.account_name} (${account.game_code})`)

      // Determine currency type based on game code
      const currencyType = account.game_code === 'POE_1' ? 'CURRENCY_POE1' :
                          account.game_code === 'POE_2' ? 'CURRENCY_POE2' :
                          account.game_code === 'DIABLO_4' ? 'CURRENCY_D4' : null

      if (!currencyType) {
        console.log(`⚠️  Skipping ${account.game_code} - not supported`)
        continue
      }

      // Get active currencies for this game
      const { data: currencies, error: currencyError } = await supabase
        .from('attributes')
        .select('id, name, code')
        .eq('type', currencyType)
        .eq('is_active', true)

      if (currencyError) {
        console.log(`❌ Error getting currencies for ${currencyType}:`, currencyError.message)
        continue
      }

      if (!currencies || currencies.length === 0) {
        console.log(`⚠️  No active currencies found for ${currencyType}`)
        continue
      }

      console.log(`   Found ${currencies.length} ${currencyType} items`)

      // Create inventory records for each currency
      let successCount = 0
      for (const currency of currencies) {
        const { error: insertError } = await supabase
          .from('currency_inventory')
          .insert({
            game_account_id: account.id,
            currency_attribute_id: currency.id,
            quantity: 0,
            reserved_quantity: 0,
            avg_buy_price_vnd: 0,
            avg_buy_price_usd: 0,
            last_updated_at: new Date().toISOString()
          })

        if (insertError) {
          console.log(`   ❌ Failed to create inventory for ${currency.name}: ${insertError.message}`)
        } else {
          successCount++
        }
      }

      console.log(`   ✅ Created ${successCount}/${currencies.length} inventory records`)
    }

    // Step 3: Verify results
    console.log('\n📋 Step 3: Verifying results...')

    const { count: finalCount } = await supabase
      .from('currency_inventory')
      .select('*', { count: 'exact', head: true })

    // Get remaining accounts without inventory
    const { data: remainingAccountsRaw } = await supabase
      .from('game_accounts')
      .select('id, account_name, game_code')
      .eq('purpose', 'INVENTORY')

    const remainingAccounts = remainingAccountsRaw?.filter(
      account => !accountIdsWithInventory.includes(account.id)
    ) || []

    console.log(`\n📊 Final Results:`)
    console.log(`   Total inventory records: ${finalCount || 0}`)
    console.log(`   Accounts still needing inventory: ${remainingAccounts?.length || 0}`)

    if (remainingAccounts && remainingAccounts.length > 0) {
      console.log(`\n⚠️  Still missing inventory for:`)
      remainingAccounts.forEach(account => {
        console.log(`   - ${account.account_name} (${account.game_code})`)
      })
    } else {
      console.log(`\n✅ SUCCESS: All INVENTORY accounts now have inventory records!`)
    }

  } catch (error) {
    console.error('❌ Backfill failed:', error.message)
  }
}

backfillInventory()