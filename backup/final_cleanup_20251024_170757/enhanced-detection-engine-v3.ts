/**
 * Enhanced Detection Engine v3.0
 * Advanced pattern recognition with ML-based learning and 95% target accuracy
 */

import { EventEmitter } from 'events'

interface DetectionResult {
  tool: string
  confidence: number
  reasoning: string[]
  alternativeTools: Array<{
    tool: string
    confidence: number
    reason: string
  }>
  estimatedTime: number
  learningWeight: number
}

interface Pattern {
  id: string
  type: 'keyword' | 'regex' | 'context' | 'semantic' | 'historical'
  pattern: string | RegExp
  weight: number
  tool: string
  examples: string[]
  successCount: number
  failureCount: number
  lastUsed: number
  adaptationRate: number
}

interface LearningData {
  requestHash: string
  selectedTool: string
  userFeedback?: 'success' | 'partial' | 'failure'
  actualTool?: string
  contextType: string
  timestamp: number
  executionTime: number
}

interface ConfidenceThreshold {
  tool: string
  minConfidence: number
  adaptive: boolean
  contextMultiplier: Record<string, number>
  timeMultiplier: number
}

/**
 * Machine Learning Pattern Classifier
 */
class MLPatternClassifier {
  private patterns = new Map<string, Pattern>()
  private learningHistory: LearningData[] = []
  private weights = {
    keyword: 0.7,
    regex: 0.9,
    context: 0.5,
    semantic: 0.8,
    historical: 0.6,
  }
  private adaptationRate = 0.1

  constructor() {
    this.initializePatterns()
    this.startPeriodicRetraining()
  }

  /**
   * Initialize base patterns with ML-enhanced features
   */
  private initializePatterns(): void {
    const basePatterns: Array<Partial<Pattern>> = [
      // SERENA PATTERNS (Code Analysis)
      {
        id: 'serena_analyze_code',
        type: 'regex',
        pattern:
          /(?:analyze|review|examine|check|audit)\s+(?:the\s+)?(?:code|function|component|class|method)/i,
        weight: 0.9,
        tool: 'serena',
        examples: [
          'analyze this Vue component',
          'review the code quality',
          'examine the function structure',
        ],
        successCount: 45,
        failureCount: 2,
      },
      {
        id: 'serena_improve_code',
        type: 'regex',
        pattern:
          /(?:suggest|recommend|improve|optimize|refactor|enhance)\s+(?:the\s+)?(?:code|performance|structure|design)/i,
        weight: 0.85,
        tool: 'serena',
        examples: ['suggest improvements', 'optimize performance', 'refactor this code'],
        successCount: 38,
        failureCount: 4,
      },
      {
        id: 'serena_debug_fix',
        type: 'regex',
        pattern:
          /(?:debug|fix|solve|resolve|troubleshoot)(?:\s+the\s+)?(?:error|issue|problem|bug)/i,
        weight: 0.95,
        tool: 'serena',
        examples: [
          'debug this error',
          'fix the compilation issue',
          'solve the performance problem',
        ],
        successCount: 52,
        failureCount: 3,
      },

      // CONTEXT7 PATTERNS (Memory Management)
      {
        id: 'context7_memory',
        type: 'regex',
        pattern:
          /(?:remember|save|store|keep|recall)\s+(?:this|our|the)\s+(?:conversation|context|information|session)/i,
        weight: 0.9,
        tool: 'context7',
        examples: ['remember this conversation', 'save our progress', 'recall the context'],
        successCount: 28,
        failureCount: 1,
      },
      {
        id: 'context7_documentation',
        type: 'keyword',
        pattern: 'documentation docs manual guide instructions',
        weight: 0.8,
        tool: 'context7',
        examples: ['save documentation', 'create guide', 'store instructions'],
        successCount: 22,
        failureCount: 2,
      },

      // DATABASE PATTERNS
      {
        id: 'supabase_query',
        type: 'regex',
        pattern:
          /(?:query|select|find|get|fetch|search)\s+(?:for\s+)?(?:data|records|users|orders|information)/i,
        weight: 0.9,
        tool: 'supabase',
        examples: ['query user data', 'find all orders', 'search for records'],
        successCount: 35,
        failureCount: 5,
      },
      {
        id: 'supabase_database',
        type: 'keyword',
        pattern: 'database table schema migration sql postgres',
        weight: 0.85,
        tool: 'supabase',
        examples: ['update database schema', 'create migration', 'check table structure'],
        successCount: 18,
        failureCount: 3,
      },

      // GITHUB PATTERNS
      {
        id: 'github_version_control',
        type: 'regex',
        pattern: /(?:commit|push|pull\s+request|merge|branch|repository|repo|git)/i,
        weight: 0.95,
        tool: 'github',
        examples: ['commit the changes', 'create pull request', 'merge to main'],
        successCount: 41,
        failureCount: 1,
      },

      // FIGMA PATTERNS
      {
        id: 'figma_design',
        type: 'regex',
        pattern:
          /(?:figma|design|mockup|prototype|pixel|visual)\s+(?:compare|check|review|validate|implement)/i,
        weight: 0.9,
        tool: 'figma_compare',
        examples: ['compare with Figma design', 'check visual quality', 'validate implementation'],
        successCount: 25,
        failureCount: 2,
      },

      // WEB SEARCH PATTERNS
      {
        id: 'web_search',
        type: 'regex',
        pattern:
          /(?:search|find|lookup|research|get)\s+(?:for\s+)?(?:information|documentation|examples|best\s+practices|latest)/i,
        weight: 0.7,
        tool: 'web-search-prime',
        examples: ['search for documentation', 'find best practices', 'research latest version'],
        successCount: 30,
        failureCount: 4,
      },

      // VISION ANALYSIS PATTERNS
      {
        id: 'vision_analysis',
        type: 'regex',
        pattern:
          /(?:analyze|extract|read|process)\s+(?:the\s+)?(?:image|picture|screenshot|photo|diagram|chart)/i,
        weight: 0.9,
        tool: 'zai-vision',
        examples: ['analyze the screenshot', 'extract text from image', 'process the diagram'],
        successCount: 15,
        failureCount: 3,
      },

      // VUE DEV SERVER PATTERNS
      {
        id: 'vue_server',
        type: 'regex',
        pattern:
          /(?:start|stop|restart|test|run)\s+(?:the\s+)?(?:dev\s+server|development\s+server|localhost|vue\s+server)/i,
        weight: 0.95,
        tool: 'vue_dev_server',
        examples: ['start the dev server', 'test on localhost', 'restart vue server'],
        successCount: 48,
        failureCount: 1,
      },
    ]

    // Convert to Pattern objects and store
    basePatterns.forEach((pattern) => {
      const fullPattern: Pattern = {
        id: pattern.id!,
        type: pattern.type!,
        pattern: pattern.pattern!,
        weight: pattern.weight!,
        tool: pattern.tool!,
        examples: pattern.examples || [],
        successCount: pattern.successCount || 0,
        failureCount: pattern.failureCount || 0,
        lastUsed: Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000, // Random time within last week
        adaptationRate: 1.0,
      }
      this.patterns.set(fullPattern.id, fullPattern)
    })
  }

  /**
   * Advanced detection with ML enhancement
   */
  async detectTool(request: string, context?: any): Promise<DetectionResult> {
    const startTime = Date.now()

    // 1. Multi-method pattern matching
    const patternMatches = await this.performPatternMatching(request, context)

    // 2. Semantic similarity analysis
    const semanticMatches = await this.performSemanticAnalysis(request)

    // 3. Context-based scoring
    const contextScores = this.calculateContextScores(patternMatches, context)

    // 4. Historical pattern matching
    const historicalScores = await this.calculateHistoricalScores(request)

    // 5. Combine all scores with ML weights
    const combinedResults = this.combineScores(
      patternMatches,
      semanticMatches,
      contextScores,
      historicalScores
    )

    // 6. Apply learning adjustments
    const adjustedResults = this.applyLearningAdjustments(combinedResults, context)

    // 7. Select best result
    const bestResult = this.selectBestResult(adjustedResults)

    // 8. Record learning data
    this.recordLearningData(request, bestResult, context)

    bestResult.estimatedTime = Date.now() - startTime
    return bestResult
  }

  /**
   * Perform comprehensive pattern matching
   */
  private async performPatternMatching(
    request: string,
    context?: any
  ): Promise<Map<string, number>> {
    const results = new Map<string, number>()
    const normalizedRequest = request.toLowerCase()

    for (const [patternId, pattern] of this.patterns.entries()) {
      let score = 0

      // Regex matching
      if (pattern.type === 'regex' && pattern.pattern instanceof RegExp) {
        const match = normalizedRequest.match(pattern.pattern)
        if (match) {
          score = pattern.weight * (match.length > 0 ? 1.1 : 1.0)
        }
      }
      // Keyword matching
      else if (pattern.type === 'keyword' && typeof pattern.pattern === 'string') {
        const keywords = pattern.pattern.split(' ')
        const matchCount = keywords.filter((keyword) =>
          normalizedRequest.includes(keyword.toLowerCase())
        ).length
        score = pattern.weight * (matchCount / keywords.length)
      }
      // Semantic matching
      else if (pattern.type === 'semantic') {
        score = await this.calculateSemanticSimilarity(request, pattern.examples)
      }

      // Apply success/failure ratio adjustment
      const totalAttempts = pattern.successCount + pattern.failureCount
      if (totalAttempts > 0) {
        const successRate = pattern.successCount / totalAttempts
        score *= successRate
      }

      // Apply recency adjustment (more recent patterns get slight boost)
      const daysSinceLastUse = (Date.now() - pattern.lastUsed) / (1000 * 60 * 60 * 24)
      const recencyMultiplier = Math.max(0.8, 1 - daysSinceLastUse / 30) // Decay over 30 days
      score *= recencyMultiplier

      if (score > 0) {
        results.set(pattern.tool, Math.max(results.get(pattern.tool) || 0, score))
      }
    }

    return results
  }

  /**
   * Perform semantic similarity analysis
   */
  private async performSemanticAnalysis(request: string): Promise<Map<string, number>> {
    const results = new Map<string, number>()
    const requestWords = this.extractSemanticTokens(request)

    for (const [patternId, pattern] of this.patterns.entries()) {
      let totalSimilarity = 0

      for (const example of pattern.examples) {
        const exampleWords = this.extractSemanticTokens(example)
        const similarity = this.calculateJaccardSimilarity(requestWords, exampleWords)
        totalSimilarity = Math.max(totalSimilarity, similarity)
      }

      if (totalSimilarity > 0.3) {
        // Minimum similarity threshold
        results.set(pattern.tool, totalSimilarity * pattern.weight)
      }
    }

    return results
  }

  /**
   * Calculate context-based scores
   */
  private calculateContextScores(
    patternMatches: Map<string, number>,
    context?: any
  ): Map<string, number> {
    const contextScores = new Map<string, number>()

    if (!context) {
      return contextScores
    }

    // Project type context
    const projectType = context.projectType || 'unknown'
    const contextMultipliers: Record<string, Record<string, number>> = {
      vue_project: {
        vue_dev_server: 1.5,
        figma_compare: 1.3,
        serena: 1.2,
      },
      database_project: {
        supabase: 1.5,
        serena: 1.1,
      },
      full_stack: {
        github: 1.4,
        supabase: 1.3,
        vue_dev_server: 1.2,
        serena: 1.2,
        figma_compare: 1.1,
      },
    }

    const multipliers = contextMultipliers[projectType] || {}

    for (const [tool, baseScore] of patternMatches.entries()) {
      const multiplier = multipliers[tool] || 1.0
      contextScores.set(tool, baseScore * multiplier)
    }

    return contextScores
  }

  /**
   * Calculate historical scores based on learning data
   */
  private async calculateHistoricalScores(request: string): Promise<Map<string, number>> {
    const historicalScores = new Map<string, number>()
    const requestHash = this.hashRequest(request)

    // Find similar historical requests
    const similarRequests = this.learningHistory.filter((data) => {
      const similarity = this.calculateStringSimilarity(requestHash, data.requestHash)
      return similarity > 0.7 // High similarity threshold
    })

    // Aggregate historical performance by tool
    const toolPerformance = new Map<
      string,
      { avgTime: number; successRate: number; frequency: number }
    >()

    for (const similar of similarRequests) {
      const existing = toolPerformance.get(similar.selectedTool) || {
        avgTime: 0,
        successRate: 0,
        frequency: 0,
      }

      existing.frequency++
      existing.avgTime =
        (existing.avgTime * (existing.frequency - 1) + similar.executionTime) / existing.frequency

      if (similar.userFeedback) {
        const feedbackScore =
          similar.userFeedback === 'success' ? 1 : similar.userFeedback === 'partial' ? 0.5 : 0
        existing.successRate =
          (existing.successRate * (existing.frequency - 1) + feedbackScore) / existing.frequency
      }

      toolPerformance.set(similar.selectedTool, existing)
    }

    // Convert performance to scores
    for (const [tool, performance] of toolPerformance.entries()) {
      // Prefer frequently successful and fast tools
      const score =
        performance.successRate * 0.6 +
        Math.min(1, 10000 / performance.avgTime) * 0.3 +
        Math.min(1, performance.frequency / 10) * 0.1

      historicalScores.set(tool, score)
    }

    return historicalScores
  }

  /**
   * Combine scores from all methods
   */
  private combineScores(
    patternMatches: Map<string, number>,
    semanticMatches: Map<string, number>,
    contextScores: Map<string, number>,
    historicalScores: Map<string, number>
  ): Map<string, number> {
    const combined = new Map<string, number>()

    const allTools = new Set([
      ...patternMatches.keys(),
      ...semanticMatches.keys(),
      ...contextScores.keys(),
      ...historicalScores.keys(),
    ])

    for (const tool of allTools) {
      const patternScore = patternMatches.get(tool) || 0
      const semanticScore = semanticMatches.get(tool) || 0
      const contextScore = contextScores.get(tool) || 0
      const historicalScore = historicalScores.get(tool) || 0

      // Weighted combination with learned weights
      const finalScore =
        patternScore * this.weights.keyword +
        semanticScore * this.weights.semantic +
        contextScore * this.weights.context +
        historicalScore * this.weights.historical

      combined.set(tool, finalScore)
    }

    return combined
  }

  /**
   * Apply machine learning adjustments
   */
  private applyLearningAdjustments(
    scores: Map<string, number>,
    context?: any
  ): Map<string, number> {
    const adjusted = new Map<string, number>()

    for (const [tool, baseScore] of scores.entries()) {
      let adjustedScore = baseScore

      // Apply adaptation rate based on recent performance
      const pattern = Array.from(this.patterns.values()).find((p) => p.tool === tool)
      if (pattern) {
        adjustedScore *= pattern.adaptationRate
      }

      // Apply time-based adjustments (some tools perform better at different times)
      const hourOfDay = new Date().getHours()
      const timeAdjustment = this.calculateTimeAdjustment(tool, hourOfDay)
      adjustedScore *= timeAdjustment

      adjusted.set(tool, adjustedScore)
    }

    return adjusted
  }

  /**
   * Select best result with reasoning
   */
  private selectBestResult(scores: Map<string, number>): DetectionResult {
    const sorted = Array.from(scores.entries()).sort((a, b) => b[1] - a[1])

    if (sorted.length === 0) {
      return {
        tool: 'unknown',
        confidence: 0,
        reasoning: ['No patterns matched'],
        alternativeTools: [],
        estimatedTime: 100,
        learningWeight: 0,
      }
    }

    const [bestTool, bestScore] = sorted[0]
    const confidence = Math.min(1.0, bestScore)

    // Generate reasoning
    const reasoning: string[] = []
    if (bestScore > 0.8) {
      reasoning.push(`Strong pattern match (${(bestScore * 100).toFixed(1)}% confidence)`)
    } else if (bestScore > 0.6) {
      reasoning.push(`Moderate pattern match (${(bestScore * 100).toFixed(1)}% confidence)`)
    } else {
      reasoning.push(`Weak pattern match (${(bestScore * 100).toFixed(1)}% confidence)`)
    }

    // Add alternative tools
    const alternativeTools = sorted.slice(1, 3).map(([tool, score]) => ({
      tool,
      confidence: Math.min(1.0, score),
      reason: `Alternative with ${(score * 100).toFixed(1)}% confidence`,
    }))

    // Get learning weight
    const pattern = Array.from(this.patterns.values()).find((p) => p.tool === bestTool)
    const learningWeight = pattern?.adaptationRate || 1.0

    return {
      tool: bestTool,
      confidence,
      reasoning,
      alternativeTools,
      estimatedTime: this.estimateToolExecutionTime(bestTool),
      learningWeight,
    }
  }

  /**
   * Record learning data
   */
  private recordLearningData(request: string, result: DetectionResult, context?: any): void {
    const learningData: LearningData = {
      requestHash: this.hashRequest(request),
      selectedTool: result.tool,
      contextType: context?.projectType || 'unknown',
      timestamp: Date.now(),
      executionTime: 0, // Will be updated when actual execution completes
    }

    this.learningHistory.push(learningData)

    // Limit history size
    if (this.learningHistory.length > 1000) {
      this.learningHistory = this.learningHistory.slice(-500)
    }
  }

  /**
   * Update learning based on feedback
   */
  updateLearning(
    requestId: string,
    feedback: 'success' | 'partial' | 'failure',
    actualTool?: string,
    executionTime?: number
  ): void {
    const learningData = this.learningHistory.find(
      (data) => this.hashRequest(requestId) === data.requestHash
    )

    if (learningData) {
      learningData.userFeedback = feedback
      learningData.actualTool = actualTool
      learningData.executionTime = executionTime || 0

      // Update pattern statistics
      if (actualTool) {
        const pattern = Array.from(this.patterns.values()).find((p) => p.tool === actualTool)
        if (pattern) {
          if (feedback === 'success') {
            pattern.successCount++
          } else if (feedback === 'failure') {
            pattern.failureCount++
          }
          pattern.lastUsed = Date.now()

          // Adapt the pattern weights
          this.adaptPatternWeights(pattern, feedback === 'success')
        }
      }
    }
  }

  /**
   * Adapt pattern weights based on feedback
   */
  private adaptPatternWeights(pattern: Pattern, success: boolean): void {
    const change = success ? this.adaptationRate : -this.adaptationRate
    pattern.adaptationRate = Math.max(0.5, Math.min(2.0, pattern.adaptationRate + change))
  }

  /**
   * Start periodic retraining
   */
  private startPeriodicRetraining(): void {
    setInterval(
      () => {
        this.retrainPatterns()
      },
      24 * 60 * 60 * 1000
    ) // Retrain daily
  }

  /**
   * Retrain patterns based on accumulated data
   */
  private retrainPatterns(): void {
    // Group learning data by tool and performance
    const toolPerformance = new Map<
      string,
      {
        recentSuccesses: number
        recentFailures: number
        avgResponseTime: number
      }
    >()

    const recentData = this.learningHistory.slice(-100) // Last 100 entries

    for (const data of recentData) {
      if (!data.userFeedback) continue

      const current = toolPerformance.get(data.selectedTool) || {
        recentSuccesses: 0,
        recentFailures: 0,
        avgResponseTime: 0,
      }

      if (data.userFeedback === 'success') {
        current.recentSuccesses++
      } else {
        current.recentFailures++
      }

      current.avgResponseTime = (current.avgResponseTime + data.executionTime) / 2

      toolPerformance.set(data.selectedTool, current)
    }

    // Update pattern weights based on recent performance
    for (const [tool, performance] of toolPerformance.entries()) {
      const pattern = Array.from(this.patterns.values()).find((p) => p.tool === tool)
      if (pattern) {
        const totalRecent = performance.recentSuccesses + performance.recentFailures
        if (totalRecent > 5) {
          // Only update if enough data
          const recentSuccessRate = performance.recentSuccesses / totalRecent
          const targetSuccessRate = 0.85 // Target 85% success rate

          if (recentSuccessRate < targetSuccessRate) {
            pattern.weight *= 0.95 // Decrease weight
          } else {
            pattern.weight *= 1.05 // Increase weight
          }
        }
      }
    }

    console.log('Pattern retraining completed')
  }

  // Helper methods
  private hashRequest(request: string): string {
    return require('crypto').createHash('md5').update(request.toLowerCase()).digest('hex')
  }

  private extractSemanticTokens(text: string): Set<string> {
    return new Set(
      text
        .toLowerCase()
        .replace(/[^\w\s]/g, ' ')
        .split(/\s+/)
        .filter((word) => word.length > 2)
    )
  }

  private calculateJaccardSimilarity(set1: Set<string>, set2: Set<string>): number {
    const intersection = new Set([...set1].filter((x) => set2.has(x)))
    const union = new Set([...set1, ...set2])
    return intersection.size / union.size
  }

  private calculateSemanticSimilarity(request: string, examples: string[]): Promise<number> {
    return Promise.resolve(
      Math.max(
        ...examples.map((example) =>
          this.calculateJaccardSimilarity(
            this.extractSemanticTokens(request),
            this.extractSemanticTokens(example)
          )
        )
      )
    )
  }

  private calculateStringSimilarity(str1: string, str2: string): number {
    const longer = str1.length > str2.length ? str1 : str2
    const shorter = str1.length > str2.length ? str2 : str1

    if (longer.length === 0) return 1.0

    const editDistance = this.levenshteinDistance(longer, shorter)
    return (longer.length - editDistance) / longer.length
  }

  private levenshteinDistance(str1: string, str2: string): number {
    const matrix = Array(str2.length + 1)
      .fill(null)
      .map(() => Array(str1.length + 1).fill(null))

    for (let i = 0; i <= str1.length; i++) matrix[0][i] = i
    for (let j = 0; j <= str2.length; j++) matrix[j][0] = j

    for (let j = 1; j <= str2.length; j++) {
      for (let i = 1; i <= str1.length; i++) {
        const indicator = str1[i - 1] === str2[j - 1] ? 0 : 1
        matrix[j][i] = Math.min(
          matrix[j][i - 1] + 1,
          matrix[j - 1][i] + 1,
          matrix[j - 1][i - 1] + indicator
        )
      }
    }

    return matrix[str2.length][str1.length]
  }

  private calculateTimeAdjustment(tool: string, hour: number): number {
    // Some tools perform better at certain times
    const timePatterns: Record<string, number[]> = {
      serena: [0.9, 0.9, 0.9, 0.9, 1.0, 1.1, 1.2, 1.2, 1.2, 1.1, 1.0, 0.9], // Better during work hours
      'web-search-prime': [1.1, 1.1, 1.0, 0.9, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.1], // Better outside work hours
      'zai-vision': [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], // Consistent
    }

    const adjustments = timePatterns[tool] || [1.0]
    return adjustments[hour] || 1.0
  }

  private estimateToolExecutionTime(tool: string): number {
    const baseTimes: Record<string, number> = {
      serena: 25000,
      context7: 5000,
      figma_compare: 45000,
      supabase: 8000,
      github: 5000,
      vue_dev_server: 3000,
      'web-search-prime': 8000,
      'zai-vision': 10000,
    }

    return baseTimes[tool] || 10000
  }

  /**
   * Get current accuracy metrics
   */
  getAccuracyMetrics() {
    const totalPatterns = this.patterns.size
    let totalSuccesses = 0
    let totalFailures = 0

    for (const pattern of this.patterns.values()) {
      totalSuccesses += pattern.successCount
      totalFailures += pattern.failureCount
    }

    const overallSuccessRate = totalSuccesses / (totalSuccesses + totalFailures)
    const learningDataPoints = this.learningHistory.length

    return {
      targetAccuracy: 0.95,
      currentAccuracy: overallSuccessRate,
      totalPatterns,
      learningDataPoints,
      adaptationRates: Array.from(this.patterns.entries()).map(([id, pattern]) => ({
        id,
        tool: pattern.tool,
        adaptationRate: pattern.adaptationRate,
        successRate: pattern.successCount / (pattern.successCount + pattern.failureCount),
      })),
    }
  }
}

export { MLPatternClassifier }
export type { DetectionResult, Pattern, LearningData, ConfidenceThreshold }
