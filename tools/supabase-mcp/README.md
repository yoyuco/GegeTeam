# Supabase MCP Server

This MCP server provides tools to interact with your Supabase database.

## Installation

1. Install dependencies:

   ```bash
   cd tools/supabase-mcp
   npm install
   ```

2. Configure environment variables:
   - Add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file
   - These should be your Supabase project URL and anonymous key

## Usage

Start the server:

```bash
npm start
```

## Available Tools

- **execute_query**: Execute SQL queries
- **list_tables**: List all tables in the database
- **get_table_schema**: Get schema information for a table
- **select_from_table**: Select records from a table

## Configuration for Claude Desktop

Add this to your Claude Desktop MCP configuration:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "node",
      "args": ["tools/supabase-mcp/index.js"],
      "cwd": "D:\Web\GegeTeam",
      "env": {
        "SUPABASE_URL": "your_supabase_url",
        "SUPABASE_ANON_KEY": "your_supabase_anon_key"
      }
    }
  }
}
```
