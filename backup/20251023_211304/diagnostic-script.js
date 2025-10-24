#!/usr/bin/env node

/**
 * JSON Language Server Diagnostic Script
 *
 * This script helps diagnose the JSON Language Server connection error
 * by checking workspace configuration, extension conflicts, and MCP integration issues.
 *
 * Usage: node diagnostic-script.js
 */

const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')

console.log('🔍 JSON Language Server Diagnostic Tool\n')
console.log('=====================================\n')

// Colors for output
const colors = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
  reset: '\x1b[0m',
}

function log(color, message) {
  console.log(`${colors[color]}${message}${colors.reset}`)
}

function checkFile(filePath, description) {
  try {
    const content = fs.readFileSync(filePath, 'utf8')
    log('green', `✅ ${description}: Found and readable`)
    return content
  } catch (error) {
    log('red', `❌ ${description}: ${error.message}`)
    return null
  }
}

function validateJSON(jsonString, filePath) {
  try {
    JSON.parse(jsonString)
    log('green', `✅ Valid JSON: ${filePath}`)
    return true
  } catch (error) {
    log('red', `❌ Invalid JSON: ${filePath} - ${error.message}`)
    return false
  }
}

function checkNodeVersion() {
  try {
    const version = execSync('node --version', { encoding: 'utf8' }).trim()
    const majorVersion = parseInt(version.slice(1).split('.')[0])

    log('blue', `📦 Node.js Version: ${version}`)

    if (majorVersion < 18) {
      log('yellow', '⚠️  Node.js version is below 18.x - may cause compatibility issues')
    } else {
      log('green', '✅ Node.js version is compatible')
    }

    return version
  } catch (error) {
    log('red', '❌ Could not determine Node.js version')
    return null
  }
}

function checkVSCodeExtensions() {
  try {
    const extensions = execSync('code --list-extensions', { encoding: 'utf8' })
    const jsonExtensions = extensions
      .split('\n')
      .filter(
        (ext) =>
          ext.toLowerCase().includes('json') ||
          ext.toLowerCase().includes('language') ||
          ext.toLowerCase().includes('schema')
      )

    log('blue', '🔌 JSON/Language Related Extensions:')
    if (jsonExtensions.length > 0) {
      jsonExtensions.forEach((ext) => log('cyan', `   - ${ext}`))
    } else {
      log('yellow', '   No JSON/Language extensions found')
    }

    return jsonExtensions
  } catch {
    log('yellow', '⚠️  Could not list VS Code extensions (code command not found)')
    return []
  }
}

function analyzeVSCodeSettings() {
  log('blue', '🔧 Analyzing VS Code Settings...')

  const settingsPath = path.join('.vscode', 'settings.json')
  const settings = checkFile(settingsPath, 'VS Code Settings')

  if (!settings) return

  if (!validateJSON(settings, settingsPath)) return

  const settingsObj = JSON.parse(settings)

  // Check for problematic configurations
  const issues = []

  if (settingsObj['json.schemas']) {
    log('cyan', '   Found JSON schema configuration')

    // Check for invalid schema URLs
    for (const schema of Object.values(settingsObj['json.schemas'])) {
      if (typeof schema === 'string' && schema.startsWith('http')) {
        try {
          new URL(schema)
          log('green', `   ✅ Valid schema URL: ${schema}`)
        } catch {
          issues.push(`Invalid schema URL: ${schema}`)
        }
      }
    }
  }

  if (settingsObj['json.trace.server']) {
    log('cyan', `   JSON trace server: ${settingsObj['json.trace.server']}`)
  }

  if (issues.length > 0) {
    log('red', '   Configuration Issues Found:')
    issues.forEach((issue) => log('red', `   ❌ ${issue}`))
  } else {
    log('green', '   ✅ No configuration issues detected')
  }
}

function analyzeMCPConfiguration() {
  log('blue', '🤖 Analyzing MCP Configuration...')

  const mcpFiles = [
    'roo-code-memory-config.json',
    'mcp-tools-discovery.json',
    'mcp-tools-specifications.json',
    'context7.json',
  ]

  let mcpIssues = 0

  mcpFiles.forEach((file) => {
    const content = checkFile(file, `MCP Config: ${file}`)
    if (content && !validateJSON(content, file)) {
      mcpIssues++
    }
  })

  if (mcpIssues === 0) {
    log('green', '✅ All MCP configuration files are valid JSON')
  } else {
    log('red', `❌ Found ${mcpIssues} MCP configuration issues`)
  }

  // Check for potential conflicts in roo-code-memory-config.json
  const memoryConfig = checkFile('roo-code-memory-config.json', 'Memory Config')
  if (memoryConfig) {
    try {
      const config = JSON.parse(memoryConfig)
      const enabledMCPs = Object.keys(config.mcpTools || {}).filter(
        (key) => config.mcpTools[key].enabled
      )

      log('cyan', `   Enabled MCP Tools: ${enabledMCPs.join(', ')}`)

      // Check for JSON-related configurations
      const jsonRelatedTools = enabledMCPs.filter(
        (tool) => tool.toLowerCase().includes('json') || tool.toLowerCase().includes('schema')
      )

      if (jsonRelatedTools.length > 0) {
        log('yellow', `   ⚠️  JSON-related MCP tools enabled: ${jsonRelatedTools.join(', ')}`)
        log('yellow', '   These may conflict with VS Code JSON Language Server')
      }
    } catch (error) {
      log('red', `❌ Error parsing memory config: ${error.message}`)
    }
  }
}

function checkPackageJSON() {
  log('blue', '📦 Analyzing Package Configuration...')

  const packageJson = checkFile('package.json', 'Package.json')
  if (!packageJson) return

  if (!validateJSON(packageJson, 'package.json')) return

  const pkg = JSON.parse(packageJson)

  // Check for JSON-related dependencies
  const jsonDeps = Object.keys(pkg.dependencies || {})
    .concat(Object.keys(pkg.devDependencies || []))
    .filter((dep) => dep.toLowerCase().includes('json'))

  if (jsonDeps.length > 0) {
    log('cyan', `   JSON-related dependencies: ${jsonDeps.join(', ')}`)
  }

  // Check for scripts that might affect JSON processing
  const jsonScripts = Object.keys(pkg.scripts || {}).filter((script) =>
    pkg.scripts[script].toLowerCase().includes('json')
  )

  if (jsonScripts.length > 0) {
    log('cyan', `   JSON-related scripts: ${jsonScripts.join(', ')}`)
  }
}

function checkTsConfig() {
  log('blue', '📘 Analyzing TypeScript Configuration...')

  const tsConfig = checkFile('tsconfig.json', 'TypeScript Config')
  if (!tsConfig) return

  if (!validateJSON(tsConfig, 'tsconfig.json')) return

  const config = JSON.parse(tsConfig)

  if (config.compilerOptions) {
    if (config.compilerOptions.resolveJsonModule) {
      log('green', '   ✅ JSON module resolution enabled')
    }

    if (config.compilerOptions.strictNullChecks) {
      log('cyan', '   ℹ️  Strict null checks enabled - may affect JSON parsing')
    }

    if (config.compilerOptions.exactOptionalPropertyTypes) {
      log('yellow', '   ⚠️  Exact optional properties enabled - may cause JSON issues')
    }
  }
}

function generateReport() {
  log('magenta', '\n📊 Diagnostic Summary')
  log('magenta', '==================')

  log('blue', '\n🔧 Recommended Actions:')
  log('white', '1. If MCP tools are causing conflicts, temporarily disable them')
  log('white', '2. Update VS Code JSON schema configuration to use array format')
  log('white', '3. Clear VS Code extension cache and restart')
  log('white', '4. Check for VS Code updates and install latest version')

  log('blue', '\n🚀 Quick Fix Commands:')
  log('cyan', '# Disable JSON tracing (temporarily)')
  log('white', '{"json.trace.server": "off"}')

  log('cyan', '# Reset JSON schemas to minimal configuration')
  log('white', '{"json.schemas": []}')

  log('cyan', '# Clear VS Code extension cache (Windows)')
  log('white', 'rmdir /s /q "%USERPROFILE%\\.vscode\\extensions"')

  log('blue', '\n📞 If issues persist:')
  log('white', '1. Check VS Code Developer Tools for detailed error logs')
  log('white', '2. Review JSON_LANGUAGE_SERVER_TROUBLESHOOTING.md')
  log('white', '3. Report issue to VS Code GitHub with diagnostic output')
}

// Main execution
function main() {
  log('cyan', 'Starting JSON Language Server Diagnostic...\n')

  // Basic environment checks
  checkNodeVersion()
  checkVSCodeExtensions()

  // Configuration analysis
  analyzeVSCodeSettings()
  analyzeMCPConfiguration()
  checkPackageJSON()
  checkTsConfig()

  // Generate recommendations
  generateReport()

  log('green', '\n✅ Diagnostic completed successfully!')
}

if (require.main === module) {
  main()
}

module.exports = {
  checkFile,
  validateJSON,
  analyzeVSCodeSettings,
  analyzeMCPConfiguration,
}
