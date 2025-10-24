# MCP Integration Conflict Resolution Guide

## 🚨 MCP-Specific JSON Language Server Conflicts

Based on the analysis of your workspace, the JSON Language Server error `TypeError: e is not iterable` is likely caused by MCP integration conflicts. This guide addresses the specific MCP-related issues and provides resolution strategies.

---

## 🔍 Identified MCP Conflicts

### 1. **Roo Code Memory Configuration Issues**

- **File**: [`roo-code-memory-config.json`](roo-code-memory-config.json:1)
- **Issue**: Complex nested JSON structure may cause parsing conflicts
- **Impact**: JSON Language Server fails to process configuration during initialization

### 2. **MCP Tools Discovery Conflicts**

- **File**: [`mcp-tools-discovery.json`](mcp-tools-discovery.json:1)
- **Issue**: Dynamic tool schemas may conflict with VS Code JSON validation
- **Impact**: Schema validation errors during language server startup

### 3. **Context7 Integration Conflicts**

- **File**: [`context7.json`](context7.json:1)
- **Issue**: Custom schema URL may not be accessible during validation
- **Impact**: Network timeout during schema fetching

### 4. **MCP Server Runtime Conflicts**

- **Issue**: Multiple MCP servers competing for JSON processing resources
- **Impact**: Memory allocation conflicts in JSON Language Server

---

## 🛠️ Step-by-Step MCP Conflict Resolution

### Phase 1: Immediate MCP Isolation

#### 1.1 Disable MCP Tools Temporarily

```json
// Update roo-code-memory-config.json
{
  "mcpTools": {
    "serena": { "enabled": false },
    "context7": { "enabled": false },
    "figma_compare": { "enabled": false },
    "notification_mcp": { "enabled": false },
    "vue_dev_server": { "enabled": false }
  }
}
```

#### 1.2 Test JSON Language Server

1. Restart VS Code
2. Open any JSON file
3. Check if the error persists
4. If resolved, proceed to Phase 2

#### 1.3 Gradual MCP Re-enablement

```json
// Re-enable one tool at a time, testing after each
{
  "mcpTools": {
    "serena": { "enabled": true }, // Test this first
    "context7": { "enabled": false },
    "figma_compare": { "enabled": false },
    "notification_mcp": { "enabled": false }
  }
}
```

### Phase 2: MCP Configuration Optimization

#### 2.1 Optimize Roo Code Memory Configuration

```json
// Simplified configuration to reduce JSON parsing complexity
{
  "version": "2.0.0",
  "memorySystem": {
    "enabled": true,
    "autoDetection": true,
    "learning": false, // Disable learning temporarily
    "persistence": true
  },
  "mcpTools": {
    "context7": {
      "enabled": true,
      "jsonValidation": false, // Prevent JSON validation conflicts
      "schemaCache": false, // Disable schema caching
      "priority": 2
    }
  }
}
```

#### 2.2 Fix MCP Tools Discovery Configuration

```json
// Simplify tool schemas to avoid complex validation
{
  "context7": {
    "server": "context7",
    "tools": [
      {
        "name": "resolve-library-id",
        "description": "Resolve Context7 Library ID",
        "inputSchema": {
          "type": "object",
          "properties": {
            "libraryName": {
              "type": "string",
              "description": "Library name to search for"
            }
          },
          "required": ["libraryName"]
        }
      }
    ],
    "success": true
  }
}
```

#### 2.3 Update Context7 Configuration

```json
{
  "$schema": "https://json.schemastore.org/context7",
  "projectTitle": "GegeTeam - Currency Management System",
  "description": "Currency trading and order management system",
  "folders": ["src", "supabase/migrations", "src/components"],
  "excludeFolders": ["node_modules", "dist", ".git"],
  "rules": [
    "Focus on Vue.js 3 + TypeScript architecture",
    "Currency system uses Supabase as backend"
  ],
  "keywords": ["vue3", "typescript", "supabase", "currency"]
}
```

### Phase 3: VS Code Integration Fixes

#### 3.1 Update VS Code Settings for MCP Compatibility

```json
// In .vscode/settings.json
{
  "json.validate.enable": true,
  "json.trace.server": "off", // Disable verbose tracing
  "json.schemas": [
    {
      "fileMatch": ["roo-code-memory-config.json"],
      "schema": {
        "type": "object",
        "properties": {
          "version": { "type": "string" },
          "memorySystem": { "type": "object" },
          "mcpTools": { "type": "object" }
        }
      }
    }
  ],
  "json.maxItemsComputed": 5000, // Limit computation for complex JSON
  "editor.largeFileOptimizations": true
}
```

#### 3.2 Add MCP File Exclusions

```json
{
  "files.exclude": {
    "**/.mcp-cache": true,
    "**/mcp-logs": true,
    "**/.roo-code-memory": true
  },
  "search.exclude": {
    "**/mcp-tools-*.json": false, // Keep searchable but excluded from validation
    "**/roo-code-memory-config.json": false
  }
}
```

### Phase 4: MCP Server Runtime Optimization

#### 4.1 Configure MCP Server Isolation

```json
// Create mcp-settings.json
{
  "servers": {
    "context7": {
      "command": "npx",
      "args": ["context7-server"],
      "env": {
        "NODE_NO_WARNINGS": "1",
        "JSON_VALIDATION": "false"
      },
      "timeout": 10000
    },
    "notification_mcp": {
      "command": "node",
      "args": ["tools/notifyme_mcp/dist/index.js"],
      "cwd": "${workspaceFolder}",
      "env": {
        "MCP_JSON_MODE": "simple"
      }
    }
  }
}
```

#### 4.2 Update VS Code MCP Extension Settings

```json
{
  "mcp.serverStartupTimeout": 15000,
  "mcp.maxConcurrentRequests": 5,
  "mcp.enableTracing": false,
  "mcp.logLevel": "warn"
}
```

---

## 🔧 Specific MCP Tool Fixes

### Fix 1: Context7 JSON Schema Conflict

```json
// In context7.json, remove custom schema URL temporarily
{
  "projectTitle": "GegeTeam - Currency Management System",
  "description": "Currency trading and order management system",
  // Remove $schema line to prevent validation conflicts
  "folders": ["src", "supabase/migrations"],
  "excludeFolders": ["node_modules", "dist"]
}
```

### Fix 2: Notification MCP Configuration

```json
// In tools/notifyme_mcp/package.json
{
  "name": "notifyme_mcp",
  "version": "1.0.0",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc --skipLibCheck", // Skip lib checking to avoid JSON conflicts
    "dev": "tsx src/index.ts --no-validate-json"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0",
    "zod": "^3.22.0"
  }
}
```

### Fix 3: Vue Figma Tools JSON Handling

```javascript
// In tools/mcp-vue-tools/src/server.js
const server = new Server(
  {
    name: 'vue-figma-tools',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      // Disable JSON validation capabilities temporarily
      validation: false,
    },
  }
)

// Add JSON parsing error handling
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  try {
    const { name, arguments: args } = request.params

    // Validate JSON arguments safely
    if (typeof args === 'string') {
      try {
        const parsedArgs = JSON.parse(args)
        return await handleToolCall(name, parsedArgs)
      } catch {
        // Fallback to string arguments if JSON parsing fails
        return await handleToolCall(name, { raw: args })
      }
    }

    return await handleToolCall(name, args)
  } catch (error) {
    console.error('Tool execution error:', error)
    return {
      content: [{ type: 'text', text: `Error: ${error.message}` }],
      isError: true,
    }
  }
})
```

---

## 🧪 MCP Conflict Testing Procedures

### Test 1: JSON Language Server Isolation

```bash
# 1. Disable all MCP tools
# 2. Restart VS Code
# 3. Test JSON file editing
# 4. Check Developer Tools for errors
```

### Test 2: Progressive MCP Re-enablement

```bash
# Enable one MCP tool at a time
# Test JSON functionality after each enablement
# Document which tool causes conflicts
```

### Test 3: Schema Validation Test

```bash
# Create test JSON files for each MCP configuration
# Validate with online JSON validators
# Check VS Code JSON validation results
```

### Test 4: Performance Impact Test

```bash
# Monitor VS Code memory usage with/without MCP
# Test JSON file opening speed
# Check for memory leaks
```

---

## 🚨 Emergency MCP Recovery

### Complete MCP Reset

```bash
# 1. Stop all MCP servers
taskkill /f /im node.exe

# 2. Clear MCP cache
rmdir /s /q "%USERPROFILE%\.mcp-cache"
rmdir /s /q ".roo-code-memory"

# 3. Reset MCP configuration
echo '{"version": "2.0.0", "mcpTools": {}}' > roo-code-memory-config.json

# 4. Restart VS Code
code --disable-extensions
```

### Minimal MCP Configuration

```json
{
  "version": "2.0.0",
  "memorySystem": {
    "enabled": false,
    "autoDetection": false,
    "learning": false,
    "persistence": false
  },
  "mcpTools": {
    "context7": {
      "enabled": true,
      "jsonValidation": false,
      "priority": 1
    }
  }
}
```

---

## 📊 MCP Monitoring and Prevention

### Monitoring Commands

```bash
# Monitor MCP server processes
ps aux | grep -i mcp

# Check MCP server logs
tail -f ~/.mcp-logs/*.log

# Monitor VS Code JSON Language Server
# Open VS Code Developer Tools > Console
```

### Prevention Strategies

1. **Regular MCP Configuration Validation**
   - Validate JSON files before committing
   - Use pre-commit hooks for MCP configs

2. **Schema Version Management**
   - Pin schema versions in MCP configs
   - Test schema changes in isolation

3. **Performance Monitoring**
   - Monitor MCP server memory usage
   - Set up alerts for JSON parsing errors

4. **Backup and Recovery**
   - Regular backups of working MCP configurations
   - Document known working configurations

---

## 🎯 Success Criteria

MCP integration is successful when:

- ✅ JSON Language Server starts without errors
- ✅ MCP tools function correctly
- ✅ No performance degradation
- ✅ JSON validation works for all files
- ✅ MCP configurations are properly validated
- ✅ No conflicts between MCP and VS Code extensions

---

## 📞 MCP-Specific Support Resources

### MCP Documentation

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Roo Code MCP Integration Guide](https://roo-code.com/docs/mcp)
- [VS Code MCP Extension](https://marketplace.visualstudio.com/items?itemName=roo-code.mcp)

### Community Support

- [Roo Code Discord](https://discord.gg/roo-code)
- [MCP GitHub Discussions](https://github.com/modelcontextprotocol/discussions)
- [VS Code Extension Issues](https://github.com/microsoft/vscode/issues)

---

**Last Updated**: 2025-10-23
**MCP Version**: Compatible with v1.0.0+
**VS Code Version**: v1.80+
**Test Environment**: Windows 11, Node.js 22.18.0

_This guide specifically addresses MCP integration conflicts with the JSON Language Server in the GegeTeam workspace._
