/**
 * Main Configuration File for Context Management Tools
 * Centralizes all configuration settings
 */

export const config = {
  environment: process.env['NODE_ENV'] || 'development',
  projectName: process.env['PROJECT_NAME'] || 'context-management',

  context: {
    maxTokens: parseInt(process.env['CONTEXT_MAX_TOKENS'] || '200000'),
    warningThreshold: parseFloat(process.env['CONTEXT_WARNING_THRESHOLD'] || '0.8'),
    criticalThreshold: parseFloat(process.env['CONTEXT_CRITICAL_THRESHOLD'] || '0.95'),
    compressionEnabled: process.env['CONTEXT_COMPRESSION_ENABLED'] === 'true',
    cachingEnabled: process.env['CONTEXT_CACHING_ENABLED'] === 'true',
  },

  monitoring: {
    enabled: process.env['MONITORING_ENABLED'] === 'true',
    interval: parseInt(process.env['MONITORING_INTERVAL'] || '30000'),
    retentionDays: parseInt(process.env['MONITORING_RETENTION_DAYS'] || '30'),
  },

  alerts: {
    enabled: process.env['ALERT_ENABLED'] === 'true',
    slackWebhook: process.env['ALERT_SLACK_WEBHOOK'],
    email: {
      smtp: {
        host: process.env['ALERT_EMAIL_SMTP_HOST'],
        port: parseInt(process.env['ALERT_EMAIL_SMTP_PORT'] || '587'),
        user: process.env['ALERT_EMAIL_USER'],
        pass: process.env['ALERT_EMAIL_PASS'],
      },
      to: process.env['ALERT_EMAIL_TO'],
    },
  },

  api: {
    openai: {
      apiKey: process.env['OPENAI_API_KEY'],
      model: process.env['OPENAI_MODEL'] || 'gpt-4',
      maxTokens: parseInt(process.env['OPENAI_MAX_TOKENS'] || '4000'),
    },
  },

  server: {
    port: parseInt(process.env['PORT'] || '3000'),
    logLevel: process.env['LOG_LEVEL'] || 'info',
    logFile: process.env['LOG_FILE'] || 'logs/app.log',
  },

  performance: {
    compressionThreshold: parseFloat(process.env['COMPRESSION_THRESHOLD'] || '0.7'),
    cacheTTL: parseInt(process.env['CACHE_TTL'] || '3600'),
    maxCacheSize: parseInt(process.env['MAX_CACHE_SIZE'] || '1000'),
    cleanupInterval: parseInt(process.env['CLEANUP_INTERVAL'] || '3600000'),
  },
}

export default config
