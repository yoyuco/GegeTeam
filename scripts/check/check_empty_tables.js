#!/usr/bin/env node

// Check empty tables to see their full structure
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI3Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU"

async function checkEmptyTables() {
    console.log('🔍 CHECKING EMPTY TABLE STRUCTURES')
    console.log('=' .repeat(60))

    const emptyTables = ['game_accounts', 'currency_inventory']

    for (const tableName of emptyTables) {
        console.log(`\n📋 Table: ${tableName}`)
        console.log('-'.repeat(40))

        try {
            // Try to get table structure using information_schema via direct HTTP
            const url = `${supabaseUrl}/rest/v1/rpc/get_table_structure?table_name=${tableName}`

            // If RPC doesn't work, try to create a sample record to see structure
            const sampleUrl = `${supabaseUrl}/rest/v1/${tableName}?select=*`

            // First, let's try to see if there are any columns by doing a count
            const countUrl = `${supabaseUrl}/rest/v1/${tableName}?select=count(*)`

            const response = await fetch(sampleUrl, {
                headers: {
                    'apikey': serviceRoleKey,
                    'Authorization': `Bearer ${serviceRoleKey}`,
                    'Accept': 'application/vnd.pgrst.object+json',
                    'Prefer': 'return=representation'
                }
            })

            if (response.status === 200) {
                const data = await response.json()

                if (data && typeof data === 'object') {
                    const columns = Object.keys(data)
                    console.log(`📋 Structure (${columns.length} columns):`)

                    columns.forEach(col => {
                        const value = data[col]
                        const type = value === null ? 'null' : typeof value
                        const nullable = value === null ? 'NULLABLE' : 'NOT NULL'
                        console.log(`  ${col.padEnd(25)} ${type.padEnd(10)} ${nullable}`)
                    })

                    // Special analysis for each table
                    if (tableName === 'game_accounts') {
                        console.log(`\n🔍 Game Accounts Analysis:`)
                        console.log(`  • Has manager_profile_id: ${data.hasOwnProperty('manager_profile_id') ? '✅' : '❌'}`)
                        console.log(`  • Has game_code: ${data.hasOwnProperty('game_code') ? '✅' : '❌'}`)
                        console.log(`  • Has league_attribute_id: ${data.hasOwnProperty('league_attribute_id') ? '✅' : '❌'}`)
                        console.log(`  • Has account_name: ${data.hasOwnProperty('account_name') ? '✅' : '❌'}`)
                        console.log(`  • Has purpose: ${data.hasOwnProperty('purpose') ? '✅' : '❌'}`)
                        console.log(`  • Has is_active: ${data.hasOwnProperty('is_active') ? '✅' : '❌'}`)
                    }

                    if (tableName === 'currency_inventory') {
                        console.log(`\n🔍 Currency Inventory Analysis:`)
                        console.log(`  • Has game_account_id: ${data.hasOwnProperty('game_account_id') ? '✅' : '❌'}`)
                        console.log(`  • Has currency_attribute_id: ${data.hasOwnProperty('currency_attribute_id') ? '✅' : '❌'}`)
                        console.log(`  • Has channel_id: ${data.hasOwnProperty('channel_id') ? '✅' : '❌'}`)
                        console.log(`  • Has quantity: ${data.hasOwnProperty('quantity') ? '✅' : '❌'}`)
                        console.log(`  • Has reserved_quantity: ${data.hasOwnProperty('reserved_quantity') ? '✅' : '❌'}`)
                        console.log(`  • Has avg_buy_price: ${data.hasOwnProperty('avg_buy_price') ? '✅' : '❌'}`)
                        console.log(`  • Has avg_buy_price_vnd: ${data.hasOwnProperty('avg_buy_price_vnd') ? '✅' : '❌'}`)
                        console.log(`  • Has avg_buy_price_usd: ${data.hasOwnProperty('avg_buy_price_usd') ? '✅' : '❌'}`)
                    }
                } else {
                    console.log('📋 Empty table - no structure visible')
                }
            } else {
                console.log(`❌ HTTP ${response.status}: Could not get structure`)
            }

        } catch (err) {
            console.log(`❌ Error: ${err.message}`)
        }
    }

    // Also check if currency_orders exists
    console.log(`\n📋 Checking: currency_orders`)
    console.log('-'.repeat(40))

    try {
        const response = await fetch(`${supabaseUrl}/rest/v1/currency_orders?select=*&limit=1`, {
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        })

        if (response.status === 200) {
            console.log('✅ currency_orders table exists')
        } else if (response.status === 404) {
            console.log('❌ currency_orders table does not exist')
        } else {
            console.log(`❌ HTTP ${response.status}`)
        }
    } catch (err) {
        console.log(`❌ Error checking currency_orders: ${err.message}`)
    }

    // Final summary
    console.log('\n' + '=' .repeat(60))
    console.log('📊 FINAL SCHEMA ANALYSIS')
    console.log('=' .repeat(60))

    console.log('\n✅ EXISTING PERFECT STRUCTURE:')
    console.log('1. profiles - Employee management (id, display_name, auth_id, status)')
    console.log('2. channels - Channel management with fees (id, name, fee_rate, fee_currency)')
    console.log('3. attributes - Currency/items definitions (id, code, name, type)')
    console.log('4. roles - Role definitions (id, code, name)')
    console.log('5. permissions - Permission definitions (id, code, description)')
    console.log('6. user_role_assignments - Role assignments (user_id, role_id, game/business scope)')

    console.log('\n❌ STRUCTURE TO VERIFY/ADD:')
    console.log('1. game_accounts - Need to check full structure')
    console.log('2. currency_inventory - Need to verify channel_id exists')
    console.log('3. currency_orders - Need to verify exists')

    console.log('\n🚀 WORK SHIFT TABLES NEEDED:')
    console.log('1. work_shifts (NEW)')
    console.log('2. employee_shift_assignments (NEW)')
    console.log('3. shift_allocation_counters (NEW)')
    console.log('4. order_allocations (NEW)')

    console.log('\n🔧 POTENTIAL MODIFICATIONS NEEDED:')
    console.log('1. game_accounts - Add owner_profile_id, possibly modify manager_profile_id')
    console.log('2. currency_inventory - Verify channel_id exists for multi-channel support')
}

checkEmptyTables()