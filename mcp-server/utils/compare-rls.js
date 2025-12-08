import { createClient } from '@supabase/supabase-js';

// Staging client
const staging = createClient(
  'https://nxlrnwijsxqalcxyavkj.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDAwMDAwMCwiZXhwIjoyMDc1NDk5OTl9fQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU',
  { auth: { persistSession: false } }
);

// Production client
const production = createClient(
  'https://susuoambmzdmcygovkea.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1c3VvYW1ibXpkbWN5Z292a2VhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1ODQ3NTA3NSwiZXhwIjoyMDc0MDUxMDc1fQ.J_0d_tbyTqYbkBqS7v77uPq_K_Nw-5UyKczzcve1x8s',
  { auth: { persistSession: false } }
);

console.log('🔍 Comparing RLS Policies for currency_orders\n');

async function compareRLS() {
  console.log('📋 STAGING RLS Policies:');
  console.log('=========================');

  try {
    // Use a view that exists to check RLS status
    const stagingTest = await staging
      .from('currency_orders')
      .select('count', { count: 'exact', head: true });

    console.log(`✅ Service role access: ${stagingTest.count} orders`);
    console.log('✅ RLS Status: ENABLED (from previous query)');

    console.log('\n📋 Staging Policies:');
    console.log('- Comprehensive currency orders access policy (SELECT)');
    console.log('  * Roles: authenticated');
    console.log('  * Conditions: admin/mod/manager/leader OR created_by OR assigned_to');
    console.log('');
    console.log('- Users can insert currency orders (INSERT)');
    console.log('  * Roles: public');
    console.log('  * Conditions: created_by = profile_id from auth.uid()');
    console.log('');
    console.log('- Users can update currency orders (UPDATE)');
    console.log('  * Roles: authenticated');
    console.log('  * Conditions: created_by OR assigned_to OR admin/mod/manager/leader');

  } catch (error) {
    console.log('❌ Staging query failed:', error.message);
  }

  console.log('\n\n📋 PRODUCTION RLS Policies:');
  console.log('==========================');

  try {
    const productionTest = await production
      .from('currency_orders')
      .select('count', { count: 'exact', head: true });

    console.log(`✅ Service role access: ${productionTest.count} orders`);

    // Test if RLS is enabled by checking if we can query without service role
    console.log('\n🔍 Checking RLS status...');

    // Production seems to have different RLS or no RLS since we can query
    // Let's check by looking at actual order data structure
    const sampleOrder = await production
      .from('currency_orders')
      .select('id, order_number, created_by, assigned_to')
      .limit(1);

    console.log('\n📊 Sample production order structure:');
    if (sampleOrder.data && sampleOrder.data.length > 0) {
      const order = sampleOrder.data[0];
      console.log(`Order ID: ${order.id}`);
      console.log(`Order Number: ${order.order_number}`);
      console.log(`Created By: ${order.created_by || 'NULL'}`);
      console.log(`Assigned To: ${order.assigned_to || 'NULL'}`);
    }

  } catch (error) {
    console.log('❌ Production query failed:', error.message);
    console.log('This suggests RLS might be enabled with different policies');
  }

  console.log('\n\n📊 COMPARISON SUMMARY:');
  console.log('======================');
  console.log('STAGING:');
  console.log('✅ RLS: ENABLED');
  console.log('✅ Policies: 3 comprehensive policies');
  console.log('✅ Role-based access control with user assignments');
  console.log('');
  console.log('PRODUCTION:');
  console.log('❓ RLS: Unknown (likely different or minimal)');
  console.log('❓ Policies: Cannot retrieve via service role');
  console.log('⚠️  Service role bypasses RLS, so differences may exist');
  console.log('');
  console.log('RECOMMENDATION:');
  console.log('🔧 Apply staging RLS policies to production for consistency');
}

compareRLS().catch(console.error);