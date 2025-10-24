#!/usr/bin/env node

// Schema inspection script to check current database structure
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI3Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU"

const supabase = createClient(supabaseUrl, serviceRoleKey)

async function inspectSchema() {
    console.log('🔍 INSPECTING CURRENT DATABASE SCHEMA')
    console.log('=' .repeat(60))

    try {
        // Get all tables
        console.log('\n📋 ALL TABLES IN DATABASE:')
        const { data: tables, error: tablesError } = await supabase
            .from('pg_tables')
            .select('tablename, schemaname')
            .eq('schemaname', 'public')
            .order('tablename')

        if (tablesError) {
            console.error('❌ Error getting tables:', tablesError.message)
            return
        }

        if (tables && tables.length > 0) {
            console.log(`Found ${tables.length} tables:`)
            tables.forEach(table => {
                console.log(`  ✓ ${table.tablename}`)
            })
        } else {
            console.log('No tables found')
        }

        // Check key tables in detail
        const keyTables = [
            'profiles',
            'game_accounts',
            'currency_inventory',
            'channels',
            'attributes',
            'currency_orders',
            'roles',
            'permissions',
            'user_role_assignments'
        ]

        for (const tableName of keyTables) {
            console.log(`\n🗂️  TABLE: ${tableName.toUpperCase()}`)
            console.log('-'.repeat(40))

            // Check if table exists
            const tableExists = tables?.some(t => t.tablename === tableName)

            if (!tableExists) {
                console.log(`❌ Table '${tableName}' does not exist`)
                continue
            }

            // Get table columns
            const { data: columns, error: columnsError } = await supabase
                .from('information_schema.columns')
                .select('column_name, data_type, is_nullable, column_default')
                .eq('table_name', tableName)
                .eq('table_schema', 'public')
                .order('ordinal_position')

            if (columnsError) {
                console.error(`❌ Error getting columns for ${tableName}:`, columnsError.message)
                continue
            }

            if (columns && columns.length > 0) {
                console.log(`Columns (${columns.length}):`)
                columns.forEach(col => {
                    const nullable = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'
                    const defaultValue = col.column_default ? ` DEFAULT ${col.column_default}` : ''
                    console.log(`  ${col.column_name.padEnd(25)} ${col.data_type.padEnd(15)} ${nullable}${defaultValue}`)
                })

                // Get sample data count
                const { count, error: countError } = await supabase
                    .from(tableName)
                    .select('*', { count: 'exact', head: true })

                if (!countError) {
                    console.log(`  📊 Data rows: ${count || 0}`)
                }
            } else {
                console.log('No columns found')
            }
        }

        // Check foreign key relationships
        console.log('\n🔗 FOREIGN KEY RELATIONSHIPS:')
        console.log('-'.repeat(40))

        const { data: constraints, error: constraintsError } = await supabase
            .from('information_schema.table_constraints')
            .select(`
                constraint_name,
                table_name,
                constraint_type
            `)
            .eq('constraint_type', 'FOREIGN KEY')
            .eq('table_schema', 'public')

        if (!constraintsError && constraints && constraints.length > 0) {
            console.log(`Found ${constraints.length} foreign key constraints:`)
            for (const constraint of constraints.slice(0, 10)) { // Limit output
                console.log(`  ${constraint.table_name}.${constraint.constraint_name}`)
            }
            if (constraints.length > 10) {
                console.log(`  ... and ${constraints.length - 10} more`)
            }
        } else {
            console.log('No foreign key constraints found or error occurred')
        }

        // Check existing functions
        console.log('\n⚡ EXISTING FUNCTIONS:')
        console.log('-'.repeat(40))

        const { data: functions, error: functionsError } = await supabase
            .from('pg_proc')
            .select('proname, proargnames')
            .eq('pronamespace', 'pg_catalog')  // Check system functions
            .ilike('proname', '%shift%')
            .limit(10)

        if (!functionsError && functions && functions.length > 0) {
            console.log(`Found ${functions.length} functions with 'shift' in name:`)
            functions.forEach(func => {
                console.log(`  ✓ ${func.proname}(${func.proargnames?.join(', ') || ''})`)
            })
        } else {
            console.log('No shift-related functions found')
        }

    } catch (error) {
        console.error('❌ Schema inspection failed:', error.message)
    }
}

inspectSchema()