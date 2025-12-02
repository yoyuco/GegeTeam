# Script Management Guide

## Quick Reference

### ✅ COMPLETED - Script Organization
- Created `scripts/` directory structure
- Moved all test/check scripts to `scripts/check/`
- Added cleanup guidelines to project memory
- Created documentation and .gitkeep files

### 📂 Current Script Locations

**Database & MCP Testing Scripts:**
```
scripts/check/
├── test_mcp_connection.js     # Original MCP connection test
├── test_mcp_simple.js         # Simplified connection test
├── check_database_schema.js   # Schema inspection attempt
├── check_schema_simple.js     # Simple schema check
├── check_schema_anon.js       # Anonymous key test
├── check_tables_direct.js     # Direct HTTP API table check
└── check_empty_tables.js      # Empty table structure analysis
```

**Other Scripts:**
- `MIGRATION_GUIDE.md` - Work shift migration guide (root)
- Migration files in `supabase/migrations/`

### 🧹 CLEANUP REMINDERS

**When MCP Supabase testing is COMPLETE:**
1. Delete or archive scripts in `scripts/check/`
2. Remove from git: `git rm scripts/check/test_mcp_*.js`
3. Update memory file: project_cleanup_and_script_management

**Regular Maintenance:**
1. Clean `scripts/temp/` weekly
2. Remove debug scripts after use
3. Keep only essential utilities

### 📋 Script Creation Guidelines

**Naming Convention:**
- Test scripts: `test-YYYY-MM-DD-description.js`
- Check scripts: `check-description.js`
- Temp scripts: `temp-YYYY-MM-DD-description.js`

**Placement:**
- `/scripts/test/` - Testing functionality
- `/scripts/check/` - Database/schema checks
- `/scripts/temp/` - Temporary debugging (CLEAN UP!)

**Documentation:**
- Add clear headers explaining purpose
- Include usage examples
- Note dependencies and cleanup requirements

### 🔄 Workflow

1. **Create script** in appropriate directory
2. **Test and validate** functionality
3. **Document** usage and purpose
4. **Archive or delete** when no longer needed
5. **Update project memory** with cleanup notes

### 💡 Tips

- **Use scripts/temp/** for quick debugging
- **Keep useful patterns** in scripts/check/ or scripts/test/
- **Add cleanup reminders** to memory
- **Regular cleanup** prevents clutter
- **Version control** important scripts, ignore temporary ones

---

**Remember:** Clean code includes clean directory structure! 🧹✨