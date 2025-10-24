#!/usr/bin/env node

// Direct table checking using HTTP API
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI3Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU"

async function checkTablesDirect() {
    console.log('🔍 DIRECT TABLE CHECKING')
    console.log('=' .repeat(50))

    const tablesToCheck = [
        'profiles',
        'game_accounts',
        'currency_inventory',
        'channels',
        'attributes',
        'roles',
        'permissions',
        'user_role_assignments',
        'work_shifts',
        'employee_shift_assignments'
    ]

    for (const tableName of tablesToCheck) {
        console.log(`\n📋 Checking: ${tableName}`)

        try {
            // Use fetch directly to avoid client caching issues
            const url = `${supabaseUrl}/rest/v1/${tableName}?select=*&limit=1`
            const response = await fetch(url, {
                headers: {
                    'apikey': serviceRoleKey,
                    'Authorization': `Bearer ${serviceRoleKey}`,
                    'Content-Type': 'application/json'
                }
            })

            if (response.ok) {
                const data = await response.json()
                const contentRange = response.headers.get('content-range')
                const totalCount = contentRange ? contentRange.split('/')[1] : 'unknown'

                console.log(`  ✅ Table exists and accessible`)
                console.log(`  📊 Total rows: ${totalCount}`)

                if (Array.isArray(data) && data.length > 0) {
                    const sampleRow = data[0]
                    const columns = Object.keys(sampleRow)

                    console.log(`  📋 Columns (${columns.length}):`)
                    columns.slice(0, 10).forEach(col => {
                        const value = sampleRow[col]
                        const type = value === null ? 'null' : typeof value
                        const preview = value !== null && typeof value !== 'object' && String(value).length < 30
                            ? ` = ${value}`
                            : typeof value === 'object' && value !== null
                            ? ` = ${JSON.stringify(value).substring(0, 30)}`
                            : ''
                        console.log(`    ${col.padEnd(25)} ${type.padEnd(10)}${preview}`)
                    })

                    if (columns.length > 10) {
                        console.log(`    ... and ${columns.length - 10} more columns`)
                    }

                    // Special analysis for key tables
                    if (tableName === 'currency_inventory') {
                        console.log(`  🔍 Inventory analysis:`)
                        console.log(`    • Has channel_id: ${sampleRow.hasOwnProperty('channel_id') ? '✅' : '❌'}`)
                        console.log(`    • Has game_account_id: ${sampleRow.hasOwnProperty('game_account_id') ? '✅' : '❌'}`)
                        console.log(`    • Has currency_attribute_id: ${sampleRow.hasOwnProperty('currency_attribute_id') ? '✅' : '❌'}`)
                        console.log(`    • Has quantity: ${sampleRow.hasOwnProperty('quantity') ? '✅' : '❌'}`)
                        console.log(`    • Has avg_buy_price: ${sampleRow.hasOwnProperty('avg_buy_price') ? '✅' : '❌'}`)
                    }

                    if (tableName === 'game_accounts') {
                        console.log(`  🔍 Account analysis:`)
                        console.log(`    • Has manager_profile_id: ${sampleRow.hasOwnProperty('manager_profile_id') ? '✅' : '❌'}`)
                        console.log(`    • Has purpose: ${sampleRow.hasOwnProperty('purpose') ? '✅' : '❌'}`)
                        console.log(`    • Has game_code: ${sampleRow.hasOwnProperty('game_code') ? '✅' : '❌'}`)
                        console.log(`    • Has account_name: ${sampleRow.hasOwnProperty('account_name') ? '✅' : '❌'}`)
                    }

                    if (tableName === 'profiles') {
                        console.log(`  🔍 Profile analysis:`)
                        console.log(`    • Has display_name: ${sampleRow.hasOwnProperty('display_name') ? '✅' : '❌'}`)
                        console.log(`    • Has auth_id: ${sampleRow.hasOwnProperty('auth_id') ? '✅' : '❌'}`)
                        console.log(`    • Has status: ${sampleRow.hasOwnProperty('status') ? '✅' : '❌'}`)
                    }

                    if (tableName === 'channels') {
                        console.log(`  🔍 Channel analysis:`)
                        console.log(`    • Has purchase_fee_rate: ${sampleRow.hasOwnProperty('purchase_fee_rate') ? '✅' : '❌'}`)
                        console.log(`    • Has sale_fee_rate: ${sampleRow.hasOwnProperty('sale_fee_rate') ? '✅' : '❌'}`)
                        console.log(`    • Has fee_currency: ${sampleRow.hasOwnProperty('purchase_fee_currency') ? '✅' : '❌'}`)
                    }
                } else {
                    console.log(`  📋 Table exists but no data to inspect columns`)
                }
            } else if (response.status === 406) {
                console.log(`  ❌ Table '${tableName}' does not exist`)
            } else {
                const errorText = await response.text()
                console.log(`  ❌ HTTP ${response.status}: ${errorText}`)
            }
        } catch (err) {
            console.log(`  ❌ Network error: ${err.message}`)
        }
    }

    // Summary
    console.log('\n' + '=' .repeat(50))
    console.log('📊 SUMMARY & RECOMMENDATIONS')
    console.log('=' .repeat(50))

    console.log('\n🎯 WHAT WE KNOW:')
    console.log('• HTTP API works with service_role_key')
    console.log('• Can directly query tables via REST API')
    console.log('• Need to check each table individually')

    console.log('\n🔧 NEEDED FOR WORK SHIFT SYSTEM:')
    console.log('\n📋 TABLES TO CREATE:')
    console.log('1. work_shifts - shift definitions')
    console.log('   - id, name, start_time, end_time, is_active')

    console.log('2. employee_shift_assignments - assign employees to shifts')
    console.log('   - employee_profile_id, shift_id, assigned_date, is_active')

    console.log('3. shift_allocation_counters - round-robin tracking')
    console.log('   - shift_id, channel_id, employee_profile_id, allocation_count')

    console.log('4. order_allocations - track order assignments')
    console.log('   - currency_order_id, shift_id, employee_profile_id, game_account_id')

    console.log('\n📋 COLUMNS TO ADD (if needed):')
    console.log('• game_accounts.owner_profile_id - primary account owner')
    console.log('• Remove game_accounts.manager_profile_id - replace with flexible assignments')

    console.log('\n📋 FUNCTIONS TO CREATE:')
    console.log('• get_current_shift() - return current active shift')
    console.log('• is_employee_in_current_shift() - check employee status')
    console.log('• allocate_sell_order_round_robin() - main allocation logic')

    console.log('\n🚀 NEXT STEPS:')
    console.log('1. Run the 3 migration files we created')
    console.log('2. Test basic work shift functionality')
    console.log('3. Integrate with existing permission system')
    console.log('4. Update frontend components')
}

checkTablesDirect()