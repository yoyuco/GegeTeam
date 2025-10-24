#!/usr/bin/env node

// Check channels table structure to see if purchase channels script is compatible
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = "https://nxlrnwijsxqalcxyavkj.supabase.co"
const serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI3Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU"

const supabase = createClient(supabaseUrl, serviceRoleKey)

async function checkChannelsStructure() {
    console.log('🔍 CHECKING CHANNELS TABLE STRUCTURE')
    console.log('=' .repeat(50))

    try {
        // Get a sample channel to see structure
        const response = await fetch(`${supabaseUrl}/rest/v1/channels?select=*&limit=1`, {
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`,
                'Accept': 'application/vnd.pgrst.object+json'
            }
        })

        if (response.ok) {
            const channelData = await response.json()

            if (channelData && typeof channelData === 'object') {
                const columns = Object.keys(channelData)

                console.log('📋 Channels Table Structure:')
                console.log(`Columns (${columns.length}):`)
                columns.forEach(col => {
                    const value = channelData[col]
                    const type = value === null ? 'null' : typeof value
                    const nullable = value === null ? 'NULLABLE' : 'NOT NULL'
                    console.log(`  ${col.padEnd(25)} ${type.padEnd(10)} ${nullable}`)
                })

                // Check for specific columns
                console.log('\n🔍 Specific Column Check:')
                console.log(`• Has channel_type: ${channelData.hasOwnProperty('channel_type') ? '✅' : '❌'}`)
                console.log(`• Has direction: ${channelData.hasOwnProperty('direction') ? '✅' : '❌'}`)
                console.log(`• Has fee structure: ${channelData.hasOwnProperty('purchase_fee_rate') ? '✅' : '❌'}`)
                console.log(`• Has is_active: ${channelData.hasOwnProperty('is_active') ? '✅' : '❌'}`)

                // Get all channels to see current data
                const allChannelsResponse = await fetch(`${supabaseUrl}/rest/v1/channels?select=code,name,is_active&limit=10`, {
                    headers: {
                        'apikey': serviceRoleKey,
                        'Authorization': `Bearer ${serviceRoleKey}`
                    }
                })

                if (allChannelsResponse.ok) {
                    const allChannels = await allChannelsResponse.json()
                    console.log(`\n📊 Current Channels (${allChannels.length} total):`)
                    allChannels.forEach(channel => {
                        console.log(`  • ${channel.code} - ${channel.name} (${channel.is_active ? 'Active' : 'Inactive'})`)
                    })
                }

                // Recommendation
                console.log('\n🎯 RECOMMENDATION FOR add_purchase_channels.sql:')
                if (!channelData.hasOwnProperty('channel_type')) {
                    console.log('❌ INCOMPATIBLE: Table missing "channel_type" column')
                    console.log('   The purchase channels script will FAIL')
                    console.log('   Option 1: Modify script to use existing columns')
                    console.log('   Option 2: Add channel_type column to channels table')
                    console.log('   Option 3: Move to scripts/temp/ for future use')
                } else {
                    console.log('✅ COMPATIBLE: Table has required structure')
                    console.log('   Purchase channels script should work')
                    console.log('   Can be moved to scripts/data/ for reference')
                }

            } else {
                console.log('ℹ️  Channels table exists but no data to inspect structure')
            }
        } else {
            console.log(`❌ Error accessing channels table: ${response.status}`)
        }

    } catch (err) {
        console.error(`❌ Check failed: ${err.message}`)
    }
}

checkChannelsStructure()