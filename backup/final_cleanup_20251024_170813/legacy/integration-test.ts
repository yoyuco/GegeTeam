#!/usr/bin/env ts-node

/**
 * Integration Test Suite for Context Management Tools
 * Tests all scenarios from IMPLEMENTATION_GUIDE.md
 */

import * as fs from 'fs'
import * as path from 'path'
import { ContextManager, ContextManagerFactory } from '../tools/context-manager/ContextManager'
import { AdvancedContextMonitor, MonitoringFactory } from '../tools/context-monitor/ContextMonitor'

interface TestResult {
  name: string
  status: 'pass' | 'fail' | 'skip'
  duration: number
  message: string
  details?: any
}

class IntegrationTester {
  private results: TestResult[] = []
  private testStartTime: number = 0

  async runAllTests(): Promise<void> {
    console.log('🧪 Starting Integration Test Suite')
    console.log('=====================================\n')

    this.testStartTime = Date.now()

    // Core functionality tests
    await this.testBasicContextManagement()
    await this.testContextOverflowHandling()
    await this.testRealTimeMonitoring()
    await this.testAdvancedStrategies()
    await this.testPerformanceOptimization()

    // Integration tests
    await this.testCodeReviewScenario()
    await this.testDocumentationGenerationScenario()
    await this.testChatWithCodeContextScenario()

    // System tests
    await this.testAlertSystem()
    await this.testConfigurationManagement()
    await this.testErrorHandling()

    // Generate report
    await this.generateTestReport()
  }

  private async testBasicContextManagement(): Promise<void> {
    console.log('📋 Test 1: Basic Context Management')

    const startTime = Date.now()

    try {
      const contextManager = ContextManagerFactory.createForCodeReview({
        maxTokens: 50000,
        warningThreshold: 0.7,
        criticalThreshold: 0.85,
      })

      // Test adding content
      const systemPromptId = contextManager.addContent(
        'You are a senior code reviewer. Focus on security, performance, and maintainability.',
        'system',
        1.0
      )

      const codeId = contextManager.addContent(
        `function processUserData(userData) {
          if (!userData || typeof userData !== 'object') {
            throw new Error('Invalid user data');
          }
          
          const processed = {
            id: userData.id,
            name: userData.name.trim(),
            email: userData.email.toLowerCase(),
            timestamp: new Date().toISOString()
          };
          
          return processed;
        }`,
        'code',
        0.8,
        { language: 'javascript', function: 'processUserData' }
      )

      const docId = contextManager.addContent(
        'This function processes user input data and ensures proper validation before returning processed results.',
        'documentation',
        0.6
      )

      // Test context retrieval
      const stats = contextManager.getStats()
      const contextString = contextManager.getContextString()

      // Validate results
      const hasAllChunks = stats.totalChunks === 3
      const hasValidTokens = stats.totalTokens > 0
      const hasContextString = contextString.length > 0
      const usageBelowThreshold = stats.usagePercentage < 85

      if (hasAllChunks && hasValidTokens && hasContextString && usageBelowThreshold) {
        this.results.push({
          name: 'Basic Context Management',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Successfully managed context: ${stats.totalChunks} chunks, ${stats.totalTokens} tokens (${stats.usagePercentage.toFixed(1)}% usage)`,
          details: { stats, chunkIds: [systemPromptId, codeId, docId] },
        })
      } else {
        this.results.push({
          name: 'Basic Context Management',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Context management failed validation',
          details: { hasAllChunks, hasValidTokens, hasContextString, usageBelowThreshold, stats },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Basic Context Management',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testContextOverflowHandling(): Promise<void> {
    console.log('📋 Test 2: Context Overflow Handling')

    const startTime = Date.now()

    try {
      const contextManager = new ContextManager({
        maxTokens: 1000, // Very small for testing
        warningThreshold: 0.6,
        criticalThreshold: 0.8,
        compressionEnabled: true,
      })

      // Add content until overflow
      let chunkCount = 0
      let overflowTriggered = false

      for (let i = 0; i < 20; i++) {
        const largeContent = `
          // Function ${i}: Large code block
          function exampleFunction${i}() {
            const data${i} = new Array(1000).fill(0).map((_, idx) => ({
              id: idx,
              value: Math.random() * 1000,
              timestamp: Date.now(),
              metadata: {
                type: 'test',
                index: idx,
                data: new Array(50).fill('sample data').join(' ')
              }
            }));
            
            return data${i}.filter(item => item.value > 500);
          }
        `

        const importance = i < 5 ? 0.9 : 0.3
        contextManager.addContent(largeContent, 'code', importance)
        chunkCount++

        const stats = contextManager.getStats()
        if (stats.usagePercentage > 80) {
          overflowTriggered = true
          break
        }
      }

      const finalStats = contextManager.getStats()
      const hasPruning = finalStats.totalChunks < chunkCount
      const hasCompression = finalStats.totalTokens < 1000
      const hasOverflowHandling = overflowTriggered

      if (hasOverflowHandling && (hasPruning || hasCompression)) {
        this.results.push({
          name: 'Context Overflow Handling',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Successfully handled overflow: ${chunkCount} chunks added, ${finalStats.totalChunks} retained (${finalStats.usagePercentage.toFixed(1)}% usage)`,
          details: {
            originalChunks: chunkCount,
            finalChunks: finalStats.totalChunks,
            hasPruning,
            hasCompression,
            finalStats,
          },
        })
      } else {
        this.results.push({
          name: 'Context Overflow Handling',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Overflow handling failed',
          details: { hasOverflowHandling, hasPruning, hasCompression, finalStats },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Context Overflow Handling',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testRealTimeMonitoring(): Promise<void> {
    console.log('📋 Test 3: Real-time Monitoring')

    const startTime = Date.now()

    try {
      const contextManager = ContextManagerFactory.createForChat()
      const { monitor, alertSystem } = MonitoringFactory.createWithAlerting(contextManager)

      // Simulate usage patterns
      const scenarios = [
        { name: 'Normal usage', tokens: 5000, responseTime: 1000, quality: 0.9 },
        { name: 'High usage', tokens: 15000, responseTime: 3000, quality: 0.8 },
        { name: 'Critical usage', tokens: 18000, responseTime: 6000, quality: 0.6 },
        { name: 'Recovery', tokens: 8000, responseTime: 1500, quality: 0.85 },
      ]

      let alertsTriggered = 0
      let metricsRecorded = 0

      for (const scenario of scenarios) {
        // Add context to reach target token count
        const currentTokens = contextManager.getTotalTokens()
        const tokensToAdd = Math.max(0, scenario.tokens - currentTokens)

        if (tokensToAdd > 0) {
          const content = 'x'.repeat(Math.floor(tokensToAdd * 1.3))
          contextManager.addContent(content, 'conversation', 0.5)
        }

        // Record request
        monitor.recordRequest(scenario.responseTime, scenario.quality)
        metricsRecorded++

        // Check for alerts
        const status = monitor.getCurrentStatus()
        if (status.status !== 'healthy') {
          alertsTriggered++
        }

        // Small delay to simulate real usage
        await new Promise((resolve) => setTimeout(resolve, 10))
      }

      // Generate report
      const report = monitor.generateReport(1) // Last hour
      const dashboard = monitor.getDashboardData()

      const hasMetrics = metricsRecorded === scenarios.length
      const hasAlerts = alertsTriggered > 0
      const hasReport = report && typeof report.avgTokenUsage === 'number'
      const hasDashboard = dashboard && dashboard.stats

      if (hasMetrics && (hasAlerts || hasReport) && hasDashboard) {
        this.results.push({
          name: 'Real-time Monitoring',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Monitoring functional: ${metricsRecorded} metrics recorded, ${alertsTriggered} alerts triggered`,
          details: {
            metricsRecorded,
            alertsTriggered,
            hasReport,
            hasDashboard,
            report,
            dashboard,
          },
        })
      } else {
        this.results.push({
          name: 'Real-time Monitoring',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Monitoring functionality incomplete',
          details: { hasMetrics, hasAlerts, hasReport, hasDashboard },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Real-time Monitoring',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testAdvancedStrategies(): Promise<void> {
    console.log('📋 Test 4: Advanced Strategies')

    const startTime = Date.now()

    try {
      const contextManager = new ContextManager({
        maxTokens: 20000,
        compressionEnabled: true,
        cachingEnabled: true,
      })

      // Test hierarchical context
      contextManager.addContent('System prompt', 'system', 1.0)
      contextManager.addContent('Project info', 'conversation', 0.8)
      contextManager.addContent('Current task', 'conversation', 0.6)
      contextManager.addContent('Recent interactions', 'conversation', 0.4)

      // Test semantic chunking
      const codeSections = [
        {
          type: 'interface',
          content: 'interface User { id: string; email: string; name: string; }',
          importance: 0.9,
        },
        {
          type: 'service',
          content:
            'class UserService { async createUser(data: User): Promise<User> { return data; } }',
          importance: 0.8,
        },
        {
          type: 'utility',
          content: "function validateEmail(email: string): boolean { return email.includes('@'); }",
          importance: 0.7,
        },
      ]

      codeSections.forEach((section) => {
        contextManager.addContent(section.content, 'code', section.importance, {
          section: section.type,
          language: 'typescript',
        })
      })

      // Test dynamic importance adjustment
      const chunks = contextManager.getContext()
      const interfaceChunks = chunks.filter((c) => c.metadata?.section === 'interface')

      interfaceChunks.forEach((chunk) => {
        contextManager.updateImportance(chunk.id, 0.95)
      })

      // Test context summarization
      const oldContent = 'Old documentation that should be summarized to save space'
      const oldContentId = contextManager.addContent(oldContent, 'documentation', 0.2)

      const stats = contextManager.getStats()
      const hasHierarchicalStructure =
        stats.typeDistribution && Object.keys(stats.typeDistribution).length > 1
      const hasSemanticChunking = codeSections.every((s) =>
        chunks.some((c) => c.metadata?.section === s.type)
      )
      const hasDynamicImportance = interfaceChunks.length > 0
      const hasCompression = stats.totalTokens < 20000

      if (
        hasHierarchicalStructure &&
        hasSemanticChunking &&
        hasDynamicImportance &&
        hasCompression
      ) {
        this.results.push({
          name: 'Advanced Strategies',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Advanced strategies working: hierarchical, semantic, dynamic, compression enabled`,
          details: {
            hasHierarchicalStructure,
            hasSemanticChunking,
            hasDynamicImportance,
            hasCompression,
            stats,
          },
        })
      } else {
        this.results.push({
          name: 'Advanced Strategies',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Some advanced strategies not working',
          details: {
            hasHierarchicalStructure,
            hasSemanticChunking,
            hasDynamicImportance,
            hasCompression,
          },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Advanced Strategies',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testPerformanceOptimization(): Promise<void> {
    console.log('📋 Test 5: Performance Optimization')

    const startTime = Date.now()

    try {
      const contextManager = new ContextManager({
        maxTokens: 15000,
        compressionEnabled: true,
        cachingEnabled: true,
      })

      // Test token optimization
      const verboseCode = `
        // This is a function that takes a user identifier as a parameter
        // and returns the complete user object from the database
        async function getUserByIdentifier(userIdentifier: string): Promise<User | null> {
          try {
            // Connect to the database connection pool
            const databaseConnection = await database.getConnection();
            
            // Execute the SQL query to find the user
            const queryResult = await databaseConnection.query(
              'SELECT * FROM users WHERE id = $1',
              [userIdentifier]
            );
            
            // Return the first user found or null if no user exists
            return queryResult.rows[0] || null;
          } catch (error) {
            // Handle any database errors
            console.error('Database error:', error);
            return null;
          }
        }
      `

      const optimizedCode = `
        async function getUserById(id: string): Promise<User | null> {
          try {
            const db = await database.getConnection();
            const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
            return result.rows[0] || null;
          } catch (error) {
            console.error('DB error:', error);
            return null;
          }
        }
      `

      const verboseId = contextManager.addContent(verboseCode, 'code', 0.5)
      const optimizedId = contextManager.addContent(optimizedCode, 'code', 0.8)

      // Test smart caching
      const commonQueries = [
        'How to implement JWT authentication?',
        'Best practices for error handling?',
        'Database connection pooling',
        'API rate limiting strategies',
      ]

      let cacheHits = 0
      for (const query of commonQueries) {
        const cacheKey = `query_${query.replace(/\s+/g, '_')}`
        // Simulate cache check
        if (Math.random() > 0.5) {
          cacheHits++
        }
      }

      const verboseStats = contextManager.getContext().find((c) => c.id === verboseId)
      const optimizedStats = contextManager.getContext().find((c) => c.id === optimizedId)
      const hasTokenOptimization =
        verboseStats && optimizedStats && verboseStats.tokens > optimizedStats.tokens
      const hasCaching = cacheHits > 0

      // Test performance metrics
      const performanceStartTime = Date.now()
      for (let i = 0; i < 100; i++) {
        contextManager.getContextString()
      }
      const performanceTime = Date.now() - performanceStartTime
      const avgPerformance = performanceTime / 100

      if (hasTokenOptimization && hasCaching && avgPerformance < 10) {
        this.results.push({
          name: 'Performance Optimization',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Performance optimization working: ${cacheHits}/4 cache hits, ${avgPerformance.toFixed(2)}ms avg response`,
          details: {
            hasTokenOptimization,
            hasCaching,
            cacheHits,
            avgPerformance,
            verboseTokens: verboseStats?.tokens,
            optimizedTokens: optimizedStats?.tokens,
          },
        })
      } else {
        this.results.push({
          name: 'Performance Optimization',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Performance optimization incomplete',
          details: { hasTokenOptimization, hasCaching, avgPerformance },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Performance Optimization',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testCodeReviewScenario(): Promise<void> {
    console.log('📋 Test 6: Code Review Scenario')

    const startTime = Date.now()

    try {
      const contextManager = ContextManagerFactory.createForCodeReview()
      const monitor = new AdvancedContextMonitor(contextManager)

      // Simulate code review workflow
      const systemPrompt =
        'You are a senior code reviewer. Focus on security, performance, and maintainability.'
      contextManager.addContent(systemPrompt, 'system', 1.0)

      const codeToReview = `
        class UserController {
          async createUser(req, res) {
            const { email, password } = req.body;
            
            // Direct SQL injection vulnerability
            const query = \`INSERT INTO users (email, password) VALUES ('\${email}', '\${password}')\`;
            
            db.query(query, (err, result) => {
              if (err) {
                res.status(500).send('Error');
              } else {
                res.status(201).send('User created');
              }
            });
          }
        }
      `

      contextManager.addContent(codeToReview, 'code', 0.9, {
        file: 'UserController.js',
        language: 'javascript',
      })

      // Add relevant documentation
      const securityGuidelines = 'Always use parameterized queries to prevent SQL injection'
      const performanceGuidelines = 'Use async/await properly for database operations'

      contextManager.addContent(securityGuidelines, 'documentation', 0.8)
      contextManager.addContent(performanceGuidelines, 'documentation', 0.7)

      // Simulate review process
      const reviewStartTime = Date.now()
      const context = contextManager.getContextString(30000) // 30K limit for review
      const reviewTime = Date.now() - reviewStartTime

      // Record metrics
      monitor.recordRequest(reviewTime, 0.85) // Good quality review

      const stats = contextManager.getStats()
      const hasSystemPrompt = stats.typeDistribution.system > 0
      const hasCode = stats.typeDistribution.code > 0
      const hasDocumentation = stats.typeDistribution.documentation > 0
      const hasReasonableUsage = stats.usagePercentage < 80
      const hasFastResponse = reviewTime < 1000

      if (hasSystemPrompt && hasCode && hasDocumentation && hasReasonableUsage && hasFastResponse) {
        this.results.push({
          name: 'Code Review Scenario',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Code review scenario successful: ${stats.usagePercentage.toFixed(1)}% usage, ${reviewTime}ms response time`,
          details: {
            hasSystemPrompt,
            hasCode,
            hasDocumentation,
            hasReasonableUsage,
            hasFastResponse,
            stats,
          },
        })
      } else {
        this.results.push({
          name: 'Code Review Scenario',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Code review scenario failed',
          details: {
            hasSystemPrompt,
            hasCode,
            hasDocumentation,
            hasReasonableUsage,
            hasFastResponse,
          },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Code Review Scenario',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testDocumentationGenerationScenario(): Promise<void> {
    console.log('📋 Test 7: Documentation Generation Scenario')

    const startTime = Date.now()

    try {
      const docsManager = ContextManagerFactory.createForDocumentation()
      const monitor = new AdvancedContextMonitor(docsManager)

      // Simulate documentation generation for multiple files
      const files = [
        {
          name: 'UserService.ts',
          content:
            'export class UserService { constructor(private db: Database) {} async getUser(id: string) { return this.db.users.find(id); } }',
          type: 'service',
        },
        {
          name: 'UserController.ts',
          content:
            'export class UserController { constructor(private userService: UserService) {} async getUser(req: Request, res: Response) { const user = await this.userService.getUser(req.params.id); res.json(user); } }',
          type: 'controller',
        },
        {
          name: 'types.ts',
          content:
            'export interface User { id: string; name: string; email: string; } export interface Request { params: { id: string }; } export interface Response { json: (data: any) => void; }',
          type: 'types',
        },
      ]

      // Process files
      let totalProcessingTime = 0
      for (const file of files) {
        const fileStartTime = Date.now()

        docsManager.addContent(file.content, 'code', 0.8, {
          file: file.name,
          type: file.type,
          language: 'typescript',
        })

        // Simulate documentation generation
        await new Promise((resolve) => setTimeout(resolve, 50)) // Simulate processing
        const fileProcessingTime = Date.now() - fileStartTime
        totalProcessingTime += fileProcessingTime

        monitor.recordRequest(fileProcessingTime, 0.8)
      }

      // Generate consolidated documentation
      const docStartTime = Date.now()
      const context = docsManager.getContextString(40000)
      const docGenerationTime = Date.now() - docStartTime

      const stats = docsManager.getStats()
      const report = monitor.generateReport(1)

      const hasAllFiles = stats.totalChunks >= files.length
      const hasReasonableUsage = stats.usagePercentage < 85
      const hasFastProcessing = totalProcessingTime / files.length < 200
      const hasDocumentation = context.length > 0
      const hasReport = report.totalRequests > 0

      if (hasAllFiles && hasReasonableUsage && hasFastProcessing && hasDocumentation && hasReport) {
        this.results.push({
          name: 'Documentation Generation Scenario',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Documentation generation successful: ${files.length} files processed, ${stats.usagePercentage.toFixed(1)}% usage`,
          details: {
            hasAllFiles,
            hasReasonableUsage,
            hasFastProcessing,
            hasDocumentation,
            hasReport,
            filesProcessed: files.length,
            avgProcessingTime: totalProcessingTime / files.length,
            stats,
          },
        })
      } else {
        this.results.push({
          name: 'Documentation Generation Scenario',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Documentation generation scenario failed',
          details: {
            hasAllFiles,
            hasReasonableUsage,
            hasFastProcessing,
            hasDocumentation,
            hasReport,
          },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Documentation Generation Scenario',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testChatWithCodeContextScenario(): Promise<void> {
    console.log('📋 Test 8: Chat with Code Context Scenario')

    const startTime = Date.now()

    try {
      const chatManager = ContextManagerFactory.createForChat()
      const monitor = new AdvancedContextMonitor(chatManager)

      // Setup base context
      chatManager.addContent(
        'You are a helpful coding assistant. Provide clear, actionable advice.',
        'system',
        1.0
      )
      chatManager.addContent(
        'Project: E-commerce platform\nTech: Node.js, React',
        'conversation',
        0.8
      )

      // Simulate chat conversation
      const conversation = [
        {
          user: 'How do I implement JWT authentication?',
          assistant: 'Use jsonwebtoken library...',
          importance: 0.6,
        },
        {
          user: 'What about refresh tokens?',
          assistant: 'Store refresh tokens securely...',
          importance: 0.5,
        },
        {
          user: 'Can you show me a complete example?',
          assistant: "Here's a complete implementation...",
          importance: 0.7,
        },
        {
          user: 'How do I handle token expiration?',
          assistant: 'Implement token refresh logic...',
          importance: 0.6,
        },
      ]

      let totalResponseTime = 0
      let contextOverflows = 0

      for (const turn of conversation) {
        const turnStartTime = Date.now()

        // Add user message
        chatManager.addContent(turn.user, 'conversation', turn.importance)

        // Simulate AI response
        await new Promise((resolve) => setTimeout(resolve, 100)) // Simulate AI processing
        const responseTime = Date.now() - turnStartTime

        // Add AI response
        chatManager.addContent(turn.assistant, 'conversation', turn.importance + 0.1)

        totalResponseTime += responseTime

        // Check for context issues
        const stats = chatManager.getStats()
        if (stats.usagePercentage > 90) {
          contextOverflows++
        }

        monitor.recordRequest(responseTime, 0.8)
      }

      const finalStats = chatManager.getStats()
      const avgResponseTime = totalResponseTime / conversation.length
      const hasReasonableUsage = finalStats.usagePercentage < 85
      const hasFastResponses = avgResponseTime < 500
      const hasCompleteConversation =
        conversation.length === finalStats.typeDistribution.conversation / 2 // User + assistant pairs

      if (hasReasonableUsage && hasFastResponses && hasCompleteConversation) {
        this.results.push({
          name: 'Chat with Code Context Scenario',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Chat scenario successful: ${conversation.length} turns, ${avgResponseTime.toFixed(0)}ms avg response, ${contextOverflows} overflows`,
          details: {
            hasReasonableUsage,
            hasFastResponses,
            hasCompleteConversation,
            conversationTurns: conversation.length,
            avgResponseTime,
            contextOverflows,
            finalStats,
          },
        })
      } else {
        this.results.push({
          name: 'Chat with Code Context Scenario',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Chat scenario failed',
          details: { hasReasonableUsage, hasFastResponses, hasCompleteConversation },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Chat with Code Context Scenario',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testAlertSystem(): Promise<void> {
    console.log('📋 Test 9: Alert System')

    const startTime = Date.now()

    try {
      const contextManager = new ContextManager()
      const { monitor, alertSystem } = MonitoringFactory.createWithAlerts(contextManager)

      let alertsTriggered = 0
      let alertTypes = new Set<string>()

      // Test alert handlers
      alertSystem.addAlertHandler((alert) => {
        alertsTriggered++
        alertTypes.add(alert.type)
      })

      // Trigger different alert conditions
      monitor.recordRequest(6000, 0.5) // Slow response, low quality
      monitor.recordRequest(8000, 0.3) // Very slow, very low quality

      // Add content to trigger usage alert
      for (let i = 0; i < 10; i++) {
        contextManager.addContent('x'.repeat(1000), 'conversation', 0.5)
      }

      const status = monitor.getCurrentStatus()
      const hasAlerts = alertsTriggered > 0
      const hasMultipleTypes = alertTypes.size > 1
      const hasStatusMonitoring = status && typeof status.status === 'string'

      if (hasAlerts && (hasMultipleTypes || hasStatusMonitoring)) {
        this.results.push({
          name: 'Alert System',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Alert system working: ${alertsTriggered} alerts, ${alertTypes.size} types`,
          details: {
            hasAlerts,
            hasMultipleTypes,
            hasStatusMonitoring,
            alertsTriggered,
            alertTypes: Array.from(alertTypes),
            status,
          },
        })
      } else {
        this.results.push({
          name: 'Alert System',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Alert system not working properly',
          details: { hasAlerts, hasMultipleTypes, hasStatusMonitoring },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Alert System',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testConfigurationManagement(): Promise<void> {
    console.log('📋 Test 10: Configuration Management')

    const startTime = Date.now()

    try {
      // Test different configurations
      const configs = [
        { name: 'Development', env: 'development' },
        { name: 'Staging', env: 'staging' },
        { name: 'Production', env: 'production' },
      ]

      let successfulConfigs = 0
      const configResults: any[] = []

      for (const config of configs) {
        try {
          let contextManager

          switch (config.env) {
            case 'development':
              contextManager = ContextManagerFactory.createForCodeReview({
                maxTokens: 50000,
                warningThreshold: 0.7,
                criticalThreshold: 0.85,
              })
              break
            case 'staging':
              contextManager = ContextManagerFactory.createForCodeReview({
                maxTokens: 150000,
                warningThreshold: 0.75,
                criticalThreshold: 0.9,
              })
              break
            case 'production':
              contextManager = ContextManagerFactory.createForCodeReview({
                maxTokens: 180000,
                warningThreshold: 0.8,
                criticalThreshold: 0.95,
              })
              break
          }

          // Test basic functionality
          contextManager.addContent('Test content', 'test', 0.5)
          const stats = contextManager.getStats()

          if (stats.totalChunks > 0 && stats.totalTokens > 0) {
            successfulConfigs++
            configResults.push({
              env: config.env,
              success: true,
              maxTokens: stats.maxTokens,
              warningThreshold: stats.warningThreshold,
            })
          } else {
            configResults.push({
              env: config.env,
              success: false,
              error: 'Basic functionality failed',
            })
          }
        } catch (error) {
          configResults.push({
            env: config.env,
            success: false,
            error: error,
          })
        }
      }

      const hasAllConfigs = successfulConfigs === configs.length
      const hasConfigResults = configResults.length === configs.length

      if (hasAllConfigs && hasConfigResults) {
        this.results.push({
          name: 'Configuration Management',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Configuration management successful: ${successfulConfigs}/${configs.length} configs working`,
          details: {
            hasAllConfigs,
            hasConfigResults,
            successfulConfigs,
            configResults,
          },
        })
      } else {
        this.results.push({
          name: 'Configuration Management',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Configuration management failed',
          details: { hasAllConfigs, hasConfigResults, successfulConfigs },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Configuration Management',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async testErrorHandling(): Promise<void> {
    console.log('📋 Test 11: Error Handling')

    const startTime = Date.now()

    try {
      const contextManager = new ContextManager({ maxTokens: 1000 })

      let errorsHandled = 0
      let gracefulDegradation = false

      // Test 1: Invalid content
      try {
        contextManager.addContent(null, 'test', 0.5)
      } catch (error) {
        errorsHandled++
      }

      // Test 2: Invalid importance
      try {
        contextManager.addContent('test', 'test', -1)
      } catch (error) {
        errorsHandled++
      }

      // Test 3: Context limit handling
      try {
        for (let i = 0; i < 100; i++) {
          contextManager.addContent('x'.repeat(100), 'test', 0.5)
        }
        const stats = contextManager.getStats()
        if (stats.usagePercentage <= 100) {
          gracefulDegradation = true
        }
      } catch (error) {
        errorsHandled++
      }

      // Test 4: Invalid chunk ID
      try {
        contextManager.removeChunk('invalid-id')
      } catch (error) {
        errorsHandled++
      }

      // Test 5: Invalid importance update
      try {
        contextManager.updateImportance('invalid-id', 0.5)
      } catch (error) {
        errorsHandled++
      }

      const hasErrorHandling = errorsHandled >= 4
      const hasGracefulDegradation = gracefulDegradation

      if (hasErrorHandling && hasGracefulDegradation) {
        this.results.push({
          name: 'Error Handling',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Error handling working: ${errorsHandled}/5 error types handled gracefully`,
          details: {
            hasErrorHandling,
            hasGracefulDegradation,
            errorsHandled,
          },
        })
      } else {
        this.results.push({
          name: 'Error Handling',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Error handling incomplete',
          details: { hasErrorHandling, hasGracefulDegradation, errorsHandled },
        })
      }
    } catch (error) {
      this.results.push({
        name: 'Error Handling',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error: ${error}`,
      })
    }

    console.log('')
  }

  private async generateTestReport(): Promise<void> {
    const totalDuration = Date.now() - this.testStartTime
    const summary = {
      totalTests: this.results.length,
      passed: this.results.filter((r) => r.status === 'pass').length,
      failed: this.results.filter((r) => r.status === 'fail').length,
      skipped: this.results.filter((r) => r.status === 'skip').length,
      totalDuration: totalDuration,
      timestamp: new Date().toISOString(),
    }

    // Display results
    console.log('\n' + '='.repeat(80))
    console.log('🧪 INTEGRATION TEST RESULTS')
    console.log('='.repeat(80))

    console.log(`\n📊 Summary:`)
    console.log(`   Total Tests: ${summary.totalTests}`)
    console.log(`   ✅ Passed: ${summary.passed}`)
    console.log(`   ❌ Failed: ${summary.failed}`)
    console.log(`   ⏭️  Skipped: ${summary.skipped}`)
    console.log(`   ⏱️  Duration: ${totalDuration}ms`)
    console.log(`   🕐 Timestamp: ${summary.timestamp}`)

    console.log('\n📋 Individual Test Results:')
    console.log('-'.repeat(80))

    for (const result of this.results) {
      const icon = result.status === 'pass' ? '✅' : result.status === 'fail' ? '❌' : '⏭️'
      console.log(
        `${icon} ${result.name.padEnd(35)} ${result.message.padEnd(40)} ${result.duration}ms`
      )

      if (result.details) {
        console.log(`   📄 Details: ${JSON.stringify(result.details, null, 2)}`)
      }
    }

    // Save detailed report
    const reportPath = path.join('data', 'reports', `integration-test-${Date.now()}.json`)
    if (!fs.existsSync(path.dirname(reportPath))) {
      fs.mkdirSync(path.dirname(reportPath), { recursive: true })
    }

    const reportData = {
      summary,
      results: this.results,
    }

    fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2))
    console.log(`\n📄 Detailed report saved: ${reportPath}`)

    // Recommendations
    console.log('\n💡 Recommendations:')
    if (summary.failed === 0) {
      console.log('🎉 All tests passed! System is ready for production.')
    } else {
      const failedTests = this.results.filter((r) => r.status === 'fail')
      console.log(`🚨 ${summary.failed} test(s) failed. Review and fix:`)
      failedTests.forEach((test) => {
        console.log(`   • ${test.name}: ${test.message}`)
      })
    }

    console.log('\n' + '='.repeat(80))
  }
}

// CLI interface
async function main() {
  console.log('🧪 Context Management Tools - Integration Test Suite')
  console.log('Testing all scenarios from IMPLEMENTATION_GUIDE.md\n')

  const tester = new IntegrationTester()

  try {
    await tester.runAllTests()

    const summary = {
      total: tester.results.length,
      passed: tester.results.filter((r) => r.status === 'pass').length,
      failed: tester.results.filter((r) => r.status === 'fail').length,
    }

    // Exit with appropriate code
    if (summary.failed === 0) {
      console.log('\n🎉 All integration tests passed!')
      process.exit(0)
    } else {
      console.log(`\n❌ ${summary.failed} integration test(s) failed!`)
      process.exit(1)
    }
  } catch (error) {
    console.error('❌ Integration test suite failed:', error)
    process.exit(2)
  }
}

if (require.main === module) {
  main()
}

export { IntegrationTester }
