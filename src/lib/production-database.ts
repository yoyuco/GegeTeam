export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      currencies: {
        Row: {
          id: string
          code: string
          name: string
          symbol: string
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string
        }
        Insert: {
          id?: string
          code: string
          name: string
          symbol: string
          created_at?: string
          updated_at?: string
          created_by?: string
          updated_by?: string
        }
        Update: {
          id?: string
          code?: string
          name?: string
          symbol?: string
          created_at?: string
          updated_at?: string
          created_by?: string
          updated_by?: string
        }
      }
      currency_orders: {
        Row: {
          id: string
          order_number: string
          type: 'CURRENCY' | 'EXCHANGE'
          status: string
          currency_code: string
          amount: number
          exchange_rate: number
          party_type: string
          party_id: string
          game_code: string
          server_attribute_code: string
          assigned_to: string
          submitted_by: string
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string
        }
        Insert: {
          id?: string
          order_number: string
          type?: 'CURRENCY' | 'EXCHANGE'
          status?: string
          currency_code: string
          amount?: number
          exchange_rate?: number
          party_type?: string
          party_id?: string
          game_code?: string
          server_attribute_code?: string
          assigned_to?: string
          submitted_by?: string
          created_at?: string
          updated_at?: string
          created_by?: string
          updated_by?: string
        }
        Update: {
          id?: string
          order_number?: string
          type?: 'CURRENCY' | 'EXCHANGE'
          status?: string
          currency_code?: string
          amount?: number
          exchange_rate?: number
          party_type?: string
          party_id?: string
          game_code?: string
          server_attribute_code?: string
          assigned_to?: string
          submitted_by?: string
          created_at?: string
          updated_at?: string
          created_by?: string
          updated_by?: string
        }
      }
      currency_transactions: {
        Row: {
          id: string
          currency_order_id: string
          game_account_id: string
          currency_code: string
          amount: number
          transaction_type: string
          created_at: string
          created_by: string
        }
        Insert: {
          id?: string
          currency_order_id: string
          game_account_id: string
          currency_code: string
          amount?: number
          transaction_type?: string
          created_at?: string
          created_by?: string
        }
        Update: {
          id?: string
          currency_order_id?: string
          game_account_id?: string
          currency_code?: string
          amount?: number
          transaction_type?: string
          created_at?: string
          created_by?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      assign_currency_order_v1: {
        Args: {
          p_order_id: string
          p_game_account_id: string
          p_assignment_notes: string
        }
        Returns: {
          success: boolean
          message: string
          status: string
        }
      }
    }
    Enums: {
      currency_exchange_type_enum: 'currency'
      currency_order_status_enum: string[]
      currency_order_type_enum: 'CURRENCY'
    }
  }
}

// Add your existing types below if needed