#!/usr/bin/env ts-node

/**
 * Real-time Monitoring Script for Context Management
 * Provides continuous monitoring and alerting
 */

import * as fs from 'fs'
import * as path from 'path'
import * as cron from 'node-cron'
import { ContextManager } from '../tools/context-manager/ContextManager'
import { AdvancedContextMonitor } from '../tools/context-monitor/ContextMonitor'
import { config } from '../config/index'

interface MonitoringService {
  start(): void
  stop(): void
  generateReport(): Promise<void>
  checkHealth(): Promise<boolean>
}

class ContextMonitoringService implements MonitoringService {
  private contextManager: ContextManager
  private monitor: AdvancedContextMonitor
  private isRunning: boolean = false
  private cronJobs: cron.ScheduledTask[] = []

  constructor() {
    this.contextManager = new ContextManager(config.context)
    this.monitor = new AdvancedContextMonitor(this.contextManager)
  }

  start(): void {
    console.log('🚀 Starting Context Monitoring Service...')
    this.isRunning = true

    // Setup monitoring intervals
    this.setupRealTimeMonitoring()
    this.setupScheduledTasks()
    this.setupAlertHandlers()

    console.log('✅ Context Monitoring Service started')
    console.log(`📊 Monitoring interval: ${config.monitoring.interval}ms`)
    console.log(`🔔 Alerts enabled: ${config.alerts.enabled}`)
  }

  stop(): void {
    console.log('🛑 Stopping Context Monitoring Service...')
    this.isRunning = false

    // Stop all cron jobs
    this.cronJobs.forEach((job) => job.stop())
    this.cronJobs = []

    console.log('✅ Context Monitoring Service stopped')
  }

  async generateReport(): Promise<void> {
    console.log('📈 Generating monitoring report...')

    try {
      const report = this.monitor.generateReport(24) // Last 24 hours
      const dashboard = this.monitor.getDashboardData()

      const reportData = {
        timestamp: new Date().toISOString(),
        summary: report,
        dashboard: dashboard,
        recommendations: this.generateRecommendations(report, dashboard),
      }

      // Save report
      const reportPath = path.join('data', 'reports', `report-${Date.now()}.json`)
      fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2))

      // Send alerts if needed
      if (report.alertCount > 5) {
        await this.sendAlert('high', `High alert count: ${report.alertCount} in 24h`)
      }

      console.log(`✅ Report generated: ${reportPath}`)

      // Log summary
      console.log('\n📊 24h Summary:')
      console.log(`- Average usage: ${report.avgTokenUsage.toFixed(1)}%`)
      console.log(`- Peak usage: ${report.peakTokenUsage.toFixed(1)}%`)
      console.log(`- Average response time: ${report.avgResponseTime}ms`)
      console.log(`- Total requests: ${report.totalRequests}`)
      console.log(`- Quality trend: ${report.qualityTrend}`)
    } catch (error) {
      console.error('❌ Failed to generate report:', error)
    }
  }

  async checkHealth(): Promise<boolean> {
    try {
      const status = this.monitor.getCurrentStatus()

      // Check if monitoring is healthy
      const isHealthy =
        status.metrics.usagePercentage < config.context.criticalThreshold &&
        status.metrics.responseTime < 10000 && // 10 seconds
        status.status !== 'critical'

      if (!isHealthy) {
        await this.sendAlert('critical', `System unhealthy: ${JSON.stringify(status)}`)
      }

      return isHealthy
    } catch (error) {
      console.error('❌ Health check failed:', error)
      return false
    }
  }

  private setupRealTimeMonitoring(): void {
    // Real-time monitoring every 30 seconds
    setInterval(async () => {
      if (!this.isRunning) return

      try {
        const status = this.monitor.getCurrentStatus()

        // Log current status
        if (config.server.logLevel === 'debug') {
          console.log(
            `📊 Status: ${status.status} (${status.metrics.usagePercentage.toFixed(1)}% usage)`
          )
        }

        // Check for alerts
        if (status.status !== 'healthy') {
          await this.handleStatusAlert(status)
        }
      } catch (error) {
        console.error('❌ Monitoring error:', error)
      }
    }, config.monitoring.interval)
  }

  private setupScheduledTasks(): Promise<void> {
    // Generate report every hour
    const reportJob = cron.schedule('0 * * * *', async () => {
      await this.generateReport()
    })

    // Health check every 5 minutes
    const healthJob = cron.schedule('*/5 * * * *', async () => {
      const isHealthy = await this.checkHealth()
      if (!isHealthy) {
        console.log('⚠️  Health check failed')
      }
    })

    // Cleanup old data daily at 2 AM
    const cleanupJob = cron.schedule('0 2 * * *', async () => {
      await this.cleanupOldData()
    })

    this.cronJobs.push(reportJob, healthJob, cleanupJob)
  }

  private setupAlertHandlers(): void {
    if (!config.alerts.enabled) return

    // Setup alert handlers
    this.monitor.on('alert', async (alert) => {
      await this.sendAlert(alert.severity, alert.message)
    })

    console.log('🔔 Alert handlers configured')
  }

  private async handleStatusAlert(status: any): Promise<void> {
    const message = `Context status: ${status.status} (${status.metrics.usagePercentage.toFixed(1)}% usage)`

    if (status.status === 'critical') {
      await this.sendAlert('critical', message)
    } else if (status.status === 'warning') {
      await this.sendAlert('warning', message)
    }
  }

  private async sendAlert(severity: 'warning' | 'critical', message: string): Promise<void> {
    console.log(`🚨 ${severity.toUpperCase()}: ${message}`)

    try {
      // Send to Slack if configured
      if (config.alerts.slackWebhook) {
        await this.sendSlackAlert(severity, message)
      }

      // Send email if configured
      if (config.alerts.email?.to) {
        await this.sendEmailAlert(severity, message)
      }
    } catch (error) {
      console.error('❌ Failed to send alert:', error)
    }
  }

  private async sendSlackAlert(severity: string, message: string): Promise<void> {
    const axios = require('axios')

    const payload = {
      text: `🚨 *${severity.toUpperCase()}* Context Management Alert`,
      attachments: [
        {
          color: severity === 'critical' ? 'danger' : 'warning',
          fields: [
            { title: 'Severity', value: severity, short: true },
            { title: 'Time', value: new Date().toISOString(), short: true },
            { title: 'Message', value: message, short: false },
          ],
        },
      ],
    }

    await axios.post(config.alerts.slackWebhook, payload)
  }

  private async sendEmailAlert(severity: string, message: string): Promise<void> {
    const nodemailer = require('nodemailer')

    const transporter = nodemailer.createTransporter({
      host: config.alerts.email.smtp.host,
      port: config.alerts.email.smtp.port,
      secure: false,
      auth: {
        user: config.alerts.email.smtp.user,
        pass: config.alerts.email.smtp.pass,
      },
    })

    const mailOptions = {
      from: config.alerts.email.smtp.user,
      to: config.alerts.email.to,
      subject: `Context Management ${severity.toUpperCase()} Alert`,
      html: `
        <h2>🚨 ${severity.toUpperCase()} Alert</h2>
        <p><strong>Time:</strong> ${new Date().toISOString()}</p>
        <p><strong>Message:</strong> ${message}</p>
        <hr>
        <p><small>This alert was generated by Context Management Tools</small></p>
      `,
    }

    await transporter.sendMail(mailOptions)
  }

  private generateRecommendations(report: any, dashboard: any): string[] {
    const recommendations: string[] = []

    if (report.avgTokenUsage > 80) {
      recommendations.push('Consider reducing context size or enabling compression')
    }

    if (report.avgResponseTime > 5000) {
      recommendations.push('Response times are slow, check for context overload')
    }

    if (report.qualityTrend === 'declining') {
      recommendations.push('Quality is declining, review context relevance')
    }

    if (report.alertCount > 10) {
      recommendations.push('High alert frequency, review system configuration')
    }

    if (recommendations.length === 0) {
      recommendations.push('System is performing well')
    }

    return recommendations
  }

  private async cleanupOldData(): Promise<void> {
    console.log('🧹 Cleaning up old monitoring data...')

    try {
      const retentionDays = config.monitoring.retentionDays
      const cutoffDate = new Date()
      cutoffDate.setDate(cutoffDate.getDate() - retentionDays)

      // Clean old reports
      const reportsDir = path.join('data', 'reports')
      if (fs.existsSync(reportsDir)) {
        const files = fs.readdirSync(reportsDir)
        for (const file of files) {
          const filePath = path.join(reportsDir, file)
          const stats = fs.statSync(filePath)

          if (stats.mtime < cutoffDate) {
            fs.unlinkSync(filePath)
            console.log(`🗑️  Deleted old report: ${file}`)
          }
        }
      }

      console.log('✅ Cleanup completed')
    } catch (error) {
      console.error('❌ Cleanup failed:', error)
    }
  }
}

// CLI interface
async function main() {
  const command = process.argv[2]
  const service = new ContextMonitoringService()

  switch (command) {
    case 'start':
      service.start()

      // Keep process running
      process.on('SIGINT', () => {
        console.log('\n🛑 Received SIGINT, stopping service...')
        service.stop()
        process.exit(0)
      })

      process.on('SIGTERM', () => {
        console.log('\n🛑 Received SIGTERM, stopping service...')
        service.stop()
        process.exit(0)
      })

      break

    case 'report':
      await service.generateReport()
      break

    case 'health':
      const isHealthy = await service.checkHealth()
      console.log(isHealthy ? '✅ Healthy' : '❌ Unhealthy')
      process.exit(isHealthy ? 0 : 1)
      break

    default:
      console.log('Usage: npm run monitor [start|report|health]')
      console.log('  start  - Start monitoring service')
      console.log('  report - Generate one-time report')
      console.log('  health - Check system health')
      process.exit(1)
  }
}

if (require.main === module) {
  main().catch(console.error)
}

export { ContextMonitoringService, MonitoringService }
