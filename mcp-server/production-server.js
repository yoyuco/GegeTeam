import { createClient } from '@supabase/supabase-js';
import express from 'express';
import cors from 'cors';

// Production Supabase client
const supabase = createClient(
  'https://susuoambmzdmcygovkea.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1c3VvYW1ibXpkbWN5Z292a2VhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1ODQ3NTA3NSwiZXhwIjoyMDc0MDUxMDc1fQ.J_0d_tbyTqYbkBqS7v77uPq_K_Nw-5UyKczzcve1x8s',
  { auth: { persistSession: false } }
);

const app = express();
app.use(cors());
app.use(express.json());

const PORT = 3002;

console.log('🚀 Production API Server Starting...');
console.log('📡 Supabase URL: https://susuoambmzdmcygovkea.supabase.co');

// Test connection
async function testConnection() {
  try {
    const { data, error } = await supabase
      .from('currency_orders')
      .select('count', { count: 'exact', head: true });

    if (error) {
      console.log('❌ Connection failed:', error.message);
      return false;
    }

    console.log(`✅ Connected - Found ${data} orders in production`);
    return true;
  } catch (err) {
    console.log('❌ Connection error:', err.message);
    return false;
  }
}

// API Routes
app.get('/health', async (req, res) => {
  try {
    const { count } = await supabase
      .from('currency_orders')
      .select('count', { count: 'exact', head: true });

    res.json({
      status: 'healthy',
      environment: 'production',
      orders_count: count,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ status: 'error', error: error.message });
  }
});

app.get('/orders', async (req, res) => {
  try {
    const { limit = 10, status, order_type } = req.query;

    let query = supabase
      .from('currency_orders')
      .select(`
        id, order_number, order_type, status, quantity,
        cost_amount, sale_amount, created_at, updated_at,
        created_by, assigned_to
      `);

    if (status) query = query.eq('status', status);
    if (order_type) query = query.eq('order_type', order_type);

    const { data, error } = await query
      .order('created_at', { ascending: false })
      .limit(parseInt(limit));

    if (error) throw error;

    res.json({
      success: true,
      environment: 'production',
      count: data.length,
      orders: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.get('/orders/:order_id', async (req, res) => {
  try {
    const { order_id } = req.params;

    const { data, error } = await supabase
      .from('currency_orders')
      .select('*')
      .eq('id', order_id)
      .single();

    if (error) throw error;

    res.json({
      success: true,
      environment: 'production',
      order: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.post('/rpc/complete_sale_order', async (req, res) => {
  try {
    const { order_id, completed_by } = req.body;

    const { data, error } = await supabase.rpc('complete_sale_order', {
      p_order_id: order_id,
      p_completed_by: completed_by
    });

    if (error) {
      res.json({
        success: false,
        error: error.message,
        note: 'Function complete_sale_order may not exist in production'
      });
      return;
    }

    res.json({
      success: true,
      environment: 'production',
      result: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.post('/rpc/confirm_purchase_receiving', async (req, res) => {
  try {
    const { order_id, confirmed_by } = req.body;

    const { data, error } = await supabase.rpc('confirm_purchase_order_receiving_v2', {
      p_order_id: order_id,
      p_completed_by: confirmed_by
    });

    if (error) {
      res.json({
        success: false,
        error: error.message,
        note: 'Function confirm_purchase_order_receiving_v2 may not exist in production'
      });
      return;
    }

    res.json({
      success: true,
      environment: 'production',
      result: data
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Start server
async function startServer() {
  const connected = await testConnection();

  if (connected) {
    console.log('\n🔧 Available API endpoints:');
    console.log('   GET  /health - Check connection');
    console.log('   GET  /orders - Query orders');
    console.log('   GET  /orders/:id - Get order details');
    console.log('   POST /rpc/complete_sale_order - Complete sale');
    console.log('   POST /rpc/confirm_purchase_receiving - Confirm purchase');
  }

  app.listen(PORT, () => {
    console.log(`\n🌐 Production API Server running on http://localhost:${PORT}`);
  });
}

startServer().catch(console.error);