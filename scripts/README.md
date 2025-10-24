# Scripts Directory

This directory contains various utility scripts for development and testing.

## Directory Structure

```
scripts/
├── test/           # Test and validation scripts
├── check/          # Database schema and connectivity check scripts
├── temp/           # Temporary scripts (should be cleaned up regularly)
└── README.md       # This file
```

## Script Categories

### `/test/` - Testing Scripts
- Scripts for testing functionality
- Integration test scripts
- Performance testing scripts

### `/check/` - Check & Validation Scripts
- Database connectivity checks
- Schema validation scripts
- Environment verification scripts

### `/temp/` - Temporary Scripts
- One-time utility scripts
- Debug scripts
- Scripts that should be deleted after use

## Cleanup Policy

**Important:** Scripts in `/temp/` directory should be:
1. Used for temporary testing/debugging
2. Deleted when no longer needed
3. Not committed to version control if possible

## Usage Guidelines

1. **Place scripts in appropriate subdirectory**
2. **Add clear documentation for each script**
3. **Clean up `/temp/` scripts regularly**
4. **Add `.gitignore` rules for sensitive temporary files**

## File Naming Convention

- Use kebab-case for file names
- Add date prefix for temporary files: `YYYY-MM-DD-script-name.js`
- Add clear descriptions in file headers

## Memory Note

See project memory for cleanup instructions and script management guidelines.