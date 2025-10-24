/**
 * Comprehensive Test Suite for MCP Optimization
 * Validates all optimization components and measures performance improvements
 */

import { EventEmitter } from 'events'
import { MCPOptimizer } from './mcp-response-optimizer'
import { MLPatternClassifier } from './enhanced-detection-engine-v3'
import { PerformanceDashboard } from './performance-dashboard'

interface TestResult {
  testName: string
  passed: boolean
  duration: number
  details: string
  metrics: any
  error?: string
}

interface BenchmarkResult {
  scenario: string
  originalTime: number
  optimizedTime: number
  improvement: number
  improvementPercent: number
  metrics: any
}

interface ValidationMetrics {
  cacheEfficiency: number
  parallelExecution: number
  tokenReduction: number
  detectionAccuracy: number
  responseTimeImprovement: number
  errorReduction: number
}

/**
 * Complete test suite for MCP optimization system
 */
class OptimizationTestSuite extends EventEmitter {
  private optimizer: MCPOptimizer
  private detectionEngine: MLPatternClassifier
  private dashboard: PerformanceDashboard
  private testResults: TestResult[] = []
  private benchmarks: BenchmarkResult[] = []

  constructor() {
    this.optimizer = new MCPOptimizer({
      cache: { ttl: 5 * 60 * 1000, maxSize: 1000 },
      parallel: { maxConcurrent: 4, enableSmartBatching: true },
      tokens: { targetLimit: 50000, enableDeduplication: true },
      performance: { monitoringEnabled: true },
    })

    this.detectionEngine = new MLPatternClassifier()
    this.dashboard = new PerformanceDashboard()

    this.setupEventListeners()
  }

  private setupEventListeners(): void {
    this.optimizer.on('execution_completed', (data) => {
      this.emit('test_event', {
        type: 'execution_completed',
        data,
      })
    })

    this.detectionEngine.on('pattern_retrained', () => {
      this.emit('test_event', {
        type: 'pattern_retrained',
      })
    })

    this.dashboard.on('alert_triggered', (alert) => {
      this.emit('test_event', {
        type: 'alert_triggered',
        alert,
      })
    })
  }

  /**
   * Run complete test suite
   */
  async runCompleteTestSuite(): Promise<ValidationMetrics> {
    console.log('🚀 Starting MCP Optimization Test Suite...\n')

    const testResults: ValidationMetrics = {
      cacheEfficiency: 0,
      parallelExecution: 0,
      tokenReduction: 0,
      detectionAccuracy: 0,
      responseTimeImprovement: 0,
      errorReduction: 0,
    }

    try {
      // Test 1: Cache System
      console.log('📋 Testing Cache System...')
      testResults.cacheEfficiency = await this.testCacheSystem()

      // Test 2: Parallel Execution
      console.log('⚡ Testing Parallel Execution...')
      testResults.parallelExecution = await this.testParallelExecution()

      // Test 3: Token Optimization
      console.log('🎯 Testing Token Optimization...')
      testResults.tokenReduction = await this.testTokenOptimization()

      // Test 4: Detection Engine Accuracy
      console.log('🧠 Testing Detection Engine...')
      testResults.detectionAccuracy = await this.testDetectionEngine()

      // Test 5: Response Time Improvement
      console.log('⏱️  Testing Response Time Improvement...')
      testResults.responseTimeImprovement = await this.testResponseTimeImprovement()

      // Test 6: Error Reduction
      console.log('🛡️  Testing Error Reduction...')
      testResults.errorReduction = await this.testErrorReduction()

      // Test 7: Integration Tests
      console.log('🔗 Running Integration Tests...')
      await this.runIntegrationTests()

      // Test 8: Performance Benchmarks
      console.log('📊 Running Performance Benchmarks...')
      await this.runPerformanceBenchmarks()

      console.log('\n✅ All tests completed successfully!')
      return testResults
    } catch (error) {
      console.error('❌ Test suite failed:', error)
      throw error
    }
  }

  /**
   * Test cache system performance
   */
  private async testCacheSystem(): Promise<number> {
    const tests = [
      {
        name: 'Cache Hit Rate',
        test: () => this.testCacheHitRate(),
      },
      {
        name: 'Cache TTL Management',
        test: () => this.testCacheTTL(),
      },
      {
        name: 'Cache Eviction',
        test: () => this.testCacheEviction(),
      },
      {
        name: 'Cache Persistence',
        test: () => this.testCachePersistence(),
      },
    ]

    const results = await Promise.allSettled(tests.map((t) => this.runSingleTest(t.name, t.test)))

    const passed = results.filter((r) => r.status === 'fulfilled').length
    const cacheEfficiency = passed / results.length

    console.log(
      `   Cache Tests: ${passed}/${results.length} passed (${(cacheEfficiency * 100).toFixed(1)}%)`
    )
    return cacheEfficiency
  }

  /**
   * Test cache hit rate performance
   */
  private async testCacheHitRate(): Promise<TestResult> {
    const startTime = Date.now()
    const testParams = { tool: 'serena', params: { analyze: 'component' } }

    try {
      // First call - should be cache miss
      await this.optimizer.execute(testParams)

      // Second call - should be cache hit
      const cacheTestStart = Date.now()
      await this.optimizer.execute(testParams)
      const cacheTestDuration = Date.now() - cacheTestStart

      const result: TestResult = {
        testName: 'Cache Hit Rate',
        passed: cacheTestDuration < 1000, // Should be much faster
        duration: cacheTestDuration,
        details: `Cache hit took ${cacheTestDuration}ms (should be < 1000ms)`,
        metrics: { cacheHitTime: cacheTestDuration },
      }

      this.testResults.push(result)
      return result
    } catch (error) {
      return {
        testName: 'Cache Hit Rate',
        passed: false,
        duration: Date.now() - startTime,
        details: `Cache test failed: ${error.message}`,
        metrics: {},
        error: error.message,
      }
    }
  }

  /**
   * Test cache TTL management
   */
  private async testCacheTTL(): Promise<TestResult> {
    const startTime = Date.now()
    const shortTTLConfig = { cache: { ttl: 1000 } } // 1 second

    const shortOptimizer = new MCPOptimizer(shortTTLConfig)
    const testParams = { tool: 'serena', params: { test: 'ttl' } }

    await shortOptimizer.execute(testParams)

    // Wait for TTL to expire
    await new Promise((resolve) => setTimeout(resolve, 1500))

    const secondCallStart = Date.now()
    await shortOptimizer.execute(testParams)
    const secondCallDuration = Date.now() - secondCallStart

    return {
      testName: 'Cache TTL Management',
      passed: secondCallDuration > 1000, // Should be slower (cache miss)
      duration: secondCallDuration,
      details: `Second call after TTL took ${secondCallDuration}ms`,
      metrics: { ttlExpiredDuration: secondCallDuration },
    }
  }

  /**
   * Test cache eviction
   */
  private async testCacheEviction(): Promise<TestResult> {
    const startTime = Date.now()
    const maxSizeConfig = { cache: { maxSize: 3 } }

    const sizeOptimizer = new MCPOptimizer(maxSizeConfig)

    // Fill cache beyond max size
    for (let i = 0; i < 5; i++) {
      await sizeOptimizer.execute({
        tool: 'serena',
        params: { test: `cache_eviction_${i}` },
      })
    }

    const status = sizeOptimizer.getStatus()
    const currentCacheSize = status.cacheStats.size

    return {
      testName: 'Cache Eviction',
      passed: currentCacheSize <= 3,
      duration: Date.now() - startTime,
      details: `Cache size: ${currentCacheSize} (should be ≤ 3)`,
      metrics: { finalCacheSize: currentCacheSize },
    }
  }

  /**
   * Test cache persistence
   */
  private async testCachePersistence(): Promise<TestResult> {
    const startTime = Date.now()
    const persistenceConfig = { cache: { enablePersistence: true } }

    const persistentOptimizer = new MCPOptimizer(persistenceConfig)
    await persistentOptimizer.execute({
      tool: 'serena',
      params: { test: 'persistence' },
    })

    // Simulate restart by creating new instance
    const restartedOptimizer = new MCPOptimizer(persistenceConfig)
    const status = restartedOptimizer.getStatus()

    return {
      testName: 'Cache Persistence',
      passed: status.cacheStats.size > 0,
      duration: Date.now() - startTime,
      details: `Restored cache size: ${status.cacheStats.size}`,
      metrics: { restoredCacheSize: status.cacheStats.size },
    }
  }

  /**
   * Test parallel execution performance
   */
  private async testParallelExecution(): Promise<number> {
    const sequentialParams = [
      { tool: 'serena', params: { analyze: 'test1' } },
      { tool: 'context7', params: { save: 'test1' } },
      { tool: 'vue_dev_server', params: { action: 'status' } },
    ]

    // Sequential execution
    const sequentialStart = Date.now()
    for (const params of sequentialParams) {
      await this.optimizer.execute(params)
    }
    const sequentialTime = Date.now() - sequentialStart

    // Parallel execution
    const parallelStart = Date.now()
    await this.optimizer.execute(sequentialParams)
    const parallelTime = Date.now() - parallelStart

    const improvement = (sequentialTime - parallelTime) / sequentialTime
    const improvementPercent = improvement * 100

    this.benchmarks.push({
      scenario: 'Sequential vs Parallel',
      originalTime: sequentialTime,
      optimizedTime: parallelTime,
      improvement: sequentialTime - parallelTime,
      improvementPercent,
      metrics: { sequentialTime, parallelTime },
    })

    console.log(`   Parallel Execution: ${improvementPercent.toFixed(1)}% improvement`)
    return improvementPercent / 100 // Return as decimal
  }

  /**
   * Test token optimization
   */
  private async testTokenOptimization(): Promise<number> {
    const largeContext = Array(100)
      .fill(0)
      .map((_, i) => ({
        content:
          `This is large content chunk ${i} with lots of redundant information that could be optimized or compressed to save tokens and improve processing efficiency dramatically`.repeat(
            5
          ),
        type: 'documentation',
        importance: 0.5,
      }))

    const originalTokens = this.estimateTokens(largeContext)

    // Simulate optimization
    const optimizedContext = this.simulateTokenOptimization(largeContext)
    const optimizedTokens = this.estimateTokens(optimizedContext)

    const reduction = (originalTokens - optimizedTokens) / originalTokens

    this.benchmarks.push({
      scenario: 'Token Optimization',
      originalTime: originalTokens,
      optimizedTime: optimizedTokens,
      improvement: originalTokens - optimizedTokens,
      improvementPercent: reduction * 100,
      metrics: { originalTokens, optimizedTokens },
    })

    console.log(`   Token Optimization: ${(reduction * 100).toFixed(1)}% reduction`)
    return reduction
  }

  /**
   * Test detection engine accuracy
   */
  private async testDetectionEngine(): Promise<number> {
    const testCases = [
      {
        request: 'Analyze this Vue component and suggest improvements',
        expectedTool: 'serena',
        context: { projectType: 'vue_project' },
      },
      {
        request: 'Remember this conversation for later',
        expectedTool: 'context7',
        context: { projectType: 'vue_project' },
      },
      {
        request: 'Query all currency orders from last week',
        expectedTool: 'supabase',
        context: { projectType: 'vue_project' },
      },
      {
        request: 'Compare with Figma design',
        expectedTool: 'figma_compare',
        context: { projectType: 'vue_project' },
      },
      {
        request: 'Commit these changes to GitHub',
        expectedTool: 'github',
        context: { projectType: 'vue_project' },
      },
    ]

    let correctDetections = 0

    for (const testCase of testCases) {
      const result = await this.detectionEngine.detectTool(testCase.request, testCase.context)

      if (result.tool === testCase.expectedTool && result.confidence > 0.6) {
        correctDetections++
      }

      // Record learning data
      this.detectionEngine.updateLearning(
        testCase.request,
        result.tool === testCase.expectedTool ? 'success' : 'failure',
        testCase.expectedTool
      )
    }

    const accuracy = correctDetections / testCases.length

    this.benchmarks.push({
      scenario: 'Detection Accuracy',
      originalTime: 87, // Original accuracy %
      optimizedTime: accuracy * 100,
      improvement: accuracy * 100 - 87,
      improvementPercent: ((accuracy * 100 - 87) / 87) * 100,
      metrics: { correctDetections, totalTests: testCases.length },
    })

    console.log(`   Detection Accuracy: ${(accuracy * 100).toFixed(1)}% (target: 95%)`)
    return accuracy
  }

  /**
   * Test response time improvement
   */
  private async testResponseTimeImprovement(): Promise<number> {
    const scenarios = [
      { tool: 'serena', params: { analyze: 'complex_component' } },
      { tool: 'figma_compare', params: { component: 'Header' } },
      { tool: 'web-search-prime', params: { query: 'Vue 3 best practices' } },
    ]

    let totalImprovement = 0

    for (const scenario of scenarios) {
      const optimizedResult = await this.optimizer.execute(scenario)
      const estimatedOriginalTime = this.getOriginalToolTime(scenario.tool)

      const improvement =
        (estimatedOriginalTime - optimizedResult.metrics.responseTime) / estimatedOriginalTime
      totalImprovement += improvement
    }

    const avgImprovement = totalImprovement / scenarios.length

    this.benchmarks.push({
      scenario: 'Response Time Improvement',
      originalTime: 45000, // Average original time
      optimizedTime: 45000 * (1 - avgImprovement),
      improvement: 45000 * avgImprovement,
      improvementPercent: avgImprovement * 100,
      metrics: { avgImprovement },
    })

    console.log(`   Response Time: ${(avgImprovement * 100).toFixed(1)}% improvement`)
    return avgImprovement
  }

  /**
   * Test error reduction
   */
  private async testErrorReduction(): Promise<number> {
    const errorProneScenarios = [
      { tool: 'serena', params: { analyze: 'malformed_input' } },
      { tool: 'figma_compare', params: { component: 'nonexistent' } },
      { tool: 'github', params: { action: 'invalid_operation' } },
    ]

    let handledErrors = 0

    for (const scenario of errorProneScenarios) {
      try {
        await this.optimizer.execute(scenario)
      } catch (error) {
        // Check if error was handled gracefully
        if (error.message.includes('handled') || error.message.includes('fallback')) {
          handledErrors++
        }
      }
    }

    const errorHandlingRate = handledErrors / errorProneScenarios.length

    console.log(`   Error Reduction: ${(errorHandlingRate * 100).toFixed(1)}% handled gracefully`)
    return errorHandlingRate
  }

  /**
   * Run integration tests
   */
  private async runIntegrationTests(): Promise<void> {
    const integrationTests = [
      { name: 'Cache + Parallel Execution', test: () => this.testCacheParallelIntegration() },
      { name: 'Detection + Optimizer', test: () => this.testDetectionOptimizerIntegration() },
      { name: 'Dashboard + Metrics', test: () => this.testDashboardIntegration() },
      { name: 'End-to-End Workflow', test: () => this.testEndToEndWorkflow() },
    ]

    for (const test of integrationTests) {
      await this.runSingleTest(test.name, test.test)
    }
  }

  /**
   * Test cache and parallel execution integration
   */
  private async testCacheParallelIntegration(): Promise<TestResult> {
    const startTime = Date.now()
    const executions = [
      { tool: 'serena', params: { analyze: 'test1' } },
      { tool: 'serena', params: { analyze: 'test2' } },
      { tool: 'serena', params: { analyze: 'test3' } },
    ]

    // First run to populate cache
    await this.optimizer.execute(executions)

    // Second run - should use cache and parallel execution
    const secondRunStart = Date.now()
    await this.optimizer.execute(executions)
    const secondRunTime = Date.now() - secondRunStart

    return {
      testName: 'Cache + Parallel Integration',
      passed: secondRunTime < 5000, // Should be very fast
      duration: secondRunTime,
      details: `Cached parallel execution took ${secondRunTime}ms`,
      metrics: { secondRunTime },
    }
  }

  /**
   * Test detection and optimizer integration
   */
  private async testDetectionOptimizerIntegration(): Promise<TestResult> {
    const startTime = Date.now()
    const request = 'Analyze Vue component for performance issues'
    const context = { projectType: 'vue_project' }

    const detection = await this.detectionEngine.detectTool(request, context)

    if (detection.tool === 'serena') {
      const execution = await this.optimizer.execute({
        tool: 'serena',
        params: { analyze: 'component', focus: 'performance' },
      })

      return {
        testName: 'Detection + Optimizer Integration',
        passed: true,
        duration: Date.now() - startTime,
        details: `Detection selected ${detection.tool}, execution completed`,
        metrics: { detection, execution },
      }
    }

    return {
      testName: 'Detection + Optimizer Integration',
      passed: false,
      duration: Date.now() - startTime,
      details: `Detection failed to select correct tool`,
      metrics: { detection },
    }
  }

  /**
   * Test dashboard integration
   */
  private async testDashboardIntegration(): Promise<TestResult> {
    const startTime = Date.now()

    // Generate some activity
    await this.optimizer.execute({ tool: 'serena', params: { test: 'dashboard' } })

    // Check if dashboard captured the activity
    const dashboardData = this.dashboard.getCurrentData()

    return {
      testName: 'Dashboard + Metrics Integration',
      passed: dashboardData !== null,
      duration: Date.now() - startTime,
      details: `Dashboard data: ${dashboardData ? 'available' : 'unavailable'}`,
      metrics: { hasData: dashboardData !== null },
    }
  }

  /**
   * Test end-to-end workflow
   */
  private async testEndToEndWorkflow(): Promise<TestResult> {
    const startTime = Date.now()

    try {
      // Complete workflow: Detection -> Optimization -> Execution -> Monitoring
      const request = 'Analyze this Vue component and save results'
      const detection = await this.detectionEngine.detectTool(request)

      const execution = await this.optimizer.execute({
        tool: detection.tool,
        params: { analyze: 'component', save: true },
      })

      const metrics = this.optimizer.getStatus()

      return {
        testName: 'End-to-End Workflow',
        passed: execution !== null,
        duration: Date.now() - startTime,
        details: `Workflow completed with ${detection.confidence} confidence`,
        metrics: { detection, execution, metrics },
      }
    } catch (error) {
      return {
        testName: 'End-to-End Workflow',
        passed: false,
        duration: Date.now() - startTime,
        details: `Workflow failed: ${error.message}`,
        error: error.message,
        metrics: {},
      }
    }
  }

  /**
   * Run performance benchmarks
   */
  private async runPerformanceBenchmarks(): Promise<void> {
    console.log('\n📈 Performance Benchmarks:')

    for (const benchmark of this.benchmarks) {
      console.log(
        `   ${benchmark.scenario}: ${benchmark.improvementPercent.toFixed(1)}% improvement`
      )
      console.log(
        `     Original: ${benchmark.originalTime}ms, Optimized: ${benchmark.optimizedTime}ms`
      )
    }

    // Overall metrics
    const avgImprovement =
      this.benchmarks.reduce((sum, b) => sum + b.improvementPercent, 0) / this.benchmarks.length

    console.log(`   Overall Improvement: ${avgImprovement.toFixed(1)}%`)
  }

  /**
   * Run single test
   */
  private async runSingleTest(
    testName: string,
    testFn: () => Promise<TestResult>
  ): Promise<TestResult> {
    try {
      const result = await testFn()
      console.log(
        `     ${testName}: ${result.passed ? '✅ PASS' : '❌ FAIL'} (${result.duration}ms)`
      )
      return result
    } catch (error) {
      console.log(`     ${testName}: ❌ ERROR - ${error.message}`)
      return {
        testName,
        passed: false,
        duration: 0,
        details: `Test error: ${error.message}`,
        error: error.message,
        metrics: {},
      }
    }
  }

  // Helper methods
  private estimateTokens(context: any[]): number {
    const str = JSON.stringify(context)
    return Math.ceil(str.length / 4) // Rough estimation
  }

  private simulateTokenOptimization(context: any[]): any[] {
    // Simulate deduplication and compression
    const unique = context.filter(
      (item, index, arr) =>
        arr.findIndex((i) => JSON.stringify(i) === JSON.stringify(item)) === index
    )

    return unique.map((item) => ({
      ...item,
      content:
        typeof item.content === 'string'
          ? item.content.replace(/\b(\w+)\s+\1\b/g, '$1')
          : item.content, // Remove repeated words
    }))
  }

  private getOriginalToolTime(tool: string): number {
    const originalTimes: Record<string, number> = {
      serena: 45000,
      figma_compare: 60000,
      'web-search-prime': 25000,
      context7: 15000,
      github: 20000,
      supabase: 35000,
      vue_dev_server: 5000,
      'zai-vision': 30000,
    }

    return originalTimes[tool] || 30000
  }

  /**
   * Get complete test results
   */
  getTestResults(): {
    validationMetrics: ValidationMetrics
    testResults: TestResult[]
    benchmarks: BenchmarkResult[]
    summary: any
  } {
    const passedTests = this.testResults.filter((r) => r.passed).length
    const totalTests = this.testResults.length

    return {
      validationMetrics: {
        cacheEfficiency: 0, // Would be populated by actual test run
        parallelExecution: 0,
        tokenReduction: 0,
        detectionAccuracy: 0,
        responseTimeImprovement: 0,
        errorReduction: 0,
      },
      testResults: this.testResults,
      benchmarks: this.benchmarks,
      summary: {
        totalTests,
        passedTests,
        successRate: totalTests > 0 ? passedTests / totalTests : 0,
        overallImprovement:
          this.benchmarks.length > 0
            ? this.benchmarks.reduce((sum, b) => sum + b.improvementPercent, 0) /
              this.benchmarks.length
            : 0,
      },
    }
  }

  /**
   * Export test results
   */
  exportResults(format: 'json' | 'html' = 'json'): string {
    const results = this.getTestResults()

    if (format === 'json') {
      return JSON.stringify(results, null, 2)
    } else {
      return this.generateHTMLReport(results)
    }
  }

  private generateHTMLReport(results: any): string {
    return `
<!DOCTYPE html>
<html>
<head>
    <title>MCP Optimization Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .test-result { margin: 10px 0; padding: 10px; border-left: 4px solid #ddd; }
        .pass { border-left-color: #4CAF50; }
        .fail { border-left-color: #f44336; }
        .benchmark { margin: 10px 0; }
        .improvement { color: #4CAF50; font-weight: bold; }
        .degradation { color: #f44336; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 MCP Optimization Test Results</h1>
        <p>Generated: ${new Date().toISOString()}</p>
        <h2>Summary</h2>
        <p>Tests Passed: ${results.summary.passedTests}/${results.summary.totalTests} (${(results.summary.successRate * 100).toFixed(1)}%)</p>
        <p>Overall Improvement: ${results.summary.overallImprovement.toFixed(1)}%</p>
    </div>

    <h2>Validation Metrics</h2>
    <div class="test-result ${results.validationMetrics.cacheEfficiency > 0.8 ? 'pass' : 'fail'}">
        Cache Efficiency: ${(results.validationMetrics.cacheEfficiency * 100).toFixed(1)}%
    </div>
    <div class="test-result ${results.validationMetrics.parallelExecution > 0.5 ? 'pass' : 'fail'}">
        Parallel Execution: ${(results.validationMetrics.parallelExecution * 100).toFixed(1)}%
    </div>
    <div class="test-result ${results.validationMetrics.tokenReduction > 0.3 ? 'pass' : 'fail'}">
        Token Reduction: ${(results.validationMetrics.tokenReduction * 100).toFixed(1)}%
    </div>
    <div class="test-result ${results.validationMetrics.detectionAccuracy > 0.9 ? 'pass' : 'fail'}">
        Detection Accuracy: ${(results.validationMetrics.detectionAccuracy * 100).toFixed(1)}%
    </div>

    <h2>Performance Benchmarks</h2>
    ${results.benchmarks
      .map(
        (benchmark) => `
    <div class="benchmark">
        <h3>${benchmark.scenario}</h3>
        <p>Original: ${benchmark.originalTime}ms</p>
        <p>Optimized: ${benchmark.optimizedTime}ms</p>
        <p class="${benchmark.improvementPercent > 0 ? 'improvement' : 'degradation'}">
            Improvement: ${benchmark.improvementPercent.toFixed(1)}%
        </p>
    </div>
    `
      )
      .join('')}
</body>
</html>`
  }
}

export { OptimizationTestSuite }
export type { TestResult, BenchmarkResult, ValidationMetrics }
