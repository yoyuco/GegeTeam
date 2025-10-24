/**
 * Real-time Performance Monitoring Dashboard
 * Tracks MCP optimization metrics and provides actionable insights
 */

import { EventEmitter } from 'events'
import { PerformanceMetrics } from './mcp-response-optimizer'

interface DashboardData {
  timestamp: number
  responseTime: number
  cacheHitRate: number
  tokenUsage: number
  detectionAccuracy: number
  parallelExecutionRate: number
  errorRate: number
  throughput: number
  toolsInUse: string[]
}

interface AlertRule {
  id: string
  name: string
  metric: keyof DashboardData
  operator: '>' | '<' | '=' | '>=' | '<='
  threshold: number
  severity: 'low' | 'medium' | 'high' | 'critical'
  enabled: boolean
  description: string
  recommendation: string
}

interface ToolPerformance {
  tool: string
  avgResponseTime: number
  successRate: number
  usageCount: number
  lastUsed: number
  trend: 'improving' | 'stable' | 'degrading'
  efficiency: number
}

/**
 * Performance Dashboard with Real-time Monitoring
 */
class PerformanceDashboard extends EventEmitter {
  private data: DashboardData[] = []
  private alerts: Array<{
    rule: AlertRule
    triggered: number
    acknowledged: boolean
  }> = []
  private toolPerformance = new Map<string, ToolPerformance>()
  private maxDataPoints = 1000
  private isRunning = false

  constructor() {
    super()
    this.initializeAlertRules()
    this.startDataCollection()
  }

  /**
   * Initialize alert rules
   */
  private initializeAlertRules(): void {
    const defaultRules: AlertRule[] = [
      {
        id: 'slow_response_time',
        name: 'Slow Response Time',
        metric: 'responseTime',
        operator: '>',
        threshold: 30000, // 30 seconds
        severity: 'high',
        enabled: true,
        description: 'MCP response time exceeds 30 seconds',
        recommendation: 'Check network connectivity and consider using caching',
      },
      {
        id: 'low_cache_hit_rate',
        name: 'Low Cache Hit Rate',
        metric: 'cacheHitRate',
        operator: '<',
        threshold: 0.3, // 30%
        severity: 'medium',
        enabled: true,
        description: 'Cache hit rate below 30%',
        recommendation: 'Increase cache TTL and optimize key generation',
      },
      {
        id: 'high_token_usage',
        name: 'High Token Usage',
        metric: 'tokenUsage',
        operator: '>',
        threshold: 80000, // 80K tokens
        severity: 'medium',
        enabled: true,
        description: 'Token usage exceeds 80K',
        recommendation: 'Optimize context with semantic tools and compression',
      },
      {
        id: 'low_detection_accuracy',
        name: 'Low Detection Accuracy',
        metric: 'detectionAccuracy',
        operator: '<',
        threshold: 0.8, // 80%
        severity: 'critical',
        enabled: true,
        description: 'Detection accuracy below 80%',
        recommendation: 'Retrain patterns and provide more user feedback',
      },
      {
        id: 'high_error_rate',
        name: 'High Error Rate',
        metric: 'errorRate',
        operator: '>',
        threshold: 0.1, // 10%
        severity: 'high',
        enabled: true,
        description: 'Error rate exceeds 10%',
        recommendation: 'Review error logs and check MCP tool configurations',
      },
    ]

    // Load custom rules from configuration if available
    this.alerts = defaultRules.map((rule) => ({
      rule,
      triggered: 0,
      acknowledged: false,
    }))
  }

  /**
   * Start real-time data collection
   */
  private startDataCollection(): void {
    this.isRunning = true

    // Collect data every 5 seconds
    setInterval(() => {
      if (this.isRunning) {
        this.collectDataPoint()
      }
    }, 5000)

    // Process alerts every 10 seconds
    setInterval(() => {
      if (this.isRunning) {
        this.processAlerts()
      }
    }, 10000)

    // Generate hourly reports
    setInterval(
      () => {
        if (this.isRunning) {
          this.generateHourlyReport()
        }
      },
      60 * 60 * 1000
    )
  }

  /**
   * Collect a single data point
   */
  private async collectDataPoint(): Promise<void> {
    try {
      const dataPoint: DashboardData = {
        timestamp: Date.now(),
        responseTime: await this.getCurrentResponseTime(),
        cacheHitRate: await this.getCurrentCacheHitRate(),
        tokenUsage: await this.getCurrentTokenUsage(),
        detectionAccuracy: await this.getCurrentDetectionAccuracy(),
        parallelExecutionRate: await this.getCurrentParallelRate(),
        errorRate: await this.getCurrentErrorRate(),
        throughput: await this.getCurrentThroughput(),
        toolsInUse: await this.getCurrentToolsInUse(),
      }

      this.addDataPoint(dataPoint)
      this.updateToolPerformance(dataPoint)
    } catch (error) {
      console.error('Error collecting data point:', error)
    }
  }

  /**
   * Add data point with automatic cleanup
   */
  private addDataPoint(dataPoint: DashboardData): void {
    this.data.push(dataPoint)

    // Keep only recent data points
    if (this.data.length > this.maxDataPoints) {
      this.data = this.data.slice(-this.maxDataPoints)
    }

    this.emit('data_point_added', dataPoint)
  }

  /**
   * Update tool performance metrics
   */
  private updateToolPerformance(dataPoint: DashboardData): void {
    for (const tool of dataPoint.toolsInUse) {
      const current = this.toolPerformance.get(tool) || {
        tool,
        avgResponseTime: 0,
        successRate: 0,
        usageCount: 0,
        lastUsed: Date.now(),
        trend: 'stable' as const,
        efficiency: 0,
      }

      current.usageCount++
      current.lastUsed = dataPoint.timestamp

      // Exponential moving average for response time
      current.avgResponseTime = current.avgResponseTime * 0.9 + dataPoint.responseTime * 0.1

      // Update success rate (would need actual success/failure data)
      const successRate = dataPoint.errorRate < 0.1 ? 1 : 0.5 // Simplified
      current.successRate = current.successRate * 0.8 + successRate * 0.2

      // Calculate efficiency (success rate / response time)
      current.efficiency = current.successRate / Math.max(1, current.avgResponseTime / 1000)

      // Determine trend
      current.trend = this.calculateTrend(tool)

      this.toolPerformance.set(tool, current)
    }
  }

  /**
   * Calculate performance trend for a tool
   */
  private calculateTrend(tool: string): 'improving' | 'stable' | 'degrading' {
    const performance = this.toolPerformance.get(tool)
    if (!performance || performance.usageCount < 5) {
      return 'stable'
    }

    // Look at recent vs overall performance
    const recentData = this.data.slice(-10) // Last 10 data points
    const toolRecentData = recentData.filter((dp) => dp.toolsInUse.includes(tool))

    if (toolRecentData.length < 3) {
      return 'stable'
    }

    const recentAvgResponseTime =
      toolRecentData.reduce((sum, dp) => sum + dp.responseTime, 0) / toolRecentData.length
    const recentSuccessRate =
      toolRecentData.reduce((sum, dp) => sum + (1 - dp.errorRate), 0) / toolRecentData.length

    if (
      recentAvgResponseTime < performance.avgResponseTime * 0.9 &&
      recentSuccessRate > performance.successRate * 1.1
    ) {
      return 'improving'
    } else if (
      recentAvgResponseTime > performance.avgResponseTime * 1.1 ||
      recentSuccessRate < performance.successRate * 0.9
    ) {
      return 'degrading'
    }

    return 'stable'
  }

  /**
   * Process alert rules
   */
  private processAlerts(): void {
    if (this.data.length === 0) return

    const latestData = this.data[this.data.length - 1]

    for (const alert of this.alerts) {
      if (!alert.rule.enabled || alert.acknowledged) continue

      const metricValue = latestData[alert.rule.metric]
      let triggered = false

      switch (alert.rule.operator) {
        case '>':
          triggered = metricValue > alert.rule.threshold
          break
        case '<':
          triggered = metricValue < alert.rule.threshold
          break
        case '>=':
          triggered = metricValue >= alert.rule.threshold
          break
        case '<=':
          triggered = metricValue <= alert.rule.threshold
          break
        case '=':
          triggered = metricValue === alert.rule.threshold
          break
      }

      if (triggered) {
        alert.triggered++
        this.emit('alert_triggered', {
          rule: alert.rule,
          value: metricValue,
          threshold: alert.rule.threshold,
          timestamp: Date.now(),
        })
      }
    }
  }

  /**
   * Generate hourly performance report
   */
  private generateHourlyReport(): void {
    const now = Date.now()
    const oneHourAgo = now - 60 * 60 * 1000
    const hourlyData = this.data.filter((dp) => dp.timestamp >= oneHourAgo)

    if (hourlyData.length === 0) return

    const report = {
      period: new Date(oneHourAgo).toISOString() + ' to ' + new Date(now).toISOString(),
      metrics: {
        avgResponseTime:
          hourlyData.reduce((sum, dp) => sum + dp.responseTime, 0) / hourlyData.length,
        avgCacheHitRate:
          hourlyData.reduce((sum, dp) => sum + dp.cacheHitRate, 0) / hourlyData.length,
        maxTokenUsage: Math.max(...hourlyData.map((dp) => dp.tokenUsage)),
        avgDetectionAccuracy:
          hourlyData.reduce((sum, dp) => sum + dp.detectionAccuracy, 0) / hourlyData.length,
        totalErrors: hourlyData.reduce((sum, dp) => sum + dp.errorRate * 100, 0),
        avgThroughput: hourlyData.reduce((sum, dp) => sum + dp.throughput, 0) / hourlyData.length,
      },
      toolUsage: this.getToolUsageStats(hourlyData),
      alerts: this.alerts.filter((a) => a.triggered > 0 && !a.acknowledged),
      recommendations: this.generateRecommendations(),
    }

    this.emit('hourly_report', report)
  }

  /**
   * Get tool usage statistics
   */
  private getToolUsageStats(
    data: DashboardData[]
  ): Array<{ tool: string; usageCount: number; percentage: number }> {
    const toolCounts = new Map<string, number>()
    let totalUsages = 0

    for (const dataPoint of data) {
      for (const tool of dataPoint.toolsInUse) {
        toolCounts.set(tool, (toolCounts.get(tool) || 0) + 1)
        totalUsages++
      }
    }

    return Array.from(toolCounts.entries())
      .map(([tool, count]) => ({
        tool,
        usageCount: count,
        percentage: (count / totalUsages) * 100,
      }))
      .sort((a, b) => b.usageCount - a.usageCount)
  }

  /**
   * Generate optimization recommendations
   */
  private generateRecommendations(): string[] {
    const recommendations: string[] = []
    const latest = this.data[this.data.length - 1]

    if (!latest) return recommendations

    // Response time recommendations
    if (latest.responseTime > 25000) {
      recommendations.push('Consider enabling more aggressive caching for slow tools')
      recommendations.push('Review tool configurations for potential bottlenecks')
    }

    // Cache recommendations
    if (latest.cacheHitRate < 0.5) {
      recommendations.push('Cache hit rate is low - review cache key generation strategy')
      recommendations.push('Consider increasing cache TTL for frequently accessed data')
    }

    // Token usage recommendations
    if (latest.tokenUsage > 60000) {
      recommendations.push(
        'Token usage is high - implement semantic analysis instead of full file reads'
      )
      recommendations.push('Enable context compression and deduplication')
    }

    // Detection accuracy recommendations
    if (latest.detectionAccuracy < 0.85) {
      recommendations.push('Provide more feedback on tool selections to improve accuracy')
      recommendations.push('Consider retraining detection patterns with recent data')
    }

    // Parallel execution recommendations
    if (latest.parallelExecutionRate < 0.3) {
      recommendations.push('Enable parallel execution for compatible MCP calls')
      recommendations.push('Review tool batching configuration')
    }

    return recommendations
  }

  // Data collection methods (would interface with actual MCP systems)
  private async getCurrentResponseTime(): Promise<number> {
    // This would interface with the actual MCP optimization system
    return 15000 // Placeholder
  }

  private async getCurrentCacheHitRate(): Promise<number> {
    return 0.7 // Placeholder
  }

  private async getCurrentTokenUsage(): Promise<number> {
    return 45000 // Placeholder
  }

  private async getCurrentDetectionAccuracy(): Promise<number> {
    return 0.87 // Placeholder
  }

  private async getCurrentParallelRate(): Promise<number> {
    return 0.8 // Placeholder
  }

  private async getCurrentErrorRate(): Promise<number> {
    return 0.05 // Placeholder
  }

  private async getCurrentThroughput(): Promise<number> {
    return 12 // Placeholder: requests per minute
  }

  private async getCurrentToolsInUse(): Promise<string[]> {
    return ['serena', 'context7', 'supabase'] // Placeholder
  }

  // Public API methods
  /**
   * Get current dashboard data
   */
  getCurrentData(): DashboardData | null {
    return this.data.length > 0 ? this.data[this.data.length - 1] : null
  }

  /**
   * Get historical data
   */
  getHistoricalData(minutes?: number): DashboardData[] {
    if (!minutes) return this.data

    const cutoff = Date.now() - minutes * 60 * 1000
    return this.data.filter((dp) => dp.timestamp >= cutoff)
  }

  /**
   * Get tool performance metrics
   */
  getToolPerformance(): ToolPerformance[] {
    return Array.from(this.toolPerformance.values())
  }

  /**
   * Get active alerts
   */
  getActiveAlerts(): Array<{ rule: AlertRule; triggered: number; recommendation: string }> {
    return this.alerts
      .filter((alert) => alert.triggered > 0 && !alert.acknowledged)
      .map((alert) => ({
        rule: alert.rule,
        triggered: alert.triggered,
        recommendation: alert.rule.recommendation,
      }))
  }

  /**
   * Acknowledge alert
   */
  acknowledgeAlert(alertId: string): void {
    const alert = this.alerts.find((a) => a.rule.id === alertId)
    if (alert) {
      alert.acknowledged = true
      this.emit('alert_acknowledged', { alertId, rule: alert.rule })
    }
  }

  /**
   * Update alert rule
   */
  updateAlertRule(alertId: string, updates: Partial<AlertRule>): void {
    const alert = this.alerts.find((a) => a.rule.id === alertId)
    if (alert) {
      Object.assign(alert.rule, updates)
      this.emit('alert_rule_updated', { alertId, rule: alert.rule })
    }
  }

  /**
   * Get dashboard summary
   */
  getDashboardSummary() {
    if (this.data.length === 0) {
      return {
        status: 'no_data',
        message: 'No data available yet',
      }
    }

    const latest = this.data[this.data.length - 1]
    const recent = this.data.slice(-10)
    const avgResponseTime = recent.reduce((sum, dp) => sum + dp.responseTime, 0) / recent.length

    return {
      status: 'active',
      uptime: this.isRunning,
      dataPoints: this.data.length,
      currentMetrics: latest,
      recentTrends: {
        responseTime: avgResponseTime,
        improving: avgResponseTime < latest.responseTime,
        toolsInUse: latest.toolsInUse.length,
      },
      activeAlerts: this.getActiveAlerts().length,
      topTools: this.getToolUsageStats(recent).slice(0, 5),
    }
  }

  /**
   * Start/stop dashboard
   */
  start(): void {
    this.isRunning = true
    this.emit('dashboard_started')
  }

  stop(): void {
    this.isRunning = false
    this.emit('dashboard_stopped')
  }

  /**
   * Export dashboard data
   */
  exportData(format: 'json' | 'csv' = 'json'): string {
    const data = {
      timestamp: new Date().toISOString(),
      summary: this.getDashboardSummary(),
      metrics: this.data,
      toolPerformance: this.getToolPerformance(),
      alerts: this.getActiveAlerts(),
    }

    if (format === 'json') {
      return JSON.stringify(data, null, 2)
    } else {
      return this.convertToCSV(data)
    }
  }

  private convertToCSV(data: any): string {
    // Convert metrics data to CSV
    const headers = [
      'timestamp',
      'responseTime',
      'cacheHitRate',
      'tokenUsage',
      'detectionAccuracy',
      'parallelExecutionRate',
      'errorRate',
      'throughput',
    ]
    const rows = [headers.join(',')]

    for (const metric of data.metrics) {
      const row = [
        new Date(metric.timestamp).toISOString(),
        metric.responseTime,
        metric.cacheHitRate,
        metric.tokenUsage,
        metric.detectionAccuracy,
        metric.parallelExecutionRate,
        metric.errorRate,
        metric.throughput,
      ]
      rows.push(row.join(','))
    }

    return rows.join('\n')
  }
}

export { PerformanceDashboard }
export type { DashboardData, AlertRule, ToolPerformance }
