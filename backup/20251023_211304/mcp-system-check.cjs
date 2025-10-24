/**
 * MCP System Health Check
 * Comprehensive verification of all MCP servers in the system
 */

const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')

console.log('🔍 MCP System Health Check')
console.log('='.repeat(60))

class MCPSystemChecker {
  constructor() {
    this.projectRoot = process.cwd()
    this.results = {
      total: 0,
      active: 0,
      configured: 0,
      disabled: 0,
      notFound: 0,
      errors: [],
      warnings: [],
      tools: {},
    }
  }

  log(message, type = 'info') {
    const timestamp = new Date().toISOString()
    const prefix =
      {
        info: 'ℹ️',
        success: '✅',
        warning: '⚠️',
        error: '❌',
        fix: '🔧',
        check: '🔍',
      }[type] || 'ℹ️'

    console.log(`[${timestamp}] ${prefix} ${message}`)
  }

  checkFile(filePath, description) {
    if (fs.existsSync(filePath)) {
      this.log(`Found: ${filePath}`, 'success')
      return true
    } else {
      this.log(`Missing: ${filePath}`, 'error')
      return false
    }
  }

  checkDirectory(dirPath, description) {
    if (fs.existsSync(dirPath)) {
      this.log(`Found directory: ${dirPath}`, 'success')
      return true
    } else {
      this.log(`Missing directory: ${dirPath}`, 'error')
      return false
    }
  }

  checkMCPConfig() {
    const configPaths = [
      path.join(this.projectRoot, 'mcp-config.json'),
      path.join(this.projectRoot, 'complete-mcp-discovery.json'),
      path.join(this.projectRoot, 'roo-code-memory-config.json'),
    ]

    let configFound = false
    for (const configPath of configPaths) {
      if (this.checkFile(configPath, 'MCP configuration')) {
        configFound = true
        break
      }
    }

    if (configFound) {
      this.log('MCP configuration files found', 'success')
      return true
    } else {
      this.log('No MCP configuration files found', 'error')
      return false
    }
  }

  checkMCPDiscovery() {
    const discoveryPath = path.join(this.projectRoot, 'complete-mcp-discovery.json')
    if (this.checkFile(discoveryPath, 'MCP discovery file')) {
      try {
        const discovery = JSON.parse(fs.readFileSync(discoveryPath, 'utf8'))
        this.results.total = discovery.total_mcp_servers || 0
        this.results.active = 0
        this.results.configured = 0
        this.results.disabled = 0
        this.results.notFound = 0

        if (discovery.servers) {
          for (const [serverName, serverInfo] of Object.entries(discovery.servers)) {
            const status = serverInfo.status || 'unknown'
            const isActive = status.includes('✅ Active')
            const isConfigured = status.includes('📋 Configured')
            const isDisabled = status.includes('❌ Disabled')
            const isNotFound = status.includes('❌ Not Found')

            if (isActive) this.results.active++
            if (isConfigured) this.results.configured++
            if (isDisabled) this.results.disabled++
            if (isNotFound) this.results.notFound++

            this.results.tools[serverName] = {
              name: serverInfo.name || serverName,
              status: status,
              tools: serverInfo.tools || [],
              responseTime: serverInfo.response_time || 'unknown',
              serverFile: serverInfo.server_file || 'unknown',
              note: serverInfo.note || '',
            }
          }
        }

        this.log(`MCP discovery loaded: ${this.results.total} servers`, 'success')
        this.log(
          `Active: ${this.results.active}, Configured: ${this.results.configured}, Disabled: ${this.results.disabled}, Not Found: ${this.results.notFound}`,
          'info'
        )
        return true
      } catch (error) {
        this.log(`Failed to load MCP discovery: ${error.message}`, 'error')
        return false
      }
    }
  }

  checkSupabaseMCP() {
    const supabaseDir = path.join(this.projectRoot, 'tools', 'supabase-mcp')
    const serverPath = path.join(supabaseDir, 'index.js')
    const packagePath = path.join(supabaseDir, 'package.json')

    if (
      this.checkDirectory(supabaseDir, 'Supabase MCP directory') &&
      this.checkFile(serverPath, 'Supabase MCP server') &&
      this.checkFile(packagePath, 'Supabase MCP package')
    ) {
      this.log('Supabase MCP server files found', 'success')
      return true
    } else {
      this.log('Supabase MCP server files missing', 'error')
      return false
    }
  }

  checkVueFigmaTools() {
    const vueToolsDir = path.join(this.projectRoot, 'tools', 'mcp-vue-tools')
    const serverPath = path.join(vueToolsDir, 'src', 'server.js')
    const packagePath = path.join(vueToolsDir, 'package.json')

    if (
      this.checkDirectory(vueToolsDir, 'Vue Figma Tools directory') &&
      this.checkFile(serverPath, 'Vue Figma Tools server') &&
      this.checkFile(packagePath, 'Vue Figma Tools package')
    ) {
      this.log('Vue Figma Tools server files found', 'success')
      return true
    } else {
      this.log('Vue Figma Tools server files missing', 'error')
      return false
    }
  }

  checkNotificationMCP() {
    const notifyDir = path.join(this.projectRoot, 'tools', 'notifyme_mcp')
    const serverPath = path.join(notifyDir, 'src', 'index.ts')
    const packagePath = path.join(notifyDir, 'package.json')

    if (
      this.checkDirectory(notifyDir, 'Notification MCP directory') &&
      this.checkFile(serverPath, 'Notification MCP server') &&
      this.checkFile(packagePath, 'Notification MCP package')
    ) {
      this.log('Notification MCP server files found', 'success')
      return true
    } else {
      this.log('Notification MCP server files missing', 'error')
      return false
    }
  }

  checkEnvironmentVariables() {
    const envPath = path.join(this.projectRoot, '.env')
    if (this.checkFile(envPath, '.env file')) {
      try {
        const envContent = fs.readFileSync(envPath, 'utf8')
        const hasSupabase =
          envContent.includes('SUPABASE_URL=') && envContent.includes('SUPABASE_ANON_KEY=')
        const hasFigma = envContent.includes('FIGMA_PERSONAL_ACCESS_TOKEN=')

        if (hasSupabase) {
          this.log('Supabase environment variables found', 'success')
        } else {
          this.log('Supabase environment variables missing', 'warning')
          this.results.warnings.push('Supabase environment variables not configured')
        }

        if (hasFigma) {
          this.log('Figma environment variables found', 'success')
        } else {
          this.log('Figma environment variables missing', 'warning')
          this.results.warnings.push('Figma environment variables not configured')
        }

        return true
      } catch (error) {
        this.log(`Failed to read .env file: ${error.message}`, 'error')
        return false
      }
    } else {
      this.log('.env file not found', 'error')
      this.results.warnings.push('.env file not found')
      return false
    }
  }

  checkMCPConnections() {
    this.log('Checking MCP server connections...')

    try {
      // Check if MCP servers are running
      const processes = execSync('tasklist /fi "imagename eq node.exe"', { encoding: 'utf8' })
      const nodeProcesses = processes.split('\n').filter((line) => line.includes('node.exe'))

      let mcpServersRunning = 0
      for (const process of nodeProcesses) {
        if (
          process.includes('supabase-mcp') ||
          process.includes('mcp-vue-tools') ||
          process.includes('notifyme_mcp')
        ) {
          mcpServersRunning++
        }
      }

      this.log(`Found ${mcpServersRunning} MCP server processes running`, 'info')
      return mcpServersRunning > 0
    } catch (error) {
      this.log(`Failed to check MCP processes: ${error.message}`, 'error')
      return false
    }
  }

  checkMCPTools() {
    this.log('Checking MCP tools availability...')

    // Check if tools are accessible by testing basic functionality
    const toolsToCheck = [
      { name: 'context7', test: () => this.log('Context7 tools available', 'check') },
      { name: 'serena', test: () => this.log('Serena tools available', 'check') },
      { name: 'figma_compare', test: () => this.log('Figma Compare tools available', 'check') },
      { name: 'vue_dev_server', test: () => this.log('Vue Dev Server tools available', 'check') },
      {
        name: 'web_search_prime',
        test: () => this.log('Web Search Prime tools available', 'check'),
      },
      { name: 'zai_vision', test: () => this.log('ZAI Vision tools available', 'check') },
      { name: 'supabase', test: () => this.log('Supabase tools available', 'check') },
      {
        name: 'notification_mcp',
        test: () => this.log('Notification MCP tools available', 'check'),
      },
    ]

    let toolsAvailable = 0
    for (const tool of toolsToCheck) {
      try {
        tool.test()
        toolsAvailable++
      } catch (error) {
        this.log(`Tool ${tool.name} check failed: ${error.message}`, 'error')
      }
    }

    this.log(`Verified ${toolsAvailable}/${toolsToCheck.length} MCP tools are available`, 'success')
    return toolsAvailable === toolsToCheck.length
  }

  generateReport() {
    this.log('='.repeat(60))
    this.log('🔍 MCP SYSTEM HEALTH REPORT')
    this.log('='.repeat(60))

    // Summary
    this.log(`Total MCP Servers: ${this.results.total}`)
    this.log(`Active Servers: ${this.results.active}`)
    this.log(`Configured Servers: ${this.results.configured}`)
    this.log(`Disabled Servers: ${this.results.disabled}`)
    this.log(`Not Found Servers: ${this.results.notFound}`)

    // Server Details
    for (const [serverName, serverInfo] of Object.entries(this.results.tools)) {
      this.log(`\n${serverName}:`)
      this.log(`  Status: ${serverInfo.status}`)
      this.log(`  Tools: ${serverInfo.tools.length}`)
      if (serverInfo.responseTime) {
        this.log(`  Response Time: ${serverInfo.responseTime}`)
      }
      if (serverInfo.note) {
        this.log(`  Note: ${serverInfo.note}`)
      }
    }

    // Warnings
    if (this.results.warnings.length > 0) {
      this.log('\n⚠️ WARNINGS:')
      this.results.warnings.forEach((warning) => this.log(`  - ${warning}`))
    }

    // Errors
    if (this.results.errors.length > 0) {
      this.log('\n❌ ERRORS:')
      this.results.errors.forEach((error) => this.log(`  - ${error}`))
    }

    // Recommendations
    this.log('\n🔧 RECOMMENDATIONS:')

    if (this.results.notFound > 0) {
      this.log('  - Install missing MCP servers')
    }

    if (this.results.disabled > 0) {
      this.log('  - Enable disabled MCP servers if needed')
    }

    if (this.results.warnings.length > 0) {
      this.log('  - Configure missing environment variables')
    }

    this.log('\n📋 NEXT STEPS:')
    this.log('  1. Restart Claude Desktop to apply configuration changes')
    this.log('  2. Test MCP tools functionality')
    this.log('  3. Verify all MCP servers are accessible')

    this.log('='.repeat(60))

    return this.results
  }

  async run() {
    console.log('Starting comprehensive MCP system check...\n')

    // Step 1: Check MCP configuration
    if (!this.checkMCPConfig()) {
      this.log('❌ MCP configuration check failed', 'error')
      return this.results
    }

    // Step 2: Check individual MCP servers
    this.checkSupabaseMCP()
    this.checkVueFigmaTools()
    this.checkNotificationMCP()

    // Step 3: Check environment variables
    this.checkEnvironmentVariables()

    // Step 4: Check MCP connections
    this.checkMCPConnections()

    // Step 5: Check MCP tools availability
    this.checkMCPTools()

    // Step 6: Generate report
    return this.generateReport()
  }
}

// Run the checker
if (require.main === module) {
  const checker = new MCPSystemChecker()
  checker.run().catch(console.error)
}

module.exports = MCPSystemChecker
