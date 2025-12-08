# Production Supabase Server

## Files Structure
```
mcp-server/
├── production-server.js     # Production API server (PORT: 3002)
├── src/simple-server.js     # Simple testing server
├── utils/                   # Testing utilities
│   ├── check-functions.js   # Database function checker
│   ├── test-production-functions.js  # Production tests
│   └── compare-rls.js       # RLS comparison tool
├── claude_config_both.json  # Claude Desktop config
├── .env                     # Environment variables
└── package.json             # Dependencies
```

## Usage

### 1. Claude Desktop Configuration
Copy `claude_config_both.json` to Claude Desktop config:
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

### 2. Start Production Server
```bash
cd mcp-server
node production-server.js
```
Server runs on http://localhost:3002

### 3. Available Endpoints
- `GET /health` - Check connection
- `GET /orders` - Query orders with filters
- `GET /orders/:id` - Get order details
- `POST /rpc/complete_sale_order` - Complete sale order
- `POST /rpc/confirm_purchase_receiving` - Confirm purchase

## Production Database Access

**✅ Available:**
- Query currency_orders table
- Real order: `PO20251206269119` (PURCHASE, pending, Qty: 90)
- confirm_purchase_order_receiving_v2 function

**❌ Missing:**
- complete_sale_order function (needs deployment)
- get_current_profile_id function (errors)

## Tools Available
- **MCP Supabase Official**: Staging access (`mcp__supabase__*`)
- **Production Server**: Custom API for production database

## Test Commands
```bash
# Test production functions
node utils/test-production-functions.js

# Compare RLS policies
node utils/compare-rls.js
```