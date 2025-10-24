#!/usr/bin/env node

// Check schema with different authentication approach
import { createClient } from '@supabase/supabase-js'

// Try with anonymous key first
const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNzM3NzIsImV4cCI6MjA3NTg0OTc3Mn0.HHMZHjT3OHHfcqeAbagirwYFPlmRNjScDFMY7mpdPRw"

const supabase = createClient(supabaseUrl, anonKey, {
    db: { schema: 'public' }
})

async function quickCheck() {
    console.log('🔍 QUICK SCHEMA CHECK')
    console.log('=' .repeat(50))

    // Test basic connection with different approach
    console.log('\n1. Testing basic connection...')

    try {
        // Try a simple RPC call to test connection
        const { data, error } = await supabase.rpc('version')

        if (error) {
            console.log(`RPC version test: ${error.message}`)
        } else {
            console.log(`✅ RPC connection works: ${data}`)
        }
    } catch (err) {
        console.log(`RPC test failed: ${err.message}`)
    }

    // Try to list system tables
    console.log('\n2. Testing table access...')

    const systemTables = [
        'information_schema.tables',
        'information_schema.columns',
        'pg_tables',
        'pg_class'
    ]

    for (const table of systemTables) {
        try {
            const { data, error } = await supabase
                .from(table)
                .select('*')
                .limit(1)

            if (error) {
                console.log(`  ❌ ${table}: ${error.message}`)
            } else {
                console.log(`  ✅ ${table}: Accessible`)
            }
        } catch (err) {
            console.log(`  ❌ ${table}: ${err.message}`)
        }
    }

    // Try direct approach with SQL through http
    console.log('\n3. Testing HTTP approach...')

    try {
        const response = await fetch(`${supabaseUrl}/rest/v1/`, {
            headers: {
                'apikey': anonKey,
                'Authorization': `Bearer ${anonKey}`
            }
        })

        if (response.ok) {
            console.log('✅ HTTP API works')
        } else {
            console.log(`❌ HTTP API: ${response.status}`)
        }
    } catch (err) {
        console.log(`❌ HTTP test: ${err.message}`)
    }

    // Test with our migration files
    console.log('\n4. Checking if we can create tables...')

    const testTables = [
        'work_shifts',
        'employee_shift_assignments',
        'shift_allocation_counters'
    ]

    for (const tableName of testTables) {
        try {
            const { data, error } = await supabase
                .from(tableName)
                .select('*')
                .limit(1)

            if (error) {
                if (error.message.includes('does not exist')) {
                    console.log(`  ✗ ${tableName}: Not exists (need migration)`)
                } else {
                    console.log(`  ❌ ${tableName}: ${error.message}`)
                }
            } else {
                console.log(`  ✅ ${tableName}: Exists and accessible`)
            }
        } catch (err) {
            console.log(`  ❌ ${tableName}: ${err.message}`)
        }
    }

    console.log('\n🎯 RECOMMENDATIONS:')
    console.log('-' .repeat(30))
    console.log('1. Check RLS policies on tables')
    console.log('2. Verify service_role_key permissions')
    console.log('3. Consider running migrations first')
    console.log('4. Test with Supabase Dashboard directly')
}

quickCheck()