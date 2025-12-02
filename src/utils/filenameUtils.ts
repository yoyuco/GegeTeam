/**
 * Utility functions for filename sanitization and handling
 */

// Helper function to sanitize filenames (remove spaces, special characters)
export const sanitizeFilename = (filename: string) => {
  return filename
    .trim()
    .replace(/\s+/g, '_')      // Replace spaces with underscores
    .replace(/[^\w.-]/g, '')  // Remove special characters except dots and dashes
    .replace(/\.+/g, '.')      // Replace multiple dots with single dot
    .toLowerCase()
}

// Helper function to create unique filename with timestamp and sanitized original name
export const createUniqueFilename = (originalFilename: string) => {
  const timestamp = Date.now()
  const randomString = Math.random().toString(36).substring(2, 8)
  const sanitizedOriginalName = sanitizeFilename(originalFilename)
  return `${timestamp}-${randomString}-${sanitizedOriginalName}`
}

// Helper function to generate unique ID (for other uses)
export const generateId = () => {
  return `file_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`
}