/**
 * MCP Optimization System Index
 * Entry point for all optimization components
 */

export {
  MCPOptimizer,
  MCPCacheManager,
  ParallelExecutionEngine,
  TokenOptimizer,
} from './mcp-response-optimizer'
export { MLPatternClassifier } from './enhanced-detection-engine-v3'
export { PerformanceDashboard } from './performance-dashboard'
export { OptimizationTestSuite } from './optimization-test-suite'

export type {
  OptimizationConfig,
  PerformanceMetrics,
  CacheEntry,
  DetectionResult,
  Pattern,
  LearningData,
  DashboardData,
  AlertRule,
  ToolPerformance,
  TestResult,
  BenchmarkResult,
  ValidationMetrics,
} from './mcp-response-optimizer'

/**
 * Quick initialization function
 */
export function initializeMPOptimization(config?: Partial<OptimizationConfig>) {
  const MCPOptimizer = require('./mcp-response-optimizer').MCPOptimizer
  const MLPatternClassifier = require('./enhanced-detection-engine-v3').MLPatternClassifier
  const PerformanceDashboard = require('./performance-dashboard').PerformanceDashboard
  const OptimizationTestSuite = require('./optimization-test-suite').OptimizationTestSuite

  return {
    optimizer: new MCPOptimizer(config),
    detectionEngine: new MLPatternClassifier(),
    dashboard: new PerformanceDashboard(),
    testSuite: new OptimizationTestSuite(),
  }
}

/**
 * Factory for different optimization profiles
 */
export function createOptimizationProfile(profile: 'development' | 'production' | 'testing') {
  const profiles = {
    development: {
      cache: { ttl: 10 * 60 * 1000, maxSize: 500 }, // 10 min, smaller cache
      parallel: { maxConcurrent: 2, timeoutMs: 15000 }, // More conservative
      tokens: { targetLimit: 30000 }, // Lower token limit for dev
      performance: {
        monitoringEnabled: true,
        alertThresholds: {
          responseTime: 10000, // Stricter for dev
          cacheHitRate: 0.4,
          tokenUsage: 40000,
        },
      },
    },
    production: {
      cache: { ttl: 15 * 60 * 1000, maxSize: 2000 }, // 15 min, larger cache
      parallel: { maxConcurrent: 6, timeoutMs: 45000 }, // More aggressive
      tokens: { targetLimit: 80000 }, // Higher token limit for production
      performance: {
        monitoringEnabled: true,
        alertThresholds: {
          responseTime: 30000, // More lenient for production
          cacheHitRate: 0.3,
          tokenUsage: 100000,
        },
      },
    },
    testing: {
      cache: { ttl: 1 * 60 * 1000, maxSize: 100 }, // 1 min, minimal cache
      parallel: { maxConcurrent: 1, timeoutMs: 5000 }, // Sequential for testing
      tokens: { targetLimit: 50000 }, // Standard limit
      performance: {
        monitoringEnabled: true,
        alertThresholds: {
          responseTime: 5000, // Very strict for testing
          cacheHitRate: 0.6,
          tokenUsage: 30000,
        },
      },
    },
  }

  return profiles[profile] || profiles.development
}

/**
 * Get system status
 */
export async function getOptimizationStatus() {
  const systems = initializeMPOptimization()
  const metrics = systems.optimizer.getStatus()
  const accuracy = systems.detectionEngine.getAccuracyMetrics()
  const dashboard = systems.dashboard.getDashboardSummary()

  return {
    timestamp: new Date().toISOString(),
    optimizer: metrics,
    detectionEngine: accuracy,
    dashboard,
    recommendations: generateRecommendations(metrics, accuracy, dashboard),
  }
}

/**
 * Generate actionable recommendations
 */
function generateRecommendations(optimizerStatus: any, accuracyMetrics: any, dashboard: any) {
  const recommendations: string[] = []

  // Cache recommendations
  if (optimizerStatus.cacheStats.hitRate < 0.5) {
    recommendations.push('Increase cache TTL to improve hit rate')
    recommendations.push('Review cache key generation strategy')
  }

  // Response time recommendations
  if (optimizerStatus.metrics.responseTime > 20000) {
    recommendations.push('Enable more aggressive parallel execution')
    recommendations.push('Consider tool-specific timeout adjustments')
  }

  // Detection accuracy recommendations
  if (accuracyMetrics.currentAccuracy < 0.9) {
    recommendations.push('Provide more feedback on tool selections')
    recommendations.push('Retrain detection patterns with recent data')
  }

  // Performance recommendations
  if (dashboard.activeAlerts > 3) {
    recommendations.push('Address high-priority alerts immediately')
    recommendations.push('Consider temporary performance reduction mode')
  }

  return recommendations
}
