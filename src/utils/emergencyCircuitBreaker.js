// Emergency Circuit Breaker
// Prevents request storms and infinite loops by implementing circuit breaker pattern
export class EmergencyCircuitBreaker {
  constructor(options = {}) {
    this.name = options.name || 'default'
    this.maxFailures = options.maxFailures || 5
    this.timeoutMs = options.timeoutMs || 60000 // 1 minute
    this.resetAfterMs = options.resetAfterMs || 300000 // 5 minutes

    this.state = 'CLOSED' // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0
    this.lastFailureTime = null
    this.successCount = 0
    this.halfOpenSuccessThreshold = 3

    this.onOpen =
      options.onOpen ||
      (() => console.error(`🚨 CIRCUIT BREAKER OPEN [${this.name}]: Too many failures`))
    this.onClose =
      options.onClose ||
      (() => console.log(`✅ CIRCUIT BREAKER CLOSED [${this.name}]: Circuit closed`))
    this.onHalfOpen =
      options.onHalfOpen ||
      (() => console.warn(`⚡ CIRCUIT BREAKER HALF-OPEN [${this.name}]: Testing connection`))
  }

  async execute(operation, context = {}) {
    // If circuit is OPEN, check if timeout has passed
    if (this.state === 'OPEN') {
      const now = Date.now()
      if (now - this.lastFailureTime > this.timeoutMs) {
        this.toHalfOpen()
      } else {
        throw new Error(
          `Circuit breaker [${this.name}] is OPEN. Error: Too many failures. Try again in ${Math.ceil((this.timeoutMs - (now - this.lastFailureTime)) / 1000)}s`
        )
      }
    }

    // If circuit is HALF-OPEN, allow only limited requests
    if (this.state === 'HALF_OPEN') {
      if (Math.random() > 0.5) {
        // 50% chance
        throw new Error(
          `Circuit breaker [${this.name}] is HALF-OPEN. Rejecting request to test circuit`
        )
      }
    }

    try {
      // Execute the operation
      const result = await operation(context)

      // Success: reset failure count and close circuit if needed
      this.onSuccess()

      return result
    } catch (error) {
      // Failure: increment failure count and potentially open circuit
      this.onFailure(error)

      throw error
    }
  }

  onSuccess() {
    this.failureCount = 0
    this.lastFailureTime = null
    this.successCount++

    // If in HALF-OPEN state and enough successes, close circuit
    if (this.state === 'HALF_OPEN' && this.successCount >= this.halfOpenSuccessThreshold) {
      this.toClosed()
    }
  }

  onFailure() {
    this.failureCount++
    this.lastFailureTime = Date.now()
    this.successCount = 0

    // If failure count exceeds threshold, open circuit
    if (this.failureCount >= this.maxFailures) {
      this.toOpen()
    }
  }

  toOpen() {
    this.state = 'OPEN'
    console.error(
      `🚨🚨🚨 CIRCUIT BREAKER OPEN [${this.name}]: ${this.failureCount} failures detected`
    )

    // Schedule automatic reset
    setTimeout(() => {
      console.log(
        `🔄 Circuit breaker [${this.name}] attempting auto-reset after ${this.timeoutMs / 1000}s timeout`
      )
      this.toHalfOpen()
    }, this.timeoutMs)

    if (this.onOpen) {
      this.onOpen()
    }
  }

  toHalfOpen() {
    this.state = 'HALF_OPEN'
    this.successCount = 0
    console.warn(
      `⚡ Circuit breaker [${this.name}] is HALF-OPEN: Testing connection with limited requests`
    )

    if (this.onHalfOpen) {
      this.onHalfOpen()
    }
  }

  toClosed() {
    this.state = 'CLOSED'
    this.failureCount = 0
    this.lastFailureTime = null
    this.successCount = 0
    console.log(`✅ Circuit breaker [${this.name}] is CLOSED: Circuit functioning normally`)

    if (this.onClose) {
      this.onClose()
    }
  }

  forceOpen(reason = 'Manual intervention') {
    console.warn(`⚠️ Circuit breaker [${this.name}] manually OPENED: ${reason}`)
    this.state = 'OPEN'
    this.lastFailureTime = Date.now()

    if (this.onOpen) {
      this.onOpen()
    }
  }

  forceClose() {
    console.log(`🔧 Circuit breaker [${this.name}] manually CLOSED`)
    this.toClosed()
  }

  getState() {
    return {
      state: this.state,
      failureCount: this.failureCount,
      successCount: this.successCount,
      lastFailureTime: this.lastFailureTime,
      timeUntilReset:
        this.state === 'OPEN'
          ? Math.max(0, this.timeoutMs - (Date.now() - this.lastFailureTime))
          : 0,
    }
  }

  reset() {
    this.toClosed()
  }
}

// Create circuit breaker for API requests
export const createApiCircuitBreaker = () => {
  return new EmergencyCircuitBreaker({
    name: 'API_REQUESTS',
    maxFailures: 5,
    timeoutMs: 60000, // 1 minute
    resetAfterMs: 300000, // 5 minutes
    onOpen: () => {
      // Send global error notification
      if (typeof window !== 'undefined') {
        globalThis.dispatchEvent(
          new CustomEvent('circuit-breaker-open', {
            detail: { message: 'API requests temporarily blocked due to repeated failures' },
          })
        )
      }
    },
    onClose: () => {
      // Send recovery notification
      if (typeof window !== 'undefined') {
        globalThis.dispatchEvent(
          new CustomEvent('circuit-breaker-close', {
            detail: { message: 'API requests恢复正常' },
          })
        )
      }
    },
  })
}

// Export singleton
export const apiCircuitBreaker = createApiCircuitBreaker()
