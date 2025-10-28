/**
 * Assignment Helper Utility for managing employee shift assignments
 * Handles 4 core scenarios: Normal, Future Changes, Active Changes, Emergency Cases
 */

import { supabase } from '@/lib/supabase'
import { formatGMT7Date, getGMT7Date, isTimeInShift } from '@/utils/timezoneHelper'
import { getShiftDateTimeRange } from '@/utils/shiftUtils'

export interface Assignment {
  id: string
  employee_profile_id: string
  employee_name: string
  shift_id: string
  shift_name: string
  assigned_date: string
  is_active: boolean
  assigned_at: string
  last_handover_time?: string
  handover_count?: number
  backup_employee_id?: string
  is_fallback?: boolean
  fallback_reason?: string
  fallback_time?: string
}

export interface ChangeImpact {
  type: 'normal' | 'future' | 'active_handover' | 'emergency'
  severity: 'low' | 'medium' | 'high'
  message: string
  requiresNotification: boolean
}

export interface HandoverRecord {
  from_employee_id: string
  to_employee_id: string
  shift_id: string
  assigned_date: string
  handover_time: string
  reason?: string
}

export class AssignmentHelper {
  /**
   * Get effective assignment with fallback logic
   * Priority: 1) Explicit assignment, 2) Most recent, 3) Default
   */
  static async getEffectiveAssignment(date: string, employeeId: string, shiftId: string): Promise<Assignment | null> {
    try {
      // Priority 1: Explicit assignment for the specific date
      const { data: explicit, error: explicitError } = await supabase
        .from('employee_shift_assignments')
        .select(`
          *,
          profiles!employee_shift_assignments_employee_profile_id_fkey(display_name),
          work_shifts(name)
        `)
        .eq('assigned_date', date)
        .eq('employee_profile_id', employeeId)
        .eq('shift_id', shiftId)
        .eq('is_active', true)
        .single()

      if (explicit && !explicitError) {
        return this.formatAssignment(explicit)
      }

      // Priority 2: Most recent assignment before the date
      const { data: recent, error: recentError } = await supabase
        .from('employee_shift_assignments')
        .select(`
          *,
          profiles!employee_shift_assignments_employee_profile_id_fkey(display_name),
          work_shifts(name)
        `)
        .eq('employee_profile_id', employeeId)
        .eq('shift_id', shiftId)
        .eq('is_active', true)
        .lt('assigned_date', date)
        .order('assigned_date', { ascending: false })
        .limit(1)
        .single()

      if (recent && !recentError) {
        // Mark as fallback
        return {
          ...this.formatAssignment(recent),
          is_fallback: true,
          fallback_reason: 'Using most recent assignment as fallback',
          fallback_time: new Date().toISOString()
        }
      }

      // Priority 3: No assignment found
      return null
    } catch (error) {
      console.error('Error getting effective assignment:', error)
      return null
    }
  }

  /**
   * Check if assignment is currently active
   */
  static isCurrentlyActive(assignment: Assignment): boolean {
    const now = getGMT7Date()
    const today = formatGMT7Date(now)
    const assignmentDate = assignment.assigned_date

    if (assignmentDate !== today) return false

    // We don't have shift time details in Assignment interface
    // For now, assume if date matches today, it's considered active
    // This can be enhanced later with shift time checking
    return true
  }

  /**
   * Analyze change impact when updating an assignment
   */
  static analyzeChangeImpact(currentAssignment: Assignment, changes: any): ChangeImpact {
    const newDate = changes.assigned_date || currentAssignment.assigned_date
    const today = formatGMT7Date(getGMT7Date())

    if (newDate > today) {
      return {
        type: 'future',
        severity: 'low',
        message: 'Thay đổi phân công cho ngày trong tương lai - không ảnh hưởng hoạt động hiện tại',
        requiresNotification: false
      }
    }

    if (newDate === today && this.isCurrentlyActive(currentAssignment)) {
      return {
        type: 'active_handover',
        severity: 'medium',
        message: 'Thay đổi phân công đang hoạt động - cần handover cho nhân viên',
        requiresNotification: true
      }
    }

    return {
      type: 'normal',
      severity: 'low',
      message: 'Cập nhật thông tin phân công',
      requiresNotification: false
    }
  }

  /**
   * Handle assignment changes based on impact analysis
   */
  static async handleAssignmentChange(
    assignmentId: string,
    changes: any,
    managerId?: string
  ): Promise<{ success: boolean; impact: ChangeImpact; data?: any }> {
    try {
      // Get current assignment
      const currentAssignment = await this.getAssignment(assignmentId)
      if (!currentAssignment) {
        throw new Error('Assignment not found')
      }

      // Analyze impact
      const impact = this.analyzeChangeImpact(currentAssignment, changes)

      // Handle different scenarios
      switch (impact.type) {
        case 'future':
          return await this.handleFutureChange(currentAssignment, changes, impact)
        case 'active_handover':
          return await this.handleActiveChange(currentAssignment, changes, impact, managerId)
        case 'normal':
          return await this.handleNormalChange(currentAssignment, changes, impact)
        default:
          throw new Error('Unknown change impact type')
      }
    } catch (error) {
      console.error('Error handling assignment change:', error)
      return {
        success: false,
        impact: {
          type: 'normal',
          severity: 'high',
          message: `Lỗi khi cập nhật phân công: ${error}`,
          requiresNotification: true
        }
      }
    }
  }

  /**
   * Handle future changes - simple update
   */
  private static async handleFutureChange(
    currentAssignment: Assignment,
    changes: any,
    impact: ChangeImpact
  ) {
    const { error } = await supabase
      .from('employee_shift_assignments')
      .update(changes)
      .eq('id', currentAssignment.id)

    if (error) throw error

    return {
      success: true,
      impact,
      data: { updatedAssignment: { ...currentAssignment, ...changes } }
    }
  }

  /**
   * Handle active changes - create handover
   */
  private static async handleActiveChange(
    currentAssignment: Assignment,
    changes: any,
    impact: ChangeImpact,
    managerId?: string
  ) {
    // Create handover record if employee changes
    if (changes.employee_profile_id && changes.employee_profile_id !== currentAssignment.employee_profile_id) {
      await this.createHandoverRecord({
        from_employee_id: currentAssignment.employee_profile_id,
        to_employee_id: changes.employee_profile_id,
        shift_id: currentAssignment.shift_id,
        assigned_date: currentAssignment.assigned_date,
        handover_time: new Date().toISOString(),
        reason: 'Manager initiated reassignment',
        manager_id: managerId
      })

      // Update handover count
      const { error: handoverError } = await supabase
        .from('employee_shift_assignments')
        .update({
          ...changes,
          last_handover_time: new Date().toISOString(),
          handover_count: (currentAssignment.handover_count || 0) + 1
        })
        .eq('id', currentAssignment.id)

      if (handoverError) throw handoverError

      // Notify both employees (this would integrate with your notification system)
      await this.notifyHandover(currentAssignment, changes.employee_profile_id)
    } else {
      // Simple update of other fields
      const { error } = await supabase
        .from('employee_shift_assignments')
        .update(changes)
        .eq('id', currentAssignment.id)

      if (error) throw error
    }

    return {
      success: true,
      impact,
      data: {
        updatedAssignment: { ...currentAssignment, ...changes },
        handoverCreated: changes.employee_profile_id !== currentAssignment.employee_profile_id
      }
    }
  }

  /**
   * Handle normal changes
   */
  private static async handleNormalChange(
    currentAssignment: Assignment,
    changes: any,
    impact: ChangeImpact
  ) {
    const { error } = await supabase
      .from('employee_shift_assignments')
      .update(changes)
      .eq('id', currentAssignment.id)

    if (error) throw error

    return {
      success: true,
      impact,
      data: { updatedAssignment: { ...currentAssignment, ...changes } }
    }
  }

  /**
   * Handle emergency reassignment when account fails
   */
  static async handleEmergencyReassignment(
    failedAccountId: string,
    failureReason: string,
    managerId?: string
  ): Promise<{ success: boolean; reassignedCount: number }> {
    try {
      // Get all assignments using the failed account
      const { data: affectedAssignments, error: fetchError } = await supabase
        .from('shift_account_access')
        .select(`
          *,
          employee_shift_assignments!inner(
            employee_profile_id,
            shift_id,
            assigned_date
          )
        `)
        .eq('game_account_id', failedAccountId)
        .eq('is_active', true)

      if (fetchError) throw fetchError

      let reassignedCount = 0

      for (const accessRecord of affectedAssignments) {
        const assignment = accessRecord.employee_shift_assignments

        // Find fallback account
        const fallbackAccount = await this.findAvailableFallbackAccount(
          assignment.shift_id,
          assignment.assigned_date
        )

        if (fallbackAccount) {
          // Execute emergency reassignment
          await this.emergencyReassignment(
            assignment,
            fallbackAccount,
            failureReason,
            managerId
          )
          reassignedCount++
        }
      }

      // Alert admin about emergency reassignments
      if (reassignedCount > 0) {
        await this.alertEmergencyReassignment(failedAccountId, failureReason, reassignedCount)
      }

      return { success: true, reassignedCount }
    } catch (error) {
      console.error('Error handling emergency reassignment:', error)
      return { success: false, reassignedCount: 0 }
    }
  }

  /**
   * Find available fallback account
   */
  private static async findAvailableFallbackAccount(shiftId: string, date: string): Promise<string | null> {
    try {
      // Get all accounts assigned to this shift that are not currently used
      const { data: availableAccounts, error } = await supabase
        .from('shift_account_access')
        .select(`
          game_account_id,
          game_accounts!inner(account_name, game_code)
        `)
        .eq('shift_id', shiftId)
        .eq('is_active', true)

      if (error || !availableAccounts || availableAccounts.length === 0) {
        return null
      }

      // Get currently used accounts for this shift/date
      const { data: usedAccounts } = await supabase
        .from('shift_account_access')
        .select('game_account_id')
        .eq('shift_id', shiftId)
        .eq('assigned_date', date)
        .eq('is_active', true)

      const usedAccountIds = usedAccounts?.map(acc => acc.game_account_id) || []

      // Find first available account
      const availableAccount = availableAccounts.find(
        acc => !usedAccountIds.includes(acc.game_account_id)
      )

      return availableAccount?.game_account_id || null
    } catch (error) {
      console.error('Error finding fallback account:', error)
      return null
    }
  }

  /**
   * Execute emergency reassignment
   */
  private static async emergencyReassignment(
    assignment: any,
    newAccountId: string,
    reason: string,
    managerId?: string
  ) {
    // Update the shift_account_access record
    await supabase
      .from('shift_account_access')
      .update({
        game_account_id: newAccountId,
        notes: `Emergency reassignment: ${reason}`,
        updated_at: new Date().toISOString()
      })
      .eq('employee_profile_id', assignment.employee_profile_id)
      .eq('shift_id', assignment.shift_id)
      .eq('assigned_date', assignment.assigned_date)

    // Mark the employee assignment as having emergency reassignment
    await supabase
      .from('employee_shift_assignments')
      .update({
        is_fallback: true,
        fallback_reason: reason,
        fallback_time: new Date().toISOString()
      })
      .eq('id', assignment.id)
  }

  /**
   * Create handover record
   */
  private static async createHandoverRecord(record: HandoverRecord & { manager_id?: string }) {
    // This would insert into a handover_history table if created
    // For now, we can log it or store in assignment notes
    console.log('Handover record created:', record)

    // Update assignment with handover info
    await supabase
      .from('employee_shift_assignments')
      .update({
        last_handover_time: record.handover_time,
        handover_count: await this.getHandoverCount(record.employee_profile_id, record.shift_id) + 1
      })
      .eq('employee_profile_id', record.employee_profile_id)
      .eq('shift_id', record.shift_id)
      .eq('assigned_date', record.assigned_date)
  }

  /**
   * Get current handover count for employee/shift
   */
  private static async getHandoverCount(employeeId: string, shiftId: string): Promise<number> {
    const { data } = await supabase
      .from('employee_shift_assignments')
      .select('handover_count')
      .eq('employee_profile_id', employeeId)
      .eq('shift_id', shiftId)
      .single()

    return data?.handover_count || 0
  }

  /**
   * Notify handover to employees
   */
  private static async notifyHandover(oldAssignment: Assignment, newEmployeeId: string) {
    // This would integrate with your notification system
    console.log(`Handover notification: ${oldAssignment.employee_name} → ${newEmployeeId}`)
    // Implementation depends on your notification system (email, in-app, etc.)
  }

  /**
   * Alert admin about emergency reassignment
   */
  private static async alertEmergencyReassignment(
    failedAccountId: string,
    reason: string,
    reassignedCount: number
  ) {
    console.log(`EMERGENCY: Account ${failedAccountId} failed. Reason: ${reason}. Reassigned ${reassignedCount} assignments.`)
    // Implementation depends on your alert system
  }

  /**
   * Format assignment data
   */
  private static formatAssignment(data: any): Assignment {
    return {
      id: data.id,
      employee_profile_id: data.employee_profile_id,
      employee_name: data.profiles?.display_name || 'Unknown',
      shift_id: data.shift_id,
      shift_name: data.work_shifts?.name || 'Unknown',
      assigned_date: data.assigned_date,
      is_active: data.is_active,
      assigned_at: data.assigned_at,
      last_handover_time: data.last_handover_time,
      handover_count: data.handover_count || 0,
      backup_employee_id: data.backup_employee_id,
      is_fallback: data.is_fallback || false,
      fallback_reason: data.fallback_reason,
      fallback_time: data.fallback_time
    }
  }

  /**
   * Get assignment by ID
   */
  static async getAssignment(assignmentId: string): Promise<Assignment | null> {
    try {
      const { data, error } = await supabase
        .from('employee_shift_assignments')
        .select(`
          *,
          profiles!employee_shift_assignments_employee_profile_id_fkey(display_name),
          work_shifts(name)
        `)
        .eq('id', assignmentId)
        .single()

      if (error || !data) return null
      return this.formatAssignment(data)
    } catch (error) {
      console.error('Error getting assignment:', error)
      return null
    }
  }
}