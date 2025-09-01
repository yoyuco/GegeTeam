/// <reference path="../deno-shim.d.ts" />
/// <reference lib="dom" />
import 'jsr:@supabase/functions-js/edge-runtime.d.ts'

// deno run -A --watch=static/,src/ dev.ts (nếu chạy local với deno)

Deno.serve(async (req) => {
  try {
    // TODO: query VIEW/MV như farmer_kpi/daily_totals
    return new Response(JSON.stringify({ ok: true, at: new Date().toISOString() }), {
      headers: { 'content-type': 'application/json' }
    })
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: String(e) }), { status: 500 })
  }
})
