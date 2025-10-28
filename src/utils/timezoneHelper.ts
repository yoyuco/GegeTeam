/**
 * Timezone helper utilities for GMT+7 (Vietnam timezone)
 */

export const TIMEZONE_OFFSET = 7 // GMT+7 for Vietnam

/**
 * Get current date in GMT+7 timezone
 * @returns Date object adjusted to GMT+7
 */
export function getGMT7Date(): Date {
  const now = new Date()
  // Convert to GMT+7
  const utcTime = now.getTime() + (now.getTimezoneOffset() * 60000)
  return new Date(utcTime + (TIMEZONE_OFFSET * 3600000))
}

/**
 * Get timestamp for current date in GMT+7 (start of day)
 * @returns number Timestamp for GMT+7 start of day
 */
export function getGMT7TodayTimestamp(): number {
  const gmt7Date = getGMT7Date()
  const gmt7Start = new Date(gmt7Date.getFullYear(), gmt7Date.getMonth(), gmt7Date.getDate(), 0, 0, 0, 0)
  return gmt7Start.getTime()
}

/**
 * Format date to YYYY-MM-DD string in GMT+7
 * @param date Date object or timestamp
 * @returns string Date string in YYYY-MM-DD format (GMT+7)
 */
export function formatGMT7Date(date: Date | number): string {
  const targetDate = typeof date === 'number' ? new Date(date) : date

  // Convert to GMT+7
  const utcTime = targetDate.getTime() + (targetDate.getTimezoneOffset() * 60000)
  const gmt7Date = new Date(utcTime + (TIMEZONE_OFFSET * 3600000))

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
export function formatGMT7Vietnamese(date: Date | number): string {
  const targetDate = typeof date === 'number' ? new Date(date) : date

  // Convert to GMT+7
  const utcTime = targetDate.getTime() + (targetDate.getTimezoneOffset() * 60000)
  const gmt7Date = new Date(utcTime + (TIMEZONE_OFFSET * 3600000))

  return gmt7Date.toLocaleDateString('vi-VN', {
    timeZone: 'Asia/Bangkok', // GMT+7
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

/**
 * Convert timestamp to date object in GMT+7
 * @param timestamp Timestamp number
 * @returns Date Date object in GMT+7
 */
export function timestampToGMT7Date(timestamp: number): Date {
  const date = new Date(timestamp)
  const utcTime = date.getTime() + (date.getTimezoneOffset() * 60000)
  return new Date(utcTime + (TIMEZONE_OFFSET * 3600000))
}

/**
 * Create a date object in GMT+7 from year, month, day
 * @param year Year
 * @param month Month (1-12)
 * @param day Day (1-31)
 * @returns Date Date object in GMT+7
 */
export function createGMT7Date(year: number, month: number, day: number): Date {
  // Create date in local timezone first
  const localDate = new Date(year, month - 1, day, 0, 0, 0, 0)
  // Convert to GMT+7
  const utcTime = localDate.getTime() - (TIMEZONE_OFFSET * 3600000)
  return new Date(utcTime)
}