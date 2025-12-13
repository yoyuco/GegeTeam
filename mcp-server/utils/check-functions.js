import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  { auth: { persistSession: false } }
);

async function checkFunctions() {
  console.log('🔍 Checking functions in production database...');
  console.log(`📡 URL: ${process.env.SUPABASE_URL}`);

  // Try to call complete_sale_order function
  console.log('\n1. Testing complete_sale_order:');
  try {
    const { data, error } = await supabase.rpc('complete_sale_order', {
      p_order_id: '00000000-0000-0000-0000-000000000000',
      p_completed_by: '00000000-0000-0000-0000-000000000000'
    });

    if (error) {
      console.log('   ❌ Error:', error.message);
    } else {
      console.log('   ✅ Available');
    }
  } catch (err) {
    console.log('   ❌ Exception:', err.message);
  }

  // Try to call confirm_purchase_order_receiving_v2 function
  console.log('\n2. Testing confirm_purchase_order_receiving_v2:');
  try {
    const { data, error } = await supabase.rpc('confirm_purchase_order_receiving_v2', {
      p_order_id: '00000000-0000-0000-0000-000000000000',
      p_completed_by: '00000000-0000-0000-0000-000000000000'
    });

    if (error) {
      console.log('   ❌ Error:', error.message);
    } else {
      console.log('   ✅ Available');
    }
  } catch (err) {
    console.log('   ❌ Exception:', err.message);
  }

  // Check for get_current_profile_id
  console.log('\n3. Testing get_current_profile_id:');
  try {
    const { data, error } = await supabase.rpc('get_current_profile_id');

    if (error) {
      console.log('   ❌ Error:', error.message);
    } else {
      console.log('   ✅ Available, returned:', data);
    }
  } catch (err) {
    console.log('   ❌ Exception:', err.message);
  }

  // Test direct query on currency_orders
  console.log('\n4. Testing currency_orders access:');
  try {
    const { data, error } = await supabase
      .from('currency_orders')
      .select('count', { count: 'exact', head: true });

    if (error) {
      console.log('   ❌ Error:', error.message);
    } else {
      console.log('   ✅ Accessible, total orders:', data);
    }
  } catch (err) {
    console.log('   ❌ Exception:', err.message);
  }

  // Get sample orders to see structure
  console.log('\n5. Getting sample orders:');
  try {
    const { data, error } = await supabase
      .from('currency_orders')
      .select('order_number, order_type, status, created_at')
      .order('created_at', { ascending: false })
      .limit(3);

    if (error) {
      console.log('   ❌ Error:', error.message);
    } else {
      console.log('   ✅ Sample orders:');
      data.forEach((order, i) => {
        console.log(`     ${i+1}. ${order.order_number} - ${order.order_type} - ${order.status}`);
      });
    }
  } catch (err) {
    console.log('   ❌ Exception:', err.message);
  }

  console.log('\n📋 Summary:');
  console.log('=========');

  process.exit(0);
}

checkFunctions().catch(console.error);