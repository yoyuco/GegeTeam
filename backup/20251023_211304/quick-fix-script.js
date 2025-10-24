#!/usr/bin/env node

/**
 * Quick Fix Script for JSON Language Server Error
 *
 * This script applies immediate fixes to resolve the TypeError: e is not iterable error
 * in VS Code JSON Language Server caused by MCP integration conflicts.
 *
 * Usage: node quick-fix-script.js
 */

const fs = require('fs')
const path = require('path')

console.log('🚀 JSON Language Server Quick Fix\n')
console.log('================================\n')

const colors = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m',
}

function log(color, message) {
  console.log(`${colors[color]}${message}${colors.reset}`)
}

function backupFile(filePath) {
  if (fs.existsSync(filePath)) {
    const backupPath = `${filePath}.backup.${Date.now()}`
    fs.copyFileSync(filePath, backupPath)
    log('blue', `📋 Backed up: ${filePath} -> ${backupPath}`)
    return backupPath
  }
  return null
}

function applyQuickFix1() {
  log('yellow', '🔧 Applying Fix 1: Disable MCP JSON validation temporarily...')

  const memoryConfigPath = 'roo-code-memory-config.json'
  backupFile(memoryConfigPath)

  try {
    const config = JSON.parse(fs.readFileSync(memoryConfigPath, 'utf8'))

    // Disable JSON validation for all MCP tools
    Object.keys(config.mcpTools || {}).forEach((tool) => {
      if (config.mcpTools[tool]) {
        config.mcpTools[tool].jsonValidation = false
        config.mcpTools[tool].schemaCache = false
      }
    })

    fs.writeFileSync(memoryConfigPath, JSON.stringify(config, null, 2))
    log('green', '✅ Fix 1 applied: MCP JSON validation disabled')
  } catch (error) {
    log('red', `❌ Fix 1 failed: ${error.message}`)
  }
}

function applyQuickFix2() {
  log('yellow', '🔧 Applying Fix 2: Simplify VS Code JSON settings...')

  const settingsPath = path.join('.vscode', 'settings.json')
  backupFile(settingsPath)

  try {
    const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'))

    // Disable JSON tracing temporarily
    settings['json.trace.server'] = 'off'
    settings['json.validate.enable'] = false
    settings['json.maxItemsComputed'] = 1000

    // Simplify schema configuration
    settings['json.schemas'] = [
      {
        fileMatch: ['package.json'],
        schema: 'https://json.schemastore.org/package',
      },
      {
        fileMatch: ['tsconfig.json'],
        schema: 'https://json.schemastore.org/tsconfig',
      },
    ]

    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2))
    log('green', '✅ Fix 2 applied: VS Code JSON settings simplified')
  } catch (error) {
    log('red', `❌ Fix 2 failed: ${error.message}`)
  }
}

function applyQuickFix3() {
  log('yellow', '🔧 Applying Fix 3: Update Context7 configuration...')

  const context7Path = 'context7.json'
  backupFile(context7Path)

  try {
    const config = JSON.parse(fs.readFileSync(context7Path, 'utf8'))

    // Remove custom schema URL to prevent validation conflicts
    delete config.$schema

    // Simplify configuration
    config.excludeFolders = ['node_modules', 'dist', '.git', '.vscode', '.claude', 'results']

    fs.writeFileSync(context7Path, JSON.stringify(config, null, 2))
    log('green', '✅ Fix 3 applied: Context7 configuration updated')
  } catch (error) {
    log('red', `❌ Fix 3 failed: ${error.message}`)
  }
}

function applyQuickFix4() {
  log('yellow', '🔧 Applying Fix 4: Create minimal MCP configuration...')

  const minimalConfig = {
    version: '2.0.0',
    memorySystem: {
      enabled: true,
      autoDetection: false,
      learning: false,
      persistence: true,
    },
    mcpTools: {
      context7: {
        enabled: true,
        jsonValidation: false,
        schemaCache: false,
        priority: 2,
      },
      serena: {
        enabled: false,
      },
      figma_compare: {
        enabled: false,
      },
      notification_mcp: {
        enabled: false,
      },
    },
  }

  backupFile('roo-code-memory-config.json')
  fs.writeFileSync('roo-code-memory-config.json', JSON.stringify(minimalConfig, null, 2))
  log('green', '✅ Fix 4 applied: Minimal MCP configuration created')
}

function createRecoveryScript() {
  log('yellow', '🔧 Creating recovery script...')

  const recoveryScript = `#!/usr/bin/env node

/**
 * Recovery Script to Restore Original Configuration
 * Run this script if the quick fixes cause issues.
 */

const fs = require('fs');
const path = require('path');

console.log('🔄 Restoring original configuration...');

// Find backup files
const files = [
  'roo-code-memory-config.json',
  '.vscode/settings.json',
  'context7.json'
];

files.forEach(file => {
  const backupPattern = file + '.backup.*';
  const backupFiles = fs.readdirSync('.').filter(f => f.startsWith(file + '.backup.'));

  if (backupFiles.length > 0) {
    const latestBackup = backupFiles.sort().pop();
    fs.copyFileSync(latestBackup, file);
    console.log(\`✅ Restored: \${file}\`);
  }
});

console.log('✅ Recovery completed. Please restart VS Code.');
`

  fs.writeFileSync('restore-config.js', recoveryScript)
  log('green', '✅ Recovery script created: restore-config.js')
}

function showNextSteps() {
  log('blue', '\n📋 Next Steps:')
  log('white', '1. Restart VS Code completely')
  log('white', '2. Open a JSON file to test')
  log('white', '3. Check Developer Tools for any remaining errors')
  log('white', '4. If issues persist, run: node restore-config.js')

  log('blue', '\n🔍 Manual Testing:')
  log('white', '- Open package.json')
  log('white', '- Try editing JSON files')
  log('white', '- Check for IntelliSense in JSON')
  log('white', '- Verify MCP tools still work')

  log('blue', '\n📞 If problems continue:')
  log('white', '- Check: JSON_LANGUAGE_SERVER_TROUBLESHOOTING.md')
  log('white', '- Run: node diagnostic-script.js')
  log('white', '- Review: mcp-conflict-resolution.md')
}

// Main execution
function main() {
  log('cyan', 'Applying quick fixes for JSON Language Server error...\n')

  applyQuickFix1()
  applyQuickFix2()
  applyQuickFix3()
  applyQuickFix4()
  createRecoveryScript()

  showNextSteps()

  log('green', '\n✅ Quick fixes completed successfully!')
  log('yellow', '⚠️  Please restart VS Code to apply changes.')
}

if (require.main === module) {
  main()
}

module.exports = {
  applyQuickFix1,
  applyQuickFix2,
  applyQuickFix3,
  applyQuickFix4,
}
