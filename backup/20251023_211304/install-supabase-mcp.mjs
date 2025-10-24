import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

// Get the current directory for ES modules
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// ANSI color codes for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
}

// Color utility functions
const colorLog = (message, color = 'reset') => {
  console.log(`${colors[color]}${message}${colors.reset}`)
}

const colorError = (message) => {
  console.error(`${colors.red}${message}${colors.reset}`)
}

const colorSuccess = (message) => {
  console.log(`${colors.green}${message}${colors.reset}`)
}

const colorWarn = (message) => {
  console.log(`${colors.yellow}${message}${colors.reset}`)
}

const colorInfo = (message) => {
  console.log(`${colors.blue}${message}${colors.reset}`)
}

// Main installation class
class SupabaseMCPInstaller {
  constructor() {
    this.projectRoot = __dirname
    this.toolsDir = path.join(this.projectRoot, 'tools')
    this.supabaseMCPDir = path.join(this.toolsDir, 'supabase-mcp')
    this.mcpConfigPath = path.join(this.projectRoot, 'supabase-mcp-config.json')
    this.claudeConfigPath = this.getClaudeConfigPath()
  }

  // Get Claude Desktop config path based on OS
  getClaudeConfigPath() {
    const platform = process.platform
    const homeDir = process.env.HOME || process.env.USERPROFILE

    if (platform === 'darwin') {
      return path.join(
        homeDir,
        'Library',
        'Application Support',
        'Claude',
        'claude_desktop_config.json'
      )
    } else if (platform === 'win32') {
      return path.join(homeDir, 'AppData', 'Roaming', 'Claude', 'claude_desktop_config.json')
    } else {
      // Linux and other platforms
      return path.join(homeDir, '.config', 'claude', 'claude_desktop_config.json')
    }
  }

  // Create directory if it doesn't exist
  ensureDir(dirPath) {
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true })
      colorInfo(`Created directory: ${dirPath}`)
    }
  }

  // Write file with content
  writeFile(filePath, content) {
    fs.writeFileSync(filePath, content, 'utf8')
    colorInfo(`Created file: ${filePath}`)
  }

  // Install Supabase MCP Server
  async install() {
    try {
      colorLog('\n🚀 Installing Supabase MCP Server for GegeTeam Project...\n', 'cyan')

      // Create tools directory
      this.ensureDir(this.toolsDir)

      // Create supabase-mcp directory
      this.ensureDir(this.supabaseMCPDir)

      // Create package.json
      const packageJson = {
        name: 'supabase-mcp',
        version: '1.0.0',
        description: 'Supabase MCP Server for GegeTeam project',
        main: 'index.js',
        type: 'module',
        scripts: {
          start: 'node index.js',
          dev: 'node --watch index.js',
        },
        dependencies: {
          '@modelcontextprotocol/sdk': '^1.17.3',
          '@supabase/supabase-js': '^2.45.4',
          dotenv: '^17.2.1',
        },
        keywords: ['mcp', 'supabase', 'database'],
        author: '',
        license: 'MIT',
      }

      this.writeFile(
        path.join(this.supabaseMCPDir, 'package.json'),
        JSON.stringify(packageJson, null, 2)
      )

      // Create .env file template
      const envTemplate = `# Supabase Configuration
# Get these values from your Supabase project settings
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
`

      this.writeFile(path.join(this.supabaseMCPDir, '.env'), envTemplate)

      // Create index.js (MCP Server)
      const serverCode = `#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase configuration. Please check your .env file.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Create MCP server
const server = new Server(
  {
    name: 'supabase-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'supabase_query',
        description: 'Execute a SQL query on Supabase',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'SQL query to execute',
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'supabase_select',
        description: 'Select data from a Supabase table',
        inputSchema: {
          type: 'object',
          properties: {
            table: {
              type: 'string',
              description: 'Table name to select from',
            },
            columns: {
              type: 'string',
              description: 'Columns to select (comma-separated, or * for all)',
              default: '*',
            },
            filter: {
              type: 'object',
              description: 'Filter conditions (JSON object)',
            },
            limit: {
              type: 'number',
              description: 'Maximum number of rows to return',
            },
          },
          required: ['table'],
        },
      },
      {
        name: 'supabase_insert',
        description: 'Insert data into a Supabase table',
        inputSchema: {
          type: 'object',
          properties: {
            table: {
              type: 'string',
              description: 'Table name to insert into',
            },
            data: {
              type: 'object',
              description: 'Data to insert (JSON object)',
            },
          },
          required: ['table', 'data'],
        },
      },
      {
        name: 'supabase_update',
        description: 'Update data in a Supabase table',
        inputSchema: {
          type: 'object',
          properties: {
            table: {
              type: 'string',
              description: 'Table name to update',
            },
            data: {
              type: 'object',
              description: 'Data to update (JSON object)',
            },
            filter: {
              type: 'object',
              description: 'Filter conditions to identify rows to update (JSON object)',
            },
          },
          required: ['table', 'data', 'filter'],
        },
      },
      {
        name: 'supabase_delete',
        description: 'Delete data from a Supabase table',
        inputSchema: {
          type: 'object',
          properties: {
            table: {
              type: 'string',
              description: 'Table name to delete from',
            },
            filter: {
              type: 'object',
              description: 'Filter conditions to identify rows to delete (JSON object)',
            },
          },
          required: ['table', 'filter'],
        },
      },
      {
        name: 'supabase_list_tables',
        description: 'List all tables in the Supabase database',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'supabase_describe_table',
        description: 'Get schema information for a specific table',
        inputSchema: {
          type: 'object',
          properties: {
            table: {
              type: 'string',
              description: 'Table name to describe',
            },
          },
          required: ['table'],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'supabase_query': {
        const { query } = args;
        const { data, error } = await supabase.rpc('exec_sql', { sql_query: query });

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error executing query: \${error.message}\`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: \`Query results:\n\${JSON.stringify(data, null, 2)}\`,
            },
          ],
        };
      }

      case 'supabase_select': {
        const { table, columns = '*', filter = {}, limit } = args;
        let query = supabase.from(table).select(columns);

        // Apply filters
        Object.entries(filter).forEach(([key, value]) => {
          query = query.eq(key, value);
        });

        // Apply limit if specified
        if (limit) {
          query = query.limit(limit);
        }

        const { data, error } = await query;

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error selecting data: \${error.message}\`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: \`Selected data:\n\${JSON.stringify(data, null, 2)}\`,
            },
          ],
        };
      }

      case 'supabase_insert': {
        const { table, data } = args;
        const { data: result, error } = await supabase.from(table).insert(data);

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error inserting data: \${error.message}\`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: \`Inserted data:\n\${JSON.stringify(result, null, 2)}\`,
            },
          ],
        };
      }

      case 'supabase_update': {
        const { table, data, filter } = args;
        let query = supabase.from(table).update(data);

        // Apply filters
        Object.entries(filter).forEach(([key, value]) => {
          query = query.eq(key, value);
        });

        const { data: result, error } = await query;

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error updating data: \${error.message}\`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: \`Updated data:\n\${JSON.stringify(result, null, 2)}\`,
            },
          ],
        };
      }

      case 'supabase_delete': {
        const { table, filter } = args;
        let query = supabase.from(table).delete();

        // Apply filters
        Object.entries(filter).forEach(([key, value]) => {
          query = query.eq(key, value);
        });

        const { data, error } = await query;

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error deleting data: \${error.message}\`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: \`Deleted data:\n\${JSON.stringify(data, null, 2)}\`,
            },
          ],
        };
      }

      case 'supabase_list_tables': {
        // This is a workaround since Supabase doesn't have a direct way to list tables
        const { data, error } = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public');

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error listing tables: \${error.message}\`,
              },
            ],
          };
        }

        const tableNames = data.map((row) => row.table_name);

        return {
          content: [
            {
              type: 'text',
              text: \`Tables in database:\n\${tableNames.join(', ')}\`,
            },
          ],
        };
      }

      case 'supabase_describe_table': {
        const { table } = args;
        // This is a workaround since Supabase doesn't have a direct way to describe tables
        const { data, error } = await supabase
          .from('information_schema.columns')
          .select('column_name, data_type, is_nullable')
          .eq('table_schema', 'public')
          .eq('table_name', table);

        if (error) {
          return {
            content: [
              {
                type: 'text',
                text: \`Error describing table: \${error.message}\`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: \`Table schema for \${table}:\n\${JSON.stringify(data, null, 2)}\`,
            },
          ],
        };
      }

      default:
        throw new Error(\`Unknown tool: \${name}\`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: \`Error: \${error.message}\`,
        },
      ],
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Supabase MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
`

      this.writeFile(path.join(this.supabaseMCPDir, 'index.js'), serverCode)

      // Create README.md
      const readme = `# Supabase MCP Server

This is a Model Context Protocol (MCP) server for interacting with Supabase databases.

## Installation

1. Navigate to the tools/supabase-mcp directory:
   \`\`\`bash
   cd tools/supabase-mcp
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Configure your Supabase credentials by editing the \`.env\` file:
   \`\`\`
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   \`\`\`

## Usage

Once configured, this MCP server provides the following tools:

- \`supabase_query\`: Execute custom SQL queries
- \`supabase_select\`: Select data from a table
- \`supabase_insert\`: Insert data into a table
- \`supabase_update\`: Update data in a table
- \`supabase_delete\`: Delete data from a table
- \`supabase_list_tables\`: List all tables in the database
- \`supabase_describe_table\`: Get schema information for a table

## Development

To run the server in development mode with auto-restart on file changes:

\`\`\`bash
npm run dev
\`\`\`

To run the server in production mode:

\`\`\`bash
npm start
\`\`\`
`

      this.writeFile(path.join(this.supabaseMCPDir, 'README.md'), readme)

      // Create MCP configuration file
      const mcpConfig = {
        mcpServers: {
          'supabase-mcp': {
            command: 'node',
            args: [path.join(this.supabaseMCPDir, 'index.js')],
            env: {
              SUPABASE_URL: process.env.SUPABASE_URL || 'your_supabase_url_here',
              SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || 'your_supabase_anon_key_here',
            },
          },
        },
      }

      this.writeFile(this.mcpConfigPath, JSON.stringify(mcpConfig, null, 2))

      // Create installation script for npm dependencies
      const installScript = `#!/bin/bash
echo "Installing dependencies for Supabase MCP Server..."
cd "${this.supabaseMCPDir}"
npm install
echo "Dependencies installed successfully!"
`

      this.writeFile(path.join(this.projectRoot, 'install-supabase-deps.sh'), installScript)

      // Make the script executable on Unix systems
      if (process.platform !== 'win32') {
        fs.chmodSync(path.join(this.projectRoot, 'install-supabase-deps.sh'), '755')
      }

      // Create Windows batch file for dependency installation
      const windowsInstallScript = `@echo off
echo Installing dependencies for Supabase MCP Server...
cd "${this.supabaseMCPDir}"
npm install
echo Dependencies installed successfully!
`

      this.writeFile(path.join(this.projectRoot, 'install-supabase-deps.bat'), windowsInstallScript)

      colorSuccess('\n✅ Supabase MCP Server installation completed successfully!\n')

      // Display next steps
      colorLog('📋 Next Steps:', 'yellow')
      colorLog('1. Configure your Supabase credentials in tools/supabase-mcp/.env', 'white')
      colorLog('2. Install dependencies by running:', 'white')
      colorLog(`   - On Unix/Mac: ./install-supabase-deps.sh`, 'white')
      colorLog(`   - On Windows: install-supabase-deps.bat`, 'white')
      colorLog(`   - Or manually: cd tools/supabase-mcp && npm install`, 'white')
      colorLog('3. Add the MCP server configuration to your Claude Desktop config', 'white')
      colorLog(`   Configuration file: ${this.mcpConfigPath}`, 'white')
      colorLog('4. Restart Claude Desktop to load the new MCP server', 'white')

      return true
    } catch (error) {
      colorError(`\n❌ Installation failed: ${error.message}\n`)
      return false
    }
  }

  // Check if installation exists
  checkInstallation() {
    const packageJsonPath = path.join(this.supabaseMCPDir, 'package.json')
    const indexJsPath = path.join(this.supabaseMCPDir, 'index.js')
    const envPath = path.join(this.supabaseMCPDir, '.env')

    return {
      packageJson: fs.existsSync(packageJsonPath),
      indexJs: fs.existsSync(indexJsPath),
      env: fs.existsSync(envPath),
      config: fs.existsSync(this.mcpConfigPath),
    }
  }

  // Display installation status
  displayStatus() {
    const status = this.checkInstallation()

    colorLog('\n📊 Supabase MCP Server Installation Status:', 'cyan')

    const items = [
      { name: 'Package JSON', status: status.packageJson },
      { name: 'Index JS', status: status.indexJs },
      { name: 'Environment File', status: status.env },
      { name: 'MCP Configuration', status: status.config },
    ]

    items.forEach((item) => {
      const statusIcon = item.status ? '✅' : '❌'
      const statusColor = item.status ? 'green' : 'red'
      colorLog(`  ${statusIcon} ${item.name}`, statusColor)
    })

    if (status.packageJson && status.indexJs && status.env && status.config) {
      colorSuccess('\n✅ Installation is complete!\n')
    } else {
      colorWarn('\n⚠️ Installation is incomplete. Run the installation script again.\n')
    }
  }

  // Update Claude Desktop configuration
  async updateClaudeConfig() {
    try {
      // Create Claude config directory if it doesn't exist
      this.ensureDir(path.dirname(this.claudeConfigPath))

      // Read existing config or create new one
      let claudeConfig = { mcpServers: {} }

      if (fs.existsSync(this.claudeConfigPath)) {
        try {
          const configContent = fs.readFileSync(this.claudeConfigPath, 'utf8')
          claudeConfig = JSON.parse(configContent)
        } catch (error) {
          colorWarn(`Warning: Could not parse existing Claude config. Creating a new one.`)
        }
      }

      // Add Supabase MCP server configuration
      claudeConfig.mcpServers['supabase-mcp'] = {
        command: 'node',
        args: [path.join(this.supabaseMCPDir, 'index.js')],
        env: {
          SUPABASE_URL: process.env.SUPABASE_URL || 'your_supabase_url_here',
          SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || 'your_supabase_anon_key_here',
        },
      }

      // Write updated configuration
      fs.writeFileSync(this.claudeConfigPath, JSON.stringify(claudeConfig, null, 2), 'utf8')

      colorSuccess(`Claude Desktop configuration updated at: ${this.claudeConfigPath}`)
      return true
    } catch (error) {
      colorError(`Failed to update Claude Desktop configuration: ${error.message}`)
      return false
    }
  }
}

// Main execution
async function main() {
  const installer = new SupabaseMCPInstaller()

  // Parse command line arguments
  const args = process.argv.slice(2)
  const command = args[0]

  switch (command) {
    case 'install':
      await installer.install()
      break
    case 'status':
      installer.displayStatus()
      break
    case 'update-claude-config':
      await installer.updateClaudeConfig()
      break
    default:
      colorLog('Supabase MCP Server Installer', 'cyan')
      colorLog('Usage:', 'white')
      colorLog('  node install-supabase-mcp.mjs <command>', 'white')
      colorLog('\nCommands:', 'white')
      colorLog('  install              - Install Supabase MCP Server', 'white')
      colorLog('  status               - Check installation status', 'white')
      colorLog('  update-claude-config - Update Claude Desktop configuration', 'white')
      break
  }
}

// Run the main function
main().catch((error) => {
  colorError(`Error: ${error.message}`)
  process.exit(1)
})
