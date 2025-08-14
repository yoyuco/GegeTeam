import 'jsr:@supabase/functions-js/edge-runtime.d.ts'

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve((req: Request): Response => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  const now = new Date().toISOString()
  return new Response(`KPI recalculated at ${now}`, {
    headers: { ...corsHeaders, 'Content-Type': 'text/plain' },
  })
})
