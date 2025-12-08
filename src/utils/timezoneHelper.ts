/**
 * Timezone helper utilities for GMT+7 (Vietnam timezone)
 * NOTE: Database timezone is already set to GMT+7, no conversion needed
 */

export const TIMEZONE_OFFSET = 7 // GMT+7 for Vietnam (legacy reference)

/**
 * Get current date in GMT+7 timezone
 * @returns Date object (database is already GMT+7)
 */
export function getGMT7Date(): Date {
  const now = new Date()
  // Database is already GMT+7, no conversion needed
  return now
}

/**
 * Get timestamp for current date in GMT+7 (start of day)
 * @returns number Timestamp for start of day (database is already GMT+7)
 */
export function getGMT7TodayTimestamp(): number {
  const gmt7Date = getGMT7Date()
  const gmt7Start = new Date(gmt7Date.getFullYear(), gmt7Date.getMonth(), gmt7Date.getDate(), 0, 0, 0, 0)
  return gmt7Start.getTime()
}

/**
 * Format date to YYYY-MM-DD string in GMT+7
 * @param date Date object or timestamp
 * @returns string Date string in YYYY-MM-DD format (database is already GMT+7)
 */
export function formatGMT7Date(date: Date | number): string {
  const targetDate = typeof date === 'number' ? new Date(date) : date

  // Database is already GMT+7, no conversion needed
  const gmt7Date = targetDate

  const year = gmt7Date.getFullYear()
  const month = String(gmt7Date.getMonth() + 1).padStart(2, '0')
  const day = String(gmt7Date.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

/**
 * Format date to Vietnamese locale string in GMT+7
 * @param date Date object or timestamp
 * @returns string Date string in Vietnamese format
 */
export function formatGMT7Vietnamese(date: Date | number | string): string {
  let targetDate: Date

  if (typeof date === 'number') {
    targetDate = new Date(date)
  } else if (typeof date === 'string') {
    // Handle string dates (YYYY-MM-DD format)
    if (date.match(/^\d{4}-\d{2}-\d{2}$/)) {
      // For date strings, treat as midnight GMT+7
      const [year, month, day] = date.split('-').map(Number)
      targetDate = new Date(year, month - 1, day)
    } else {
      targetDate = new Date(date)
    }
  } else {
    targetDate = date
  }

  // Check if date is valid
  if (isNaN(targetDate.getTime())) {
    return 'Invalid date'
  }

  // Database is already GMT+7, no conversion needed
  const gmt7Date = targetDate

  return gmt7Date.toLocaleDateString('vi-VN', {
    timeZone: 'Asia/Bangkok', // GMT+7 - preserve display formatting
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

/**
 * Convert timestamp to date object in GMT+7
 * @param timestamp Timestamp number
 * @returns Date Date object (database is already GMT+7)
 */
export function timestampToGMT7Date(timestamp: number): Date {
  // Database is already GMT+7, no conversion needed
  return new Date(timestamp)
}

/**
 * Create a date object in GMT+7 from year, month, day
 * @param year Year
 * @param month Month (1-12)
 * @param day Day (1-31)
 * @returns Date Date object (database is already GMT+7)
 */
export function createGMT7Date(year: number, month: number, day: number): Date {
  // Database is already GMT+7, no conversion needed
  return new Date(year, month - 1, day, 0, 0, 0, 0)
}