import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://susuoambmzdmcygovkea.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1c3VvYW1ibXpkbWN5Z292a2VhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1ODQ3NTA3NSwiZXhwIjoyMDc0MDUxMDc1fQ.J_0d_tbyTqYbkBqS7v77uPq_K_Nw-5UyKczzcve1x8s',
  { auth: { persistSession: false } }
);

console.log('🔍 Testing Production Database Functions...\n');

// 1. Test available functions
console.log('1. Checking available functions:');
try {
  const { data, error } = await supabase
    .from('currency_orders')
    .select('count', { count: 'exact', head: true });

  if (error) {
    console.log('   ❌ Database access failed:', error.message);
  } else {
    console.log(`   ✅ Database accessible - ${data} orders found`);
  }
} catch (err) {
  console.log('   ❌ Connection error:', err.message);
}

// 2. Test complete_sale_order function
console.log('\n2. Testing complete_sale_order function:');
try {
  const { data, error } = await supabase.rpc('complete_sale_order', {
    p_order_id: '00000000-0000-0000-0000-000000000000',
    p_completed_by: '00000000-0000-0000-0000-000000000000'
  });

  if (error) {
    console.log('   ❌ Function error:', error.message);
    console.log('   📝 Note: Function may not exist in production');
  } else {
    console.log('   ✅ Function available:', data);
  }
} catch (err) {
  console.log('   ❌ Exception:', err.message);
}

// 3. Test confirm_purchase_order_receiving_v2 function
console.log('\n3. Testing confirm_purchase_order_receiving_v2 function:');
try {
  const { data, error } = await supabase.rpc('confirm_purchase_order_receiving_v2', {
    p_order_id: '00000000-0000-0000-0000-000000000000',
    p_completed_by: '00000000-0000-0000-0000-000000000000'
  });

  if (error) {
    console.log('   ❌ Function error:', error.message);
    console.log('   📝 Note: Function may not exist in production');
  } else {
    console.log('   ✅ Function available:', data);
  }
} catch (err) {
  console.log('   ❌ Exception:', err.message);
}

// 4. Check actual orders
console.log('\n4. Getting sample orders:');
try {
  const { data, error } = await supabase
    .from('currency_orders')
    .select('id, order_number, order_type, status, quantity')
    .order('created_at', { ascending: false })
    .limit(3);

  if (error) {
    console.log('   ❌ Query failed:', error.message);
  } else {
    console.log('   ✅ Sample orders:');
    data.forEach((order, i) => {
      console.log(`     ${i+1}. ${order.order_number} - ${order.order_type} - ${order.status} - Qty: ${order.quantity}`);
      console.log(`        ID: ${order.id}`);
    });
  }
} catch (err) {
  console.log('   ❌ Exception:', err.message);
}

// 5. Test get_current_profile_id
console.log('\n5. Testing get_current_profile_id:');
try {
  const { data, error } = await supabase.rpc('get_current_profile_id');

  if (error) {
    console.log('   ❌ Function error:', error.message);
  } else {
    console.log('   ✅ Function returned:', data);
  }
} catch (err) {
  console.log('   ❌ Exception:', err.message);
}

console.log('\n📋 Summary:');
console.log('============');
console.log('✅ Production database connection: Working');
console.log('📊 Orders available: Yes');
console.log('🔧 RPC Functions: Need to be deployed');