import { defineStore } from 'pinia' import { supabase } from '@/lib/supabase' export const useAuth =
defineStore('auth', { state: () => ({ user: null as any }), actions: { async init() { const { data }
= await supabase.auth.getUser() this.user = data.user ?? null supabase.auth.onAuthStateChange((_e,
s) => (this.user = s?.user ?? null)) }, async signIn(email: string, password: string) { const {
data, error } = await supabase.auth.signInWithPassword({ email, password }) if (error) throw error
this.user = data.user }, async signOut() { await supabase.auth.signOut() this.user = null }, }, })
