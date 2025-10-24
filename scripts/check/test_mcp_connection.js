#!/usr/bin/env node

// Test script to verify Supabase MCP connection
import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

console.log('🔍 Testing Supabase MCP Connection...')
console.log('📋 Environment Check:')
console.log(`   SUPABASE_URL: ${supabaseUrl ? '✅' : '❌'}`)
console.log(`   SUPABASE_SERVICE_ROLE_KEY: ${serviceRoleKey ? '✅' : '❌'}`)

if (!supabaseUrl || !serviceRoleKey) {
    console.error('❌ Missing required environment variables')
    process.exit(1)
}

// Create Supabase client with service role key
const supabase = createClient(supabaseUrl, serviceRoleKey)

async function testConnection() {
    try {
        console.log('\n🚀 Testing basic connection...')

        // Test 1: List tables
        console.log('📋 Testing: List tables...')
        const { data: tables, error: tablesError } = await supabase
            .from('information_schema.tables')
            .select('table_name')
            .eq('table_schema', 'public')
            .limit(10)

        if (tablesError) {
            console.error('❌ Tables query failed:', tablesError.message)
        } else {
            console.log('✅ Tables query successful')
            console.log(`   Found ${tables?.length || 0} tables`)
            if (tables && tables.length > 0) {
                console.log('   Sample tables:', tables.slice(0, 3).map(t => t.table_name).join(', '))
            }
        }

        // Test 2: Check key tables
        console.log('\n🗂️ Testing: Check key tables exist...')
        const keyTables = ['profiles', 'game_accounts', 'currency_inventory', 'work_shifts']

        for (const tableName of keyTables) {
            const { data, error } = await supabase
                .from(tableName)
                .select('*')
                .limit(1)

            if (error) {
                console.log(`   ❌ ${tableName}: ${error.message}`)
            } else {
                console.log(`   ✅ ${tableName}: Accessible`)
            }
        }

        // Test 3: Check work shifts data
        console.log('\n⏰ Testing: Check work shifts data...')
        const { data: shifts, error: shiftsError } = await supabase
            .from('work_shifts')
            .select('*')

        if (shiftsError) {
            console.log(`   ❌ Work shifts: ${shiftsError.message}`)
        } else {
            console.log(`   ✅ Work shifts: ${shifts?.length || 0} shifts found`)
            if (shifts && shifts.length > 0) {
                shifts.forEach(shift => {
                    console.log(`      - ${shift.name} (${shift.start_time} - ${shift.end_time})`)
                })
            }
        }

        // Test 4: Check current shift
        console.log('\n🎯 Testing: Check current shift function...')
        try {
            const { data: currentShift, error: shiftError } = await supabase
                .rpc('get_current_shift')

            if (shiftError) {
                console.log(`   ❌ get_current_shift: ${shiftError.message}`)
            } else {
                console.log(`   ✅ Current shift: ${currentShift || 'No active shift'}`)
            }
        } catch (err) {
            console.log(`   ❌ get_current_shift: Function not available or error: ${err.message}`)
        }

        console.log('\n🎉 Connection test completed!')
        console.log('\n📝 Next steps:')
        console.log('   1. Start MCP server: cd tools/supabase-mcp && npm start')
        console.log('   2. Test MCP tools via Claude Code')
        console.log('   3. Run migrations if needed')

    } catch (error) {
        console.error('❌ Connection test failed:', error.message)
    }
}

testConnection()