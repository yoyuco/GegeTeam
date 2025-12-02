# Currency System Edge Functions

This directory contains Edge Functions for automated currency management tasks.

## Available Functions

### 1. Update Exchange Rate (`update-exchange-rate`)

**Purpose**: Automatically updates exchange rates from external API.

**Endpoint**: `POST /functions/v1/update-exchange-rate`

**Usage**:

```javascript
const response = await fetch(`${SUPABASE_URL}/functions/v1/update-exchange-rate`, {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
  },
})

const result = await response.json()
```

**Features**:

- Fetches real-time exchange rates from external API
- Updates USD/VND rate (primary for currency system)
- Updates major currency pairs (EUR, GBP, JPY, CNY)
- Logs all updates to system_logs table
- Handles API failures gracefully

**Scheduling**:
Set up a cron job to run this function daily:

```bash
# Example: Run daily at 8 AM UTC
0 8 * * * curl -X POST https://your-project.supabase.co/functions/v1/update-exchange-rate -H "Authorization: Bearer YOUR_ANON_KEY"
```

### 2. Sync Inventory (`sync-inventory`)

**Purpose**: Synchronizes inventory based on transaction history.

**Endpoint**: `POST /functions/v1/sync-inventory`

**Usage**:

```javascript
// Sync all inventory
const response = await fetch(`${SUPABASE_URL}/functions/v1/sync-inventory`, {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({}),
})

// Sync specific game/league/currency
const response = await fetch(`${SUPABASE_URL}/functions/v1/sync-inventory`, {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    gameCode: 'POE1',
    leagueId: 'uuid-here',
    currencyId: 'uuid-here',
    forceSync: true,
  }),
})
```

**Parameters**:

- `gameCode` (optional): Filter by specific game ('POE1', 'POE2', 'D4')
- `leagueId` (optional): Filter by specific league UUID
- `currencyId` (optional): Filter by specific currency UUID
- `forceSync` (optional): Force update even for small differences

**Features**:

- Calculates expected inventory from transaction history
- Compares with current inventory records
- Updates discrepancies automatically
- Sets zero inventory for records with no supporting transactions
- Comprehensive logging and reporting

**Response**:

```json
{
  "success": true,
  "message": "Inventory synchronization completed. 15 records processed, 3 corrections made.",
  "data": {
    "totalRecords": 12,
    "totalUpdates": 15,
    "totalCorrections": 3,
    "syncResults": [...]
  }
}
```

## Environment Setup

These Edge Functions require the following environment variables:

1. `SUPABASE_URL`: Your Supabase project URL
2. `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase service role key

These are automatically available in Supabase Edge Functions runtime.

## Deployment

Deploy functions to Supabase:

```bash
# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy update-exchange-rate
supabase functions deploy sync-inventory
```

## Security Considerations

1. **Authentication**: Functions use service role key for database operations
2. **Rate Limiting**: Consider implementing rate limiting for external API calls
3. **Error Handling**: All functions include comprehensive error handling
4. **Logging**: All operations are logged to `system_logs` table

## Monitoring

Monitor function execution through:

- Supabase Dashboard (Edge Functions logs)
- `system_logs` table in database
- External monitoring services (optional)

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure proper headers are set in function responses
2. **API Rate Limits**: External APIs may have rate limits
3. **Database Permissions**: Service role key should have necessary permissions
4. **Time Zones**: Exchange rate updates consider server timezone

### Debugging

Enable debug logging by checking function logs in Supabase Dashboard or adding console.log statements.

## Future Enhancements

1. **Multi-source Exchange Rates**: Aggregate from multiple API providers
2. **Real-time Inventory Sync**: Use database triggers for real-time updates
3. **Advanced Analytics**: Add inventory trend analysis
4. **Alert System**: Notify on significant inventory discrepancies
