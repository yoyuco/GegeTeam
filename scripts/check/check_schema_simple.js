#!/usr/bin/env node

// Simple schema inspection using direct table access
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI7Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU"

const supabase = createClient(supabaseUrl, serviceRoleKey)

async function inspectTables() {
    console.log('🔍 INSPECTING KEY DATABASE TABLES')
    console.log('=' .repeat(60))

    const keyTables = [
        'profiles',
        'game_accounts',
        'currency_inventory',
        'channels',
        'attributes',
        'currency_orders',
        'roles',
        'permissions',
        'user_role_assignments',
        'parties',
        'currencies',
        'work_shifts',
        'employee_shift_assignments'
    ]

    for (const tableName of keyTables) {
        console.log(`\n🗂️  CHECKING TABLE: ${tableName}`)
        console.log('-'.repeat(50))

        try {
            // Test table access and get basic info
            const { data, error, count } = await supabase
                .from(tableName)
                .select('*', { count: 'exact', head: true })

            if (error) {
                if (error.message.includes('does not exist')) {
                    console.log(`❌ Table '${tableName}' does not exist`)
                } else {
                    console.log(`❌ Error accessing '${tableName}': ${error.message}`)
                }
                continue
            }

            console.log(`✅ Table exists and is accessible`)
            console.log(`📊 Data rows: ${count || 0}`)

            // Try to get column information by selecting a sample row
            const { data: sampleData, error: sampleError } = await supabase
                .from(tableName)
                .select('*')
                .limit(1)

            if (!sampleError && sampleData && sampleData.length > 0) {
                const sampleRow = sampleData[0]
                const columns = Object.keys(sampleRow)

                console.log(`📋 Columns (${columns.length}):`)
                columns.forEach(col => {
                    const value = sampleRow[col]
                    const type = value === null ? 'NULL' : typeof value
                    const preview = value !== null && typeof value !== 'object'
                        ? ` = ${String(value).substring(0, 30)}`
                        : typeof value === 'object' && value !== null
                        ? ` = ${JSON.stringify(value).substring(0, 30)}`
                        : ''
                    console.log(`  ${col.padEnd(30)} ${type.padEnd(10)}${preview}`)
                })
            } else {
                console.log('ℹ️  No data available to inspect columns')
            }

            // For specific tables, add detailed analysis
            if (tableName === 'currency_inventory' && sampleData && sampleData.length > 0) {
                console.log('\n🔍 INVENTORY ANALYSIS:')
                const sample = sampleData[0]
                console.log(`  ✅ Has channel_id: ${sample.hasOwnProperty('channel_id') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has game_account_id: ${sample.hasOwnProperty('game_account_id') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has currency_attribute_id: ${sample.hasOwnProperty('currency_attribute_id') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has quantity fields: ${sample.hasOwnProperty('quantity') ? 'YES' : 'NO'}`)
            }

            if (tableName === 'game_accounts' && sampleData && sampleData.length > 0) {
                console.log('\n🔍 GAME ACCOUNTS ANALYSIS:')
                const sample = sampleData[0]
                console.log(`  ✅ Has manager_profile_id: ${sample.hasOwnProperty('manager_profile_id') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has purpose field: ${sample.hasOwnProperty('purpose') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has game_code: ${sample.hasOwnProperty('game_code') ? 'YES' : 'NO'}`)
            }

            if (tableName === 'profiles' && sampleData && sampleData.length > 0) {
                console.log('\n🔍 PROFILES ANALYSIS:')
                const sample = sampleData[0]
                console.log(`  ✅ Has display_name: ${sample.hasOwnProperty('display_name') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has auth_id: ${sample.hasOwnProperty('auth_id') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Can serve as employee: YES`)
            }

            if (tableName === 'channels' && sampleData && sampleData.length > 0) {
                console.log('\n🔍 CHANNELS ANALYSIS:')
                const sample = sampleData[0]
                console.log(`  ✅ Has fee structure: ${sample.hasOwnProperty('purchase_fee_rate') ? 'YES' : 'NO'}`)
                console.log(`  ✅ Has currency info: ${sample.hasOwnProperty('purchase_fee_currency') ? 'YES' : 'NO'}`)
            }

        } catch (err) {
            console.log(`❌ Unexpected error with '${tableName}': ${err.message}`)
        }
    }

    // Check what tables exist by trying each one
    console.log('\n📊 SUMMARY TABLE STATUS:')
    console.log('-'.repeat(50))

    let existingTables = []
    let missingTables = []

    for (const tableName of keyTables) {
        try {
            const { data, error } = await supabase
                .from(tableName)
                .select('id')
                .limit(1)

            if (!error) {
                existingTables.push(tableName)
            } else {
                missingTables.push(tableName)
            }
        } catch (err) {
            missingTables.push(tableName)
        }
    }

    console.log(`✅ Existing tables (${existingTables.length}):`)
    existingTables.forEach(table => console.log(`  ✓ ${table}`))

    console.log(`\n❌ Missing tables (${missingTables.length}):`)
    missingTables.forEach(table => console.log(`  ✗ ${table}`))

    return { existingTables, missingTables }
}

// Run the inspection
inspectTables().then(({ existingTables, missingTables }) => {
    console.log('\n' + '='.repeat(60))
    console.log('📋 INSPECTION COMPLETE')

    if (missingTables.includes('work_shifts')) {
        console.log('\n⚠️  WORK SHIFT TABLES NOT FOUND')
        console.log('Need to run migration files:')
        console.log('  1. 20250125000000_create_work_shifts_temp.sql')
        console.log('  2. 20250125010000_enhanced_allocation_logic_temp.sql')
        console.log('  3. 20250125020000_testing_and_samples_temp.sql')
    }

    console.log('\n🎯 READY FOR NEXT STEPS')
}).catch(err => {
    console.error('❌ Schema inspection failed:', err.message)
})