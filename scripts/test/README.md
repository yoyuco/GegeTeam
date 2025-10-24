# Testing Scripts

This directory contains scripts for testing database compatibility and functionality.

## Available Scripts

### Database Compatibility Tests
- `test_purchase_channels_script.sql` - Test purchase channels script compatibility
  - Verifies database structure compatibility
  - Tests INSERT statement compatibility
  - Checks constraint compatibility
  - Provides final recommendations

## Usage

### Running Compatibility Tests
```sql
-- Run in Supabase SQL Editor to test before running data scripts
-- This will verify if add_purchase_channels_compatible.sql will work
```

## Test Categories

### ✅ Structure Validation
- Column existence checks
- Data type compatibility
- Constraint verification

### ✅ Data Validation
- Sample data testing
- Conflict detection
- Query compatibility

### ✅ Final Assessment
- Overall compatibility score
- Recommendations
- Next steps

## Test Results Format

Tests provide clear ✅/❌ indicators:
- ✅ COMPATIBLE - Will work with current structure
- ❌ INCOMPATIBLE - Needs modification
- ⚠️ WARNING - Will work but needs attention

## Memory Notes

See project memory for:
- Test history and results
- Compatibility requirements
- Database structure changes