/**
 * Utility functions for handling work shifts, including overnight shift logic
 */

/**
 * Check if a shift is overnight (ends on the next day)
 * @param startTime Start time in "HH:mm:ss" format
 * @param endTime End time in "HH:mm:ss" format
 * @returns true if the shift is overnight
 */
export const isOvernightShift = (startTime: string, endTime: string): boolean => {
  const [startHour] = startTime.split(':').map(Number)
  const [endHour] = endTime.split(':').map(Number)
  return endHour < startHour
}

/**
 * Format shift time display with overnight indicator
 * @param startTime Start time in "HH:mm:ss" format
 * @param endTime End time in "HH:mm:ss" format
 * @returns Formatted time string, e.g., "20:00:00 - 08:00:00 (qua đêm)"
 */
export const formatShiftTime = (startTime: string, endTime: string): string => {
  const overnight = isOvernightShift(startTime, endTime)
  const timeStr = `${startTime} - ${endTime}`
  return overnight ? `${timeStr} (qua đêm)` : timeStr
}

/**
 * Calculate shift duration in hours
 * @param startTime Start time in "HH:mm:ss" format
 * @param endTime End time in "HH:mm:ss" format
 * @returns Duration in hours (can be decimal)
 */
export const calculateShiftDuration = (startTime: string, endTime: string): number => {
  const [startHour, startMin] = startTime.split(':').map(Number)
  const [endHour, endMin] = endTime.split(':').map(Number)

  const startMinutes = startHour * 60 + startMin
  let endMinutes = endHour * 60 + endMin

  // If overnight, add 24 hours (1440 minutes) to end time
  if (endMinutes < startMinutes) {
    endMinutes += 1440
  }

  return (endMinutes - startMinutes) / 60 // Return duration in hours
}

/**
 * Get human-readable shift duration description
 * @param startTime Start time in "HH:mm:ss" format
 * @param endTime End time in "HH:mm:ss" format
 * @returns Duration description, e.g., "8 giờ", "7 giờ 30 phút"
 */
export const getShiftDurationDescription = (startTime: string, endTime: string): string => {
  const duration = calculateShiftDuration(startTime, endTime)
  const hours = Math.floor(duration)
  const minutes = Math.round((duration - hours) * 60)

  if (minutes === 0) {
    return `${hours} giờ`
  } else {
    return `${hours} giờ ${minutes} phút`
  }
}

/**
 * Check if a specific datetime falls within a shift
 * @param checkTime Date to check
 * @param shiftStartTime Shift start time in "HH:mm:ss" format
 * @param shiftEndTime Shift end time in "HH:mm:ss" format
 * @returns true if the checkTime is within the shift
 */
export const isTimeInShift = (
  checkTime: Date,
  shiftStartTime: string,
  shiftEndTime: string
): boolean => {
  const [startHour, startMin] = shiftStartTime.split(':').map(Number)
  const [endHour, endMin] = shiftEndTime.split(':').map(Number)

  const checkMinutes = checkTime.getHours() * 60 + checkTime.getMinutes()
  const startMinutes = startHour * 60 + startMin
  let endMinutes = endHour * 60 + endMin

  // If overnight shift, adjust end time
  if (isOvernightShift(shiftStartTime, shiftEndTime)) {
    endMinutes += 1440 // Add 24 hours
    if (checkMinutes < startMinutes) {
      // Check time is after midnight, add 24 hours to compare correctly
      const adjustedCheckMinutes = checkMinutes + 1440
      return adjustedCheckMinutes >= startMinutes && adjustedCheckMinutes < endMinutes
    }
  }

  return checkMinutes >= startMinutes && checkMinutes < endMinutes
}

/**
 * Get shift information for a specific date and shift
 * @param date Base date
 * @param shiftStartTime Shift start time in "HH:mm:ss" format
 * @param shiftEndTime Shift end time in "HH:mm:ss" format
 * @returns Object with start and end Date objects for the shift
 */
export const getShiftDateTimeRange = (
  date: Date,
  shiftStartTime: string,
  shiftEndTime: string
): { start: Date; end: Date } => {
  const [startHour, startMin] = shiftStartTime.split(':').map(Number)
  const [endHour, endMin] = shiftEndTime.split(':').map(Number)

  const startDate = new Date(date)
  startDate.setHours(startHour, startMin, 0, 0)

  const endDate = new Date(date)
  endDate.setHours(endHour, endMin, 0, 0)

  // If overnight shift and end time is earlier than start time, move end date to next day
  if (isOvernightShift(shiftStartTime, shiftEndTime) && endDate < startDate) {
    endDate.setDate(endDate.getDate() + 1)
  }

  return { start: startDate, end: endDate }
}