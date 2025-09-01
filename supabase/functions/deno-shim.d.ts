// supabase/functions/deno-shim.d.ts
export {}

declare global {
  // Shim tối thiểu để TS biết Deno trong workspace Node/Vite
  const Deno: {
    serve: (handler: (req: Request) => Response | Promise<Response>) => void
    env?: { get(name: string): string | undefined }
  }
}
