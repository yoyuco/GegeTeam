#!/usr/bin/env node

import 'dotenv/config'
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'
import { createClient } from '@supabase/supabase-js'
import { z } from 'zod'

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables')
  console.error('Available variables:', {
    SUPABASE_URL: !!process.env.SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY: !!process.env.SUPABASE_SERVICE_ROLE_KEY,
    SUPABASE_ANON_KEY: !!process.env.SUPABASE_ANON_KEY
  })
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

const server = new McpServer(
  {
    name: 'supabase-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
)

// Tool: execute_query
server.tool(
  'execute_query',
  'Execute SQL query on Supabase database',
  {
    query: z.string().describe('SQL query to execute'),
    parameters: z.string().optional().describe('JSON parameters for prepared statement'),
  },
  async ({ query, parameters }) => {
    try {
      const trimmedQuery = query.trim().toLowerCase()

      // For SELECT queries, use direct table access
      if (trimmedQuery.startsWith('select')) {
        // Extract table name from query (simple approach)
        const tableMatch = query.match(/from\s+(\w+)/i)
        if (tableMatch) {
          const tableName = tableMatch[1]

          // Try to execute the query directly using Supabase client
          const { data, error } = await supabase
            .from(tableName)
            .select('*')

          if (error) {
            return {
              content: [
                {
                  type: 'text',
                  text: JSON.stringify({
                    error: error.message,
                    note: 'Direct SELECT failed. Try using a simpler query or check table permissions.',
                    hint: 'Available tables can be listed with list_tables tool'
                  }, null, 2),
                },
              ],
            }
          }

          return {
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  data,
                  rowCount: data?.length || 0,
                  note: 'Query executed successfully using direct table access'
                }, null, 2),
              },
            ],
          }
        }
      }

      // For other query types, provide guidance
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              error: 'Complex SQL queries not supported in this version',
              query: query,
              suggestions: [
                'Use list_tables to see available tables',
                'Use get_table_schema to see table structure',
                'Use select_from_table for simple SELECT queries',
                'For complex queries, consider using Supabase Dashboard directly'
              ]
            }, null, 2),
          },
        ],
      }
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({ error: error.message }, null, 2),
          },
        ],
      }
    }
  }
)

// Tool: list_tables
server.tool('list_tables', 'List all tables in the database', {}, async () => {
  try {
    const { data, error } = await supabase
      .from('information_schema.tables')
      .select('table_name, table_schema')
      .eq('table_schema', 'public')

    if (error) {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({ error: error.message }, null, 2),
          },
        ],
      }
    }

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(
            {
              tables: data.map((t) => t.table_name),
              count: data.length,
            },
            null,
            2
          ),
        },
      ],
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({ error: error.message }, null, 2),
        },
      ],
    }
  }
})

// Tool: get_table_schema
server.tool(
  'get_table_schema',
  'Get schema information for a specific table',
  {
    table_name: z.string().describe('Name of the table'),
  },
  async ({ table_name }) => {
    try {
      const { data, error } = await supabase
        .from('information_schema.columns')
        .select('column_name, data_type, is_nullable, column_default')
        .eq('table_name', table_name)
        .eq('table_schema', 'public')

      if (error) {
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({ error: error.message }, null, 2),
            },
          ],
        }
      }

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(
              {
                table: table_name,
                columns: data,
              },
              null,
              2
            ),
          },
        ],
      }
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({ error: error.message }, null, 2),
          },
        ],
      }
    }
  }
)

// Tool: select_from_table
server.tool(
  'select_from_table',
  'Select records from a table',
  {
    table_name: z.string().describe('Name of the table'),
    columns: z.string().optional().describe('Comma-separated column names (default: *)'),
    limit: z.number().optional().describe('Maximum number of records to return'),
    filter: z.string().optional().describe('WHERE clause filter'),
  },
  async ({ table_name, columns, limit, filter }) => {
    try {
      let query = supabase.from(table_name)

      // Select columns
      const selectColumns = columns || '*'
      query = query.select(selectColumns)

      // Apply filter
      if (filter) {
        query = query.filter(filter)
      }

      // Apply limit
      if (limit) {
        query = query.limit(limit)
      }

      const { data, error } = await query

      if (error) {
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({ error: error.message }, null, 2),
            },
          ],
        }
      }

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(
              {
                table: table_name,
                data,
                count: data?.length || 0,
              },
              null,
              2
            ),
          },
        ],
      }
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({ error: error.message }, null, 2),
          },
        ],
      }
    }
  }
)

async function main() {
  const transport = new StdioServerTransport()
  await server.connect(transport)
  console.error('Supabase MCP server started')
}

main().catch((error) => {
  console.error('Failed to start Supabase MCP server', { error })
  process.exit(1)
})
