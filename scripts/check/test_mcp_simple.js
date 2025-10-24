#!/usr/bin/env node

// Simple test script to verify Supabase connection
import { createClient } from '@supabase/supabase-js'

// Use current Supabase staging environment
const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI3Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU"

console.log('🔍 Testing Supabase MCP Connection...')
console.log('📋 Using service role key for admin access')

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
        const keyTables = ['profiles', 'game_accounts', 'currency_inventory']

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

        // Test 3: Check if work shifts tables exist (new migrations)
        console.log('\n⏰ Testing: Check work shift tables...')
        const workShiftTables = ['work_shifts', 'employee_shift_assignments', 'shift_allocation_counters']

        for (const tableName of workShiftTables) {
            const { data, error } = await supabase
                .from(tableName)
                .select('*')
                .limit(1)

            if (error) {
                console.log(`   ❌ ${tableName}: ${error.message}`)
            } else {
                console.log(`   ✅ ${tableName}: Exists and accessible`)
            }
        }

        console.log('\n🎉 Connection test completed!')
        console.log('\n📝 MCP is ready if:')
        console.log('   ✅ Tables are accessible')
        console.log('   ✅ Service role key works')
        console.log('   ✅ Basic queries succeed')

        console.log('\n🚀 To start MCP server:')
        console.log('   cd tools/supabase-mcp && npm start')

    } catch (error) {
        console.error('❌ Connection test failed:', error.message)
    }
}

testConnection()