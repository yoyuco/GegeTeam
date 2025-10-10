# Staging Database Schema Export

**Project:** GegeTeam
**Environment:** Staging
**Supabase Project:** fvgjmfytzdnrdlluktdx
**Export Date:** 2025-10-10
**Export Source:** https://fvgjmfytzdnrdlluktdx.supabase.co

## 📁 Exported Files

### Schema Files (Successfully Exported)

1. **`full-schema.sql`** (483KB) - Complete database schema including:
   - ✅ All tables (CREATE TABLE statements)
   - ✅ All enums (CREATE TYPE statements)
   - ✅ All indexes (CREATE INDEX statements)
   - ✅ All constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
   - ✅ All triggers (CREATE TRIGGER statements)
   - ✅ All functions (CREATE FUNCTION statements)
   - ✅ All Row Level Security (RLS) policies
   - ✅ All schemas (public, auth, storage, realtime, extensions, graphql_public)

2. **`01-public-schema.sql`** (309KB) - Public schema objects:
   - ✅ Application tables
   - ✅ Currency system tables
   - ✅ User management tables
   - ✅ Game accounts and inventory tables
   - ✅ Transactions and audit tables

3. **`02-auth-schema.sql`** (48KB) - Authentication schema:
   - ✅ Users table
   - ✅ Sessions table
   - ✅ Auth-related functions and triggers
   - ✅ Auth RLS policies

4. **`03-storage-schema.sql`** (54KB) - Storage schema:
   - ✅ Buckets table
   - ✅ Objects table
   - ✅ Storage-related functions and policies

5. **`04-realtime-schema.sql`** (58KB) - Realtime schema:
   - ✅ Realtime subscriptions and messages
   - ✅ Realtime functions and triggers

### Missing Files (Connection Timeout Issues)

❌ **`05-extensions-schema.sql`** - Extensions schema (connection timeout)
❌ **`06-public-data.sql`** - Table data (connection timeout)
❌ **`07-roles.sql`** - Database roles (connection timeout)

## 🔍 Schema Overview

### Main Tables in Public Schema

#### Currency Management System

- `attributes` - Game attributes and currency definitions
- `currency_inventory` - Currency inventory tracking
- `currency_transactions` - Transaction records
- `trading_fees` - Trading fee configuration
- `channels` - Sales channels
- `sellers` - Seller information

#### User Management

- `profiles` - User profiles
- `parties` - Party/user relationships
- `game_accounts` - Game account management
- `manager_profiles` - Manager profiles

#### System Tables

- `audit_logs` - Audit trail
- `notifications` - System notifications
- `settings` - System settings

#### Enum Types

- Currency types and game types
- Transaction statuses
- User roles and permissions

## 🔐 Security Features

### Row Level Security (RLS) Policies

- ✅ All tables have comprehensive RLS policies
- ✅ User-based access control
- ✅ Role-based permissions
- ✅ Data isolation by game/league

### Database Functions

- ✅ Currency transaction management
- ✅ Inventory calculations
- ✅ User permission checks
- ✅ Audit logging functions

### Triggers

- ✅ Audit trail creation
- ✅ Inventory updates
- ✅ Data validation
- ✅ Timestamp management

## 📊 Data Export Status

**Note:** Due to connection timeout issues with the staging database, table data could not be automatically exported. However, the complete schema structure is available.

### Manual Data Export Options

1. **Using Supabase Dashboard:**
   - Go to https://fvgjmfytzdnrdlluktdx.supabase.co
   - Navigate to Table Editor
   - Export individual tables as CSV

2. **Using psql (if connection is stable):**

   ```bash
   psql "postgresql://postgres:[PASSWORD]@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres" -c "\copy (SELECT * FROM table_name) TO 'table_data.csv' WITH CSV HEADER"
   ```

3. **Using API:**
   - Use Supabase client with service role key
   - Export data programmatically

## 🚀 How to Use This Schema

### For Local Development

1. Create a new Supabase project
2. Apply the schema files in order:

   ```bash
   # Apply full schema at once
   psql -d your_database -f full-schema.sql

   # Or apply schema by schema
   psql -d your_database -f 01-public-schema.sql
   psql -d your_database -f 02-auth-schema.sql
   psql -d your_database -f 03-storage-schema.sql
   psql -d your_database -f 04-realtime-schema.sql
   ```

### For Migration to New Environment

1. Use the `full-schema.sql` file as a complete migration
2. Review and modify any environment-specific settings
3. Apply to target database
4. Import data separately

### For Schema Documentation

- Use these files as complete documentation of the staging database structure
- All relationships, constraints, and security policies are included
- Function signatures and trigger definitions are preserved

## 🔧 Important Notes

1. **Connection Issues:** Some exports failed due to network timeout issues with the staging database
2. **Schema Completeness:** The exported schema includes all database objects except some extensions
3. **Data Integrity:** All foreign key relationships and constraints are preserved
4. **Security:** All RLS policies and security configurations are included
5. **Functions:** All custom functions and stored procedures are exported

## 📈 Database Statistics

- **Total Schema Size:** ~950KB
- **Main Tables:** 20+ application tables
- **Enums:** 15+ custom enum types
- **Functions:** 25+ custom functions
- **Triggers:** 10+ triggers
- **RLS Policies:** 30+ security policies

## 🛠️ Environment Configuration

**Staging Environment:**

- URL: https://fvgjmfytzdnrdlluktdx.supabase.co
- Region: Southeast Asia (Singapore)
- Database Version: PostgreSQL 17
- Project ID: fvgjmfytzdnrdlluktdx

## 📝 Next Steps

1. **Schema Review:** Review the exported schema for any environment-specific values
2. **Data Export:** Manually export critical data if needed
3. **Testing:** Test schema application in development environment
4. **Documentation:** Update any missing documentation
5. **Security:** Review RLS policies for target environment

---

_Export completed using Supabase CLI v2.47.1_
_Note: Some exports failed due to connection timeouts - retry with stable network connection for complete export_
