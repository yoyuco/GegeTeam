// path: src/utils/errorLogger.ts
interface ErrorContext {
  component?: string
  errorInfo?: string
  route?: string
  type?: string
  filename?: string
  lineno?: number
  colno?: number
  userId?: string
  [key: string]: unknown
}

interface LogEntry {
  timestamp: string
  level: 'error' | 'warning' | 'info'
  message: string
  stack?: string
  context?: ErrorContext
}

class ErrorLogger {
  private logs: LogEntry[] = []
  private maxLogs = 100
  private isDevelopment = import.meta.env.DEV

  log(error: Error | string | null | undefined, context?: ErrorContext): void {
    let message: string
    let stack: string | undefined

    if (error === null || error === undefined) {
      message = 'Unknown error (null or undefined)'
      stack = undefined
    } else if (typeof error === 'string') {
      message = error
      stack = undefined
    } else {
      message = error.message || 'Unknown error'
      stack = error.stack
    }

    const logEntry: LogEntry = {
      timestamp: new Date().toISOString(),
      level: 'error',
      message,
      stack,
      context,
    }

    this.addLog(logEntry)

    // Log to console in development
    if (this.isDevelopment) {
      console.error('ErrorLogger:', logEntry)
    }

    // Send to monitoring service (if available)
    this.sendToMonitoring(logEntry)
  }

  logWarning(message: string, context?: ErrorContext): void {
    const logEntry: LogEntry = {
      timestamp: new Date().toISOString(),
      level: 'warning',
      message,
      context,
    }

    this.addLog(logEntry)

    if (this.isDevelopment) {
      console.warn('ErrorLogger:', logEntry)
    }
  }

  logInfo(message: string, context?: ErrorContext): void {
    const logEntry: LogEntry = {
      timestamp: new Date().toISOString(),
      level: 'info',
      message,
      context,
    }

    this.addLog(logEntry)

    if (this.isDevelopment) {
      console.info('ErrorLogger:', logEntry)
    }
  }

  private addLog(logEntry: LogEntry): void {
    this.logs.push(logEntry)

    // Keep only the last maxLogs entries
    if (this.logs.length > this.maxLogs) {
      this.logs = this.logs.slice(-this.maxLogs)
    }
  }

  private sendToMonitoring(logEntry: LogEntry): void {
    // In production, you would send this to a monitoring service
    // like Sentry, LogRocket, Datadog, etc.
    if (!this.isDevelopment && typeof window !== 'undefined' && window.fetch) {
      window
        .fetch('/api/logs', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(logEntry),
        })
        .catch((err) => {
          console.error('Failed to send error to monitoring:', err)
        })
    }
  }

  getLogs(): LogEntry[] {
    return [...this.logs]
  }

  clearLogs(): void {
    this.logs = []
  }

  getErrorSummary(): { total: number; errors: number; warnings: number; info: number } {
    const summary = {
      total: this.logs.length,
      errors: 0,
      warnings: 0,
      info: 0,
    }

    for (const log of this.logs) {
      if (log.level === 'error') summary.errors++
      else if (log.level === 'warning') summary.warnings++
      else if (log.level === 'info') summary.info++
    }

    return summary
  }
}

// Create global instance
export const errorLogger = new ErrorLogger()

// Extend Window interface
declare global {
  interface Window {
    $errorLogger: ErrorLogger
  }
}

// Make available globally
if (typeof window !== 'undefined') {
  window.$errorLogger = errorLogger
}

export default errorLogger
