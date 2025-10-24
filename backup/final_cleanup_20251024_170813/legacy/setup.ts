#!/usr/bin/env ts-node

/**
 * Automated Setup Script for Context Management Tools
 * Handles installation, configuration, and initial setup
 */

import * as fs from 'fs'
import * as path from 'path'
import { execSync } from 'child_process'
import * as readline from 'readline'

interface SetupConfig {
  projectName: string
  environment: 'development' | 'staging' | 'production'
  enableMonitoring: boolean
  enableAlerts: boolean
  slackWebhook?: string
  emailConfig?: {
    smtpHost: string
    smtpPort: number
    user: string
    pass: string
    to: string
  }
  openaiApiKey?: string
  dbConfig?: {
    host: string
    port: number
    name: string
    user: string
    password: string
  }
}

class SetupManager {
  private rl: readline.Interface
  private config: Partial<SetupConfig> = {}

  constructor() {
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    })
  }

  async run(): Promise<void> {
    console.log('🚀 Context Management Tools Setup')
    console.log('==================================\n')

    try {
      await this.checkPrerequisites()
      await this.gatherConfiguration()
      await this.installDependencies()
      await this.setupConfiguration()
      await this.createDirectories()
      await this.setupDatabase()
      await this.setupMonitoring()
      await this.runTests()
      await this.createStartupScripts()

      console.log('\n✅ Setup completed successfully!')
      console.log('\nNext steps:')
      console.log('1. Review the generated configuration files')
      console.log('2. Update .env with your specific settings')
      console.log('3. Run: npm start to begin using the tools')
      console.log('4. Visit: http://localhost:3000 for the dashboard')
    } catch (error) {
      console.error('\n❌ Setup failed:', error)
      process.exit(1)
    } finally {
      this.rl.close()
    }
  }

  private async checkPrerequisites(): Promise<void> {
    console.log('📋 Checking prerequisites...')

    // Check Node.js version
    const nodeVersion = process.version
    const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0])

    if (majorVersion < 18) {
      throw new Error(`Node.js version 18+ required. Current: ${nodeVersion}`)
    }
    console.log(`✅ Node.js: ${nodeVersion}`)

    // Check npm
    try {
      execSync('npm --version', { stdio: 'pipe' })
      console.log('✅ npm: Available')
    } catch {
      throw new Error('npm is not available')
    }

    // Check Git
    try {
      execSync('git --version', { stdio: 'pipe' })
      console.log('✅ Git: Available')
    } catch {
      console.log('⚠️  Git: Not found (optional)')
    }

    console.log('')
  }

  private async gatherConfiguration(): Promise<void> {
    console.log('⚙️  Configuration setup\n')

    this.config.projectName = await this.askQuestion(
      'Project name (default: context-management): ',
      'context-management'
    )

    this.config.environment = (await this.askQuestion(
      'Environment (development/staging/production): ',
      'development'
    )) as 'development' | 'staging' | 'production'

    this.config.enableMonitoring =
      (await this.askQuestion('Enable monitoring? (y/n): ', 'y')) === 'y'

    if (this.config.enableMonitoring) {
      this.config.enableAlerts = (await this.askQuestion('Enable alerts? (y/n): ', 'y')) === 'y'

      if (this.config.enableAlerts) {
        this.config.slackWebhook =
          (await this.askQuestion('Slack webhook URL (optional): ', '')) || undefined

        if ((await this.askQuestion('Configure email alerts? (y/n): ', 'n')) === 'y') {
          this.config.emailConfig = {
            smtpHost: await this.askQuestion('SMTP host: ', 'smtp.gmail.com'),
            smtpPort: parseInt(await this.askQuestion('SMTP port: ', '587')),
            user: await this.askQuestion('Email user: ', ''),
            pass: await this.askQuestion('Email password: ', ''),
            to: await this.askQuestion('Alert recipient: ', ''),
          }
        }
      }
    }

    this.config.openaiApiKey =
      (await this.askQuestion('OpenAI API key (optional): ', '')) || undefined

    if (this.config.environment === 'production') {
      console.log('\n📊 Database configuration (production):')
      this.config.dbConfig = {
        host: await this.askQuestion('DB host: ', 'localhost'),
        port: parseInt(await this.askQuestion('DB port: ', '5432')),
        name: await this.askQuestion('DB name: ', 'context_management'),
        user: await this.askQuestion('DB user: ', 'postgres'),
        password: await this.askQuestion('DB password: ', ''),
      }
    }

    console.log('')
  }

  private async installDependencies(): Promise<void> {
    console.log('📦 Installing dependencies...')

    try {
      execSync('npm install', { stdio: 'inherit' })
      console.log('✅ Dependencies installed')
    } catch (error) {
      throw new Error('Failed to install dependencies')
    }

    console.log('')
  }

  private async setupConfiguration(): Promise<void> {
    console.log('🔧 Setting up configuration...')

    // Create .env file
    const envContent = this.generateEnvFile()
    fs.writeFileSync('.env', envContent)

    // Create config files
    await this.createConfigFiles()

    // Update package.json if needed
    await this.updatePackageJson()

    console.log('✅ Configuration created')
    console.log('')
  }

  private generateEnvFile(): string {
    const envVars = [
      `# Environment Configuration`,
      `NODE_ENV=${this.config.environment}`,
      `PROJECT_NAME=${this.config.projectName}`,
      ``,
      `# Context Management Configuration`,
      `CONTEXT_MAX_TOKENS=200000`,
      `CONTEXT_WARNING_THRESHOLD=0.8`,
      `CONTEXT_CRITICAL_THRESHOLD=0.95`,
      `CONTEXT_COMPRESSION_ENABLED=true`,
      `CONTEXT_CACHING_ENABLED=true`,
      ``,
      `# Monitoring Configuration`,
      `MONITORING_ENABLED=${this.config.enableMonitoring}`,
      `MONITORING_INTERVAL=30000`,
      `MONITORING_RETENTION_DAYS=30`,
      ``,
      `# Alert Configuration`,
      `ALERT_ENABLED=${this.config.enableAlerts}`,
      this.config.slackWebhook
        ? `ALERT_SLACK_WEBHOOK=${this.config.slackWebhook}`
        : '# ALERT_SLACK_WEBHOOK=',
      ``,
      `# API Configuration`,
      this.config.openaiApiKey
        ? `OPENAI_API_KEY=${this.config.openaiApiKey}`
        : '# OPENAI_API_KEY=your-api-key',
      `OPENAI_MODEL=gpt-4`,
      `OPENAI_MAX_TOKENS=4000`,
      ``,
      `# Application Configuration`,
      `PORT=3000`,
      `LOG_LEVEL=info`,
      `LOG_FILE=logs/app.log`,
      ``,
      `# Performance Configuration`,
      `COMPRESSION_THRESHOLD=0.7`,
      `CACHE_TTL=3600`,
      `MAX_CACHE_SIZE=1000`,
      `CLEANUP_INTERVAL=3600000`,
    ]

    if (this.config.emailConfig) {
      envVars.push(
        ``,
        `# Email Configuration`,
        `ALERT_EMAIL_SMTP_HOST=${this.config.emailConfig.smtpHost}`,
        `ALERT_EMAIL_SMTP_PORT=${this.config.emailConfig.smtpPort}`,
        `ALERT_EMAIL_USER=${this.config.emailConfig.user}`,
        `ALERT_EMAIL_PASS=${this.config.emailConfig.pass}`,
        `ALERT_EMAIL_TO=${this.config.emailConfig.to}`
      )
    }

    if (this.config.dbConfig) {
      envVars.push(
        ``,
        `# Database Configuration`,
        `DB_HOST=${this.config.dbConfig.host}`,
        `DB_PORT=${this.config.dbConfig.port}`,
        `DB_NAME=${this.config.dbConfig.name}`,
        `DB_USER=${this.config.dbConfig.user}`,
        `DB_PASSWORD=${this.config.dbConfig.password}`
      )
    }

    return envVars.join('\n')
  }

  private async createConfigFiles(): Promise<void> {
    // Create main config file
    const configDir = 'config'
    if (!fs.existsSync(configDir)) {
      fs.mkdirSync(configDir, { recursive: true })
    }

    const configContent = `
export const config = {
  environment: '${this.config.environment}',
  projectName: '${this.config.projectName}',
  
  context: {
    maxTokens: parseInt(process.env.CONTEXT_MAX_TOKENS || '200000'),
    warningThreshold: parseFloat(process.env.CONTEXT_WARNING_THRESHOLD || '0.8'),
    criticalThreshold: parseFloat(process.env.CONTEXT_CRITICAL_THRESHOLD || '0.95'),
    compressionEnabled: process.env.CONTEXT_COMPRESSION_ENABLED === 'true',
    cachingEnabled: process.env.CONTEXT_CACHING_ENABLED === 'true'
  },
  
  monitoring: {
    enabled: process.env.MONITORING_ENABLED === 'true',
    interval: parseInt(process.env.MONITORING_INTERVAL || '30000'),
    retentionDays: parseInt(process.env.MONITORING_RETENTION_DAYS || '30')
  },
  
  alerts: {
    enabled: process.env.ALERT_ENABLED === 'true',
    slackWebhook: process.env.ALERT_SLACK_WEBHOOK,
    email: {
      smtp: {
        host: process.env.ALERT_EMAIL_SMTP_HOST,
        port: parseInt(process.env.ALERT_EMAIL_SMTP_PORT || '587'),
        user: process.env.ALERT_EMAIL_USER,
        pass: process.env.ALERT_EMAIL_PASS
      },
      to: process.env.ALERT_EMAIL_TO
    }
  },
  
  api: {
    openai: {
      apiKey: process.env.OPENAI_API_KEY,
      model: process.env.OPENAI_MODEL || 'gpt-4',
      maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS || '4000')
    }
  },
  
  server: {
    port: parseInt(process.env.PORT || '3000'),
    logLevel: process.env.LOG_LEVEL || 'info',
    logFile: process.env.LOG_FILE || 'logs/app.log'
  },
  
  performance: {
    compressionThreshold: parseFloat(process.env.COMPRESSION_THRESHOLD || '0.7'),
    cacheTTL: parseInt(process.env.CACHE_TTL || '3600'),
    maxCacheSize: parseInt(process.env.MAX_CACHE_SIZE || '1000'),
    cleanupInterval: parseInt(process.env.CLEANUP_INTERVAL || '3600000')
  }
};
`

    fs.writeFileSync(path.join(configDir, 'index.ts'), configContent)

    // Create environment-specific configs
    const envConfigs = {
      development: { logLevel: 'debug', monitoring: true },
      staging: { logLevel: 'info', monitoring: true },
      production: { logLevel: 'warn', monitoring: true },
    }

    for (const [env, settings] of Object.entries(envConfigs)) {
      const envConfigPath = path.join(configDir, `${env}.ts`)
      const envConfigContent = `
import { config } from './index';

export const ${env}Config = {
  ...config,
  server: {
    ...config.server,
    logLevel: '${settings.logLevel}'
  },
  monitoring: {
    ...config.monitoring,
    enabled: ${settings.monitoring}
  }
};
`
      fs.writeFileSync(envConfigPath, envConfigContent)
    }
  }

  private async updatePackageJson(): Promise<void> {
    const packageJsonPath = 'package.json'
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'))

    // Add scripts for the specific project
    packageJson.scripts = {
      ...packageJson.scripts,
      'setup:prod': 'NODE_ENV=production npm run build && npm start',
      'monitor:prod': 'NODE_ENV=production npm run monitor',
      'health-check': 'ts-node scripts/health-check.ts',
      'backup-config': 'tar -czf config-backup-$(date +%Y%m%d).tar.gz config/ .env',
      'restore-config': 'tar -xzf config-backup-*.tar.gz',
    }

    fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2))
  }

  private async createDirectories(): Promise<void> {
    console.log('📁 Creating directories...')

    const directories = [
      'logs',
      'data',
      'data/cache',
      'data/metrics',
      'data/reports',
      'scripts',
      'tests',
      'tests/integration',
      'tests/unit',
    ]

    for (const dir of directories) {
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true })
        console.log(`✅ Created: ${dir}`)
      }
    }

    // Create .gitkeep files
    for (const dir of directories) {
      const gitkeepPath = path.join(dir, '.gitkeep')
      if (!fs.existsSync(gitkeepPath)) {
        fs.writeFileSync(gitkeepPath, '')
      }
    }

    console.log('')
  }

  private async setupDatabase(): Promise<void> {
    if (this.config.environment !== 'production' || !this.config.dbConfig) {
      console.log('🗄️  Database setup skipped (not required)')
      console.log('')
      return
    }

    console.log('🗄️  Setting up database...')

    // Create database initialization script
    const initScript = `
-- Context Management Database Schema
-- Generated for ${this.config.projectName}

CREATE DATABASE IF NOT EXISTS ${this.config.dbConfig.name};

\\c ${this.config.dbConfig.name};

-- Metrics table
CREATE TABLE IF NOT EXISTS metrics (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  project_name VARCHAR(255),
  total_tokens INTEGER,
  usage_percentage DECIMAL(5,2),
  response_time INTEGER,
  quality_score DECIMAL(3,2),
  alert_level VARCHAR(20),
  active_chunks INTEGER
);

-- Alerts table
CREATE TABLE IF NOT EXISTS alerts (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  project_name VARCHAR(255),
  severity VARCHAR(20),
  message TEXT,
  metadata JSONB
);

-- Reports table
CREATE TABLE IF NOT EXISTS reports (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  project_name VARCHAR(255),
  period_hours INTEGER,
  avg_token_usage DECIMAL(5,2),
  peak_token_usage DECIMAL(5,2),
  avg_response_time INTEGER,
  total_requests INTEGER,
  alert_count INTEGER,
  quality_trend VARCHAR(20),
  recommendations JSONB
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_metrics_timestamp ON metrics(timestamp);
CREATE INDEX IF NOT EXISTS idx_alerts_timestamp ON alerts(timestamp);
CREATE INDEX IF NOT EXISTS idx_reports_timestamp ON reports(timestamp);
`

    fs.writeFileSync('scripts/init-db.sql', initScript)
    console.log('✅ Database script created')
    console.log('⚠️  Please run the init-db.sql script manually on your database server')
    console.log('')
  }

  private async setupMonitoring(): Promise<void> {
    if (!this.config.enableMonitoring) {
      console.log('📊 Monitoring setup skipped')
      console.log('')
      return
    }

    console.log('📊 Setting up monitoring...')

    // Create monitoring configuration
    const monitoringConfig = {
      enabled: true,
      interval: 30000,
      retention: {
        metrics: 30, // days
        alerts: 90, // days
        reports: 365, // days
      },
      alerts: {
        thresholds: {
          tokenWarning: 0.8,
          tokenCritical: 0.95,
          responseTimeSlow: 5000,
          qualityScoreMin: 0.7,
        },
        channels: {
          slack: !!this.config.slackWebhook,
          email: !!this.config.emailConfig,
        },
      },
      dashboard: {
        enabled: true,
        refreshInterval: 5000,
        maxDataPoints: 1000,
      },
    }

    fs.writeFileSync('config/monitoring.json', JSON.stringify(monitoringConfig, null, 2))

    console.log('✅ Monitoring configuration created')
    console.log('')
  }

  private async runTests(): Promise<void> {
    console.log('🧪 Running initial tests...')

    try {
      // Build the project first
      execSync('npm run build', { stdio: 'pipe' })

      // Run basic tests
      execSync('npm test -- --passWithNoTests', { stdio: 'pipe' })
      console.log('✅ Tests passed')
    } catch (error) {
      console.log('⚠️  Some tests failed, but setup can continue')
    }

    console.log('')
  }

  private async createStartupScripts(): Promise<void> {
    console.log('🚀 Creating startup scripts...')

    // Create startup script
    const startupScript = `#!/bin/bash

# Context Management Tools Startup Script
# Generated for ${this.config.projectName}

echo "🚀 Starting Context Management Tools..."

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Start the application
if [ "$NODE_ENV" = "production" ]; then
    echo "🏭 Production mode"
    npm run setup:prod
else
    echo "🛠️  Development mode"
    npm run dev
fi
`

    fs.writeFileSync('start.sh', startupScript)
    fs.chmodSync('start.sh', '755')

    // Create health check script
    const healthCheckScript = `#!/bin/bash

# Health Check Script for Context Management Tools

echo "🔍 Performing health check..."

# Check if the application is running
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Application is healthy"
    exit 0
else
    echo "❌ Application is not responding"
    exit 1
fi
`

    fs.writeFileSync('scripts/health-check.sh', healthCheckScript)
    fs.chmodSync('scripts/health-check.sh', '755')

    console.log('✅ Startup scripts created')
    console.log('')
  }

  private async askQuestion(question: string, defaultValue: string = ''): Promise<string> {
    return new Promise((resolve) => {
      this.rl.question(`${question}${defaultValue ? `(${defaultValue}) ` : ''}`, (answer) => {
        resolve(answer || defaultValue)
      })
    })
  }
}

// Run the setup
if (require.main === module) {
  const setup = new SetupManager()
  setup.run().catch(console.error)
}

export { SetupManager }
