// Accounting library functions
import { supabase } from './supabase';

export interface ChartOfAccount {
  id: string;
  account_code: string;
  account_name: string;
  account_category: 'ASSET' | 'LIABILITY' | 'EQUITY' | 'REVENUE' | 'EXPENSE';
  parent_account_id?: string;
  is_active: boolean;
  description?: string;
}

export interface JournalEntry {
  id: string;
  entry_number: string;
  entry_date: string;
  description?: string;
  reference_type?: string;
  reference_id?: string;
  total_amount: number;
  currency_code: string;
  status: 'draft' | 'posted' | 'void';
  created_by: string;
  approved_by?: string;
  created_at: string;
  lines?: JournalEntryLine[];
}

export interface JournalEntryLine {
  id: string;
  journal_entry_id: string;
  line_number: number;
  account_id: string;
  entity_type?: string;
  entity_id?: string;
  debit_amount: number;
  credit_amount: number;
  description?: string;
  account_name?: string; // Joined field
}

export interface EmployeeFundAccount {
  id: string;
  employee_id: string;
  currency_code: string;
  current_balance: number;
  credit_limit: number;
  total_allocated: number;
  total_returned: number;
  is_active: boolean;
  employee_name?: string; // Joined field
}

export interface EmployeeFundTransaction {
  id: string;
  transaction_number: string;
  employee_id: string;
  transaction_type: 'FUND_ALLOCATION' | 'FUND_RETURN' | 'FUND_ADJUSTMENT' | 'FUND_TRANSFER';
  amount: number;
  currency_code: string;
  balance_before: number;
  balance_after: number;
  description?: string;
  reference_type?: string;
  reference_id?: string;
  approval_status: 'auto_approved' | 'pending' | 'approved' | 'rejected';
  created_at: string;
  employee_name?: string; // Joined field
}

export interface ApprovalRequest {
  id: string;
  request_number: string;
  entity_type: string;
  entity_id: string;
  requester_id: string;
  amount: number;
  currency_code: string;
  description?: string;
  status: 'pending' | 'approved' | 'rejected' | 'expired';
  approver_id?: string;
  approval_notes?: string;
  rejection_reason?: string;
  requested_at: string;
  expires_at: string;
}

// Chart of Accounts functions
export async function getChartOfAccounts(): Promise<ChartOfAccount[]> {
  const { data, error } = await supabase
    .from('chart_of_accounts')
    .select('*')
    .eq('is_active', true)
    .order('account_code');

  if (error) throw error;
  return data || [];
}

export async function getAccountBalance(accountId: string, entityType = 'company', entityId?: string): Promise<any> {
  const { data, error } = await supabase
    .from('account_balances')
    .select('*')
    .eq('account_id', accountId)
    .eq('entity_type', entityType)
    .eq('entity_id', entityId || '')
    .single();

  if (error && error.code !== 'PGRST116') throw error; // Ignore "not found" error
  return data;
}

// Employee Fund Management
export async function getEmployeeFundAccounts(employeeId?: string): Promise<EmployeeFundAccount[]> {
  let query = supabase
    .from('employee_fund_accounts')
    .select(`
      *,
      profiles!employee_fund_accounts_employee_id_fkey (
        display_name as employee_name
      )
    `)
    .eq('is_active', true);

  if (employeeId) {
    query = query.eq('employee_id', employeeId);
  }

  const { data, error } = await query.order('last_transaction_at', { ascending: false });

  if (error) throw error;
  return data || [];
}

export async function getEmployeeFundBalance(employeeId: string, currencyCode: string): Promise<number> {
  const { data, error } = await supabase
    .from('employee_fund_accounts')
    .select('current_balance')
    .eq('employee_id', employeeId)
    .eq('currency_code', currencyCode)
    .eq('is_active', true)
    .single();

  if (error && error.code !== 'PGRST116') throw error;
  return data?.current_balance || 0;
}

export async function allocateEmployeeFunds(
  employeeId: string,
  amount: number,
  currencyCode: string = 'VND',
  description?: string,
  referenceType?: string,
  referenceId?: string
): Promise<{
  success: boolean;
  message: string;
  transactionId?: string;
  requiresApproval?: boolean;
}> {
  const { data, error } = await supabase.rpc('allocate_employee_fund', {
    p_employee_id: employeeId,
    p_amount: amount,
    p_currency_code: currencyCode,
    p_description: description,
    p_created_by: (await supabase.auth.getUser()).data?.id,
    p_reference_type: referenceType,
    p_reference_id: referenceId
  });

  if (error) throw error;
  return data[0];
}

export async function returnEmployeeFunds(
  employeeId: string,
  amount: number,
  currencyCode: string = 'VND',
  description?: string,
  referenceType?: string,
  referenceId?: string
): Promise<{
  success: boolean;
  message: string;
  transactionId?: string;
}> {
  const { data, error } = await supabase.rpc('return_employee_fund', {
    p_employee_id: employeeId,
    p_amount: amount,
    p_currency_code: currencyCode,
    p_description: description,
    p_created_by: (await supabase.auth.getUser()).data?.id,
    p_reference_type: referenceType,
    p_reference_id: referenceId
  });

  if (error) throw error;
  return data[0];
}

export async function getEmployeeFundTransactions(
  employeeId?: string,
  fromDate?: string,
  toDate?: string
): Promise<EmployeeFundTransaction[]> {
  let query = supabase
    .from('employee_fund_transactions')
    .select(`
      *,
      profiles!employee_fund_transactions_employee_id_fkey (
        display_name as employee_name
      )
    `);

  if (employeeId) {
    query = query.eq('employee_id', employeeId);
  }

  if (fromDate) {
    query = query.gte('created_at', fromDate);
  }

  if (toDate) {
    query = query.lte('created_at', toDate);
  }

  const { data, error } = await query.order('created_at', { ascending: false });

  if (error) throw error;
  return data || [];
}

// Approval Management
export async function getPendingApprovals(): Promise<ApprovalRequest[]> {
  const { data, error } = await supabase
    .from('pending_approvals_view')
    .select('*')
    .order('requested_at', { ascending: false });

  if (error) throw error;
  return data || [];
}

export async function approveRequest(
  requestId: string,
  approvalNotes?: string
): Promise<{
  success: boolean;
  message: string;
}> {
  const { data, error } = await supabase.rpc('approve_request', {
    p_approval_request_id: requestId,
    p_approver_id: (await supabase.auth.getUser()).data?.id,
    p_approval_notes: approvalNotes
  });

  if (error) throw error;
  return data[0];
}

export async function rejectRequest(
  requestId: string,
  rejectionReason: string
): Promise<{
  success: boolean;
  message: string;
}> {
  const { data, error } = await supabase.rpc('reject_request', {
    p_approval_request_id: requestId,
    p_approver_id: (await supabase.auth.getUser()).data?.id,
    p_rejection_reason: rejectionReason
  });

  if (error) throw error;
  return data[0];
}

// Journal Entries
export async function createJournalEntry(
  description: string,
  entries: Array<{
    accountCode: string;
    entityType?: string;
    entityId?: string;
    debitAmount?: number;
    creditAmount?: number;
    description?: string;
  }>,
  referenceType?: string,
  referenceId?: string
): Promise<string> {
  // First, get account IDs from account codes
  const accountCodes = entries.map(e => e.accountCode);
  const { data: accounts, error: accountError } = await supabase
    .from('chart_of_accounts')
    .select('id, account_code')
    .in('account_code', accountCodes);

  if (accountError) throw accountError;

  const accountMap = new Map(
    accounts?.map(a => [a.account_code, a.id]) || []
  );

  // Prepare journal entry lines
  const journalLines = entries.map(entry => ({
    account_id: accountMap.get(entry.accountCode),
    entity_type: entry.entityType,
    entity_id: entry.entityId,
    debit_amount: entry.debitAmount || 0,
    credit_amount: entry.creditAmount || 0,
    description: entry.description
  }));

  // Calculate total amount
  const totalAmount = entries.reduce((sum, e) =>
    sum + (e.debitAmount || 0) + (e.creditAmount || 0), 0
  );

  // Create journal entry
  const { data, error } = await supabase
    .from('journal_entries')
    .insert({
      entry_number: `JE-${new Date().getFullYear()}-${Math.random().toString(36).substr(2, 5)}`,
      entry_date: new Date().toISOString().split('T')[0],
      description,
      reference_type: referenceType,
      reference_id: referenceId,
      total_amount: totalAmount / 2, // Because debits = credits
      status: 'posted',
      created_by: (await supabase.auth.getUser()).data?.id
    })
    .select()
    .single();

  if (error) throw error;

  // Create journal entry lines
  const { error: lineError } = await supabase
    .from('journal_entry_lines')
    .insert(
      journalLines.map((line, index) => ({
        ...line,
        journal_entry_id: data.id,
        line_number: index + 1
      }))
    );

  if (lineError) throw lineError;

  return data.id;
}

// Reporting
export async function getTrialBalance(asOfDate?: string): Promise<any[]> {
  const { data, error } = await supabase
    .from('trial_balance')
    .select('*')
    .order('account_code');

  if (error) throw error;
  return data || [];
}

export async function getEmployeeFundReconciliation(): Promise<any[]> {
  const { data, error } = await supabase
    .from('employee_funds_reconciliation')
    .select('*')
    .order('employee_name', 'currency_code');

  if (error) throw error;
  return data || [];
}

export async function getFinancialSummary(
  fromDate?: string,
  toDate?: string
): Promise<any> {
  const { data, error } = await supabase
    .from('financial_transaction_summary')
    .select('*')
    .limit(1); // This is a summary view with just one row

  if (error) throw error;
  return data?.[0];
}

// Utility functions
export function formatCurrency(amount: number, currency: string = 'VND'): string {
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency === 'VND' ? 'USD' : currency,
    minimumFractionDigits: currency === 'VND' ? 0 : 2,
    maximumFractionDigits: currency === 'VND' ? 0 : 2
  });

  // Format VND as just number with VND suffix
  if (currency === 'VND') {
    return amount.toLocaleString('en-US') + ' VND';
  }

  return formatter.format(amount);
}

export function getTransactionStatusColor(status: string): string {
  switch (status) {
    case 'pending':
      return 'text-yellow-600';
    case 'approved':
    case 'auto_approved':
      return 'text-green-600';
    case 'rejected':
      return 'text-red-600';
    case 'expired':
      return 'text-gray-600';
    case 'posted':
      return 'text-blue-600';
    case 'draft':
      return 'text-gray-500';
    default:
      return 'text-gray-600';
  }
}

export function getTransactionTypeLabel(type: string): string {
  switch (type) {
    case 'FUND_ALLOCATION':
      return 'Cấp vốn';
    case 'FUND_RETURN':
      return 'Trả vốn';
    case 'FUND_ADJUSTMENT':
      return 'Điều chỉnh';
    case 'FUND_TRANSFER':
      return 'Chuyển khoản';
    default:
      return type;
  }
}

// Error handling
export class AccountingError extends Error {
  constructor(
    message: string,
    public code?: string,
    public details?: any
  ) {
    super(message);
    this.name = 'AccountingError';
  }
}

// Helper to check if user has accounting permissions
export async function hasAccountingPermissions(): Promise<boolean> {
  const { data: user } = await supabase.auth.getUser();
  if (!user) return false;

  // Check if user has accounting role or is admin
  const { data: roleAssignments } = await supabase
    .from('user_role_assignments')
    .select('roles(code)')
    .eq('user_id', user.id);

  return roleAssignments?.some(ra =>
    ra.roles?.code === 'accountant' || ra.roles?.code === 'admin'
  ) || false;
}