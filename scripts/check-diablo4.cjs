// Check if DIABLO_4 can be added to game_code enum and if trigger needs to handle it
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

async function checkDiablo4Support() {
  console.log('🔍 Checking DIABLO_4 Support')
  console.log('==========================')

  try {
    // Step 1: Try to create a DIABLO_4 account to see if it works
    console.log('\n📋 Step 1: Testing DIABLO_4 account creation...')

    const { data: leagues } = await supabase
      .from('attributes')
      .select('id, name')
      .eq('type', 'SEASON_D4')
      .eq('is_active', true)
      .limit(1)

    if (!leagues || leagues.length === 0) {
      console.log('⚠️  No D4 leagues found - will create without league')
    } else {
      console.log(`✅ Found D4 league: ${leagues[0].name}`)
    }

    const testAccountName = `DIABLO4_Test_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`

    const { data: newAccount, error: insertError } = await supabase
      .from('game_accounts')
      .insert({
        game_code: leagues[0] ? 'DIABLO_4' : 'POE_2', // Try DIABLO_4 first, fallback to POE_2
        league_attribute_id: leagues[0]?.id || null,
        account_name: testAccountName,
        purpose: 'INVENTORY'
      })
      .select()
      .single()

    if (insertError) {
      console.log('❌ DIABLO_4 account creation failed:', insertError.message)
      console.log('   Error details:', JSON.stringify(insertError, null, 2))

      // Try with POE_2 to see if it's an enum issue
      console.log('\n📋 Step 2: Trying POE_2 account as fallback...')

      const { data: poe2Account, error: poe2Error } = await supabase
        .from('game_accounts')
        .insert({
          game_code: 'POE_2',
          league_attribute_id: (leagues[0]?.id || null),
          account_name: testAccountName + '_POE2',
          purpose: 'INVENTORY'
        })
        .select()
        .single()

      if (poe2Error) {
        console.log('❌ Even POE_2 account creation failed:', poe2Error.message)
        return
      }

      console.log('✅ POE_2 fallback account created:', poe2Account.account_name)
      console.log('   This confirms enum is limited to POE_2')

      // Check trigger behavior
      await new Promise(resolve => setTimeout(resolve, 2000))

      const { data: inventory } = await supabase
        .from('currency_inventory')
        .select(`
          *,
          attributes:currency_attribute_id (name, code, type)
        `)
        .eq('game_account_id', poe2Account.id)

      console.log(`📊 Inventory records for POE_2 account: ${inventory.length}`)

      if (inventory.length > 0) {
        console.log('✅ Trigger works for POE_2 - so the issue is enum limitation')
      } else {
        console.log('❌ Trigger does not work even for POE_2 - deeper issue')
      }

      // Cleanup POE2 test
      await supabase
        .from('currency_inventory')
        .delete()
        .eq('game_account_id', poe2Account.id)

      await supabase
        .from('game_accounts')
        .delete()
        .eq('id', poe2Account.id)

    } else {
      console.log('✅ DIABLO_4 account created successfully!')
      console.log(`   Account ID: ${newAccount.id}`)
      console.log(`   Game Code: ${newAccount.game_code}`)

      // Wait for trigger to execute
      await new Promise(resolve => setTimeout(resolve, 3000))

      // Check inventory records
      const { data: inventory } = await supabase
        .from('currency_inventory')
        .select(`
          *,
          attributes:currency_attribute_id (name, code, type)
        `)
        .eq('game_account_id', newAccount.id)

      console.log(`📊 Inventory records for DIABLO_4 account: ${inventory.length}`)

      if (inventory.length > 0) {
        console.log('✅ Trigger created inventory records for DIABLO_4!')
        console.log('   This means trigger can handle DIABLO_4 when enum allows it')

        // Show currency types
        const diablo4Count = inventory.filter(r => r.attributes.type === 'CURRENCY_D4').length
        const poe2Count = inventory.filter(r => r.attributes.type === 'CURRENCY_POE2').length
        const poe1Count = inventory.filter(r => r.attributes.type === 'CURRENCY_POE1').length

        console.log(`📈 Inventory breakdown:`)
        console.log(`   CURRENCY_D4: ${diablo4Count}`)
        console.log(`   CURRENCY_POE2: ${poe2Count}`)
        console.log(`   CURRENCY_POE1: ${poe1Count}`)

        // Cleanup DIABLO_4 test
        await supabase
          .from('currency_inventory')
          .delete()
          .eq('game_account_id', newAccount.id)

        await supabase
          .from('game_accounts')
          .delete()
          .eq('id', newAccount.id)

        console.log('🧹 DIABLO_4 test cleanup completed')
      } else {
        console.log('❌ No inventory records created for DIABLO_4 account')
        console.log('   This means trigger logic does not include DIABLO_4 handling')
        console.log('   Or enum constraint prevents DIABLO_4 account creation')
      }
    }

    // Step 2: Check if we can extend the enum
    console.log('\n📋 Step 2: Checking CURRENCY_D4 items in database...')

    const { data: d4Items, error: d4Error } = await supabase
      .from('attributes')
      .select('name, code, type, is_active')
      .eq('type', 'CURRENCY_D4')
      .limit(10)

    if (d4Error) {
      console.log('❌ Error checking CURRENCY_D4 items:', d4Error.message)
    } else {
      console.log(`✅ Found ${d4Items.length} CURRENCY_D4 items available:`)
      d4Items.forEach((item, index) => {
        console.log(`   ${index + 1}. ${item.name} (${item.code}) - Active: ${item.is_active}`)
      })
    }

    console.log('\n📋 CONCLUSION:')
    console.log('   If DIABLO_4 account creation succeeded: Need to update trigger logic')
    console.log('   If DIABLO_4 account failed but POE_2 worked: Need to fix enum constraint')
    console.log('   If both failed: Need deeper investigation of database constraints')

  } catch (error) {
    console.error('❌ Check failed:', error.message)
  }
}

checkDiablo4Support()