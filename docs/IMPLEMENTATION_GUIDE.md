# Hướng Dẫn Thực Thi: Khắc Phục Vấn Đề Context Limit 200K Token

## 🚀 Bắt Đầu Nhanh

Bạn đang gặp vấn đề với context limit 200K token? Hãy làm theo các bước sau để khắc phục ngay lập tức.

### Bước 1: Chẩn Đoán Vấn Đề (5 phút)

```typescript
// Kiểm tra context usage hiện tại
const checkContextUsage = () => {
  const stats = contextManager.getStats()
  console.log(`Context usage: ${stats.usagePercentage.toFixed(1)}%`)
  console.log(`Total tokens: ${stats.totalTokens}`)
  console.log(`Chunk count: ${stats.totalChunks}`)

  if (stats.usagePercentage > 80) {
    console.log('⚠️  WARNING: Context usage too high!')
  }
  if (stats.usagePercentage > 95) {
    console.log('🚨 CRITICAL: Context limit exceeded!')
  }
}
```

### Bước 2: Áp Dụng Giải Pháp Nhanh (15 phút)

#### Solution A: Sử dụng ContextManager có sẵn

```typescript
// Cài đặt nhanh
import { ContextManagerFactory } from './tools/context-manager/ContextManager'

// Tạo context manager cho code review
const contextManager = ContextManagerFactory.createForCodeReview({
  maxTokens: 180000, // Để lại 20K cho response
  warningThreshold: 0.75,
  criticalThreshold: 0.9,
  compressionEnabled: true,
})

// Thêm content với importance score
contextManager.addContent(systemPrompt, 'system', 1.0)
contextManager.addContent(importantCode, 'code', 0.9)
contextManager.addContent(documentation, 'documentation', 0.7)

// Lấy context đã tối ưu
const optimizedContext = contextManager.getContextString()
```

#### Solution B: Manual chunking (nếu không dùng tool)

```typescript
// Chia nhỏ context manually
const chunkContext = (content, maxTokens = 50000) => {
  const chunks = []
  const words = content.split(/\s+/)
  let currentChunk = []
  let currentTokens = 0

  for (const word of words) {
    const wordTokens = Math.ceil(word.length * 0.75) // Approximate
    if (currentTokens + wordTokens > maxTokens) {
      chunks.push(currentChunk.join(' '))
      currentChunk = [word]
      currentTokens = wordTokens
    } else {
      currentChunk.push(word)
      currentTokens += wordTokens
    }
  }

  if (currentChunk.length > 0) {
    chunks.push(currentChunk.join(' '))
  }

  return chunks
}
```

---

## 🛠️ Giải Pháp Chi Tiết Theo Từng Tình Huống

### Tình Huống 1: Code Review Lớn

**Vấn đề**: Review file lớn với nhiều function
**Giải pháp**: Hierarchical Context + Semantic Chunking

```typescript
// Implementation
class CodeReviewManager {
  constructor() {
    this.contextManager = ContextManagerFactory.createForCodeReview()
    this.setupHierarchicalContext()
  }

  setupHierarchicalContext() {
    // Level 1: System prompts (5%)
    this.contextManager.addContent(
      'You are a senior code reviewer. Focus on security, performance, maintainability.',
      'system',
      1.0
    )

    // Level 2: Project context (10%)
    this.contextManager.addContent(
      `Project: ${this.projectInfo.name}\nTech stack: ${this.projectInfo.techStack}`,
      'documentation',
      0.9
    )
  }

  reviewLargeFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8')

    // Chia theo function/class
    const functions = this.extractFunctions(content)

    // Review từng function với context riêng
    const reviews = []
    for (const func of functions) {
      const review = this.reviewFunction(func)
      reviews.push(review)
    }

    return this.consolidateReviews(reviews)
  }

  reviewFunction(functionCode) {
    // Clear previous function context
    this.clearFunctionContext()

    // Add current function with high importance
    this.contextManager.addContent(functionCode, 'code', 0.95)

    // Add related documentation
    const relatedDocs = this.getRelatedDocs(functionCode)
    relatedDocs.forEach((doc) => {
      this.contextManager.addContent(doc, 'documentation', 0.7)
    })

    // Get review
    const context = this.contextManager.getContextString(30000)
    return this.getAIReview(context)
  }
}
```

### Tình Huống 2: Documentation Generation

**Vấn đề**: Generate documentation cho large codebase
**Giải pháp**: Multi-Agent Distribution + External Memory

```typescript
// Implementation
class DocumentationGenerator {
  constructor() {
    this.agents = {
      api: new APIAgent(),
      models: new ModelAgent(),
      utils: new UtilAgent(),
    }
    this.vectorStore = new VectorStore()
  }

  async generateDocumentation(codebasePath) {
    // Phase 1: Analyze and categorize
    const analysis = await this.analyzeCodebase(codebasePath)

    // Phase 2: Generate docs in parallel
    const promises = [
      this.generateAPIDocs(analysis.apiFiles),
      this.generateModelDocs(analysis.modelFiles),
      this.generateUtilDocs(analysis.utilFiles),
    ]

    const results = await Promise.all(promises)

    // Phase 3: Consolidate
    return this.consolidateDocumentation(results)
  }

  async generateAPIDocs(apiFiles) {
    const agent = this.agents.api
    const docs = []

    for (const file of apiFiles) {
      // Create focused context for each file
      const context = await this.createAPIContext(file)
      const doc = await agent.generateDoc(context)
      docs.push(doc)

      // Store in vector memory for cross-references
      await this.vectorStore.store({
        id: file.path,
        content: doc,
        metadata: { type: 'api', file: file.path },
      })
    }

    return docs
  }

  async createAPIContext(file) {
    const contextManager = new ContextManager({ maxTokens: 25000 })

    // Add file content
    contextManager.addContent(file.content, 'code', 0.9)

    // Add related API docs from vector store
    const relatedDocs = await this.vectorStore.findSimilar(file.content, 5)
    relatedDocs.forEach((doc) => {
      contextManager.addContent(doc.content, 'documentation', 0.7)
    })

    return contextManager.getContextString()
  }
}
```

### Tình Huống 3: Chat với Code Context

**Vấn đề**: Conversation kéo dài với nhiều code snippets
**Giải pháp**: Rolling Context + Smart Caching

```typescript
// Implementation
class CodeChatManager {
  constructor() {
    this.contextManager = ContextManagerFactory.createForChat()
    this.cache = new Map()
    this.setupBaseContext()
  }

  setupBaseContext() {
    // Permanent context (5%)
    this.contextManager.addContent(
      'You are a helpful coding assistant. Provide clear, actionable advice.',
      'system',
      1.0
    )
  }

  async chat(userMessage, codeContext = null) {
    // Check cache first
    const cacheKey = this.generateCacheKey(userMessage, codeContext)
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey)
    }

    // Add user message
    this.contextManager.addContent(userMessage, 'conversation', 0.6)

    // Add code context if provided
    if (codeContext) {
      this.addCodeContext(codeContext)
    }

    // Get response
    const context = this.contextManager.getContextString(40000)
    const response = await this.getAIResponse(context)

    // Add AI response
    this.contextManager.addContent(response, 'conversation', 0.7)

    // Cache result
    this.cache.set(cacheKey, response)

    // Cleanup old cache entries
    if (this.cache.size > 100) {
      const firstKey = this.cache.keys().next().value
      this.cache.delete(firstKey)
    }

    return response
  }

  addCodeContext(codeContext) {
    // Prioritize recent and relevant code
    const prioritizedCode = this.prioritizeCode(codeContext)

    prioritizedCode.forEach((code, index) => {
      const importance = Math.max(0.3, 1.0 - index * 0.1)
      this.contextManager.addContent(code, 'code', importance)
    })
  }

  prioritizeCode(codeContext) {
    // Sort by recency and relevance
    return codeContext
      .sort((a, b) => {
        // Recent code first
        if (a.timestamp !== b.timestamp) {
          return b.timestamp - a.timestamp
        }
        // Then by relevance score
        return b.relevance - a.relevance
      })
      .slice(0, 5) // Keep only top 5
  }
}
```

---

## 🔧 Setup Production Environment

### Bước 1: Installation

```bash
# Clone the tools
git clone <repository-url>
cd context-management-tools

# Install dependencies
npm install

# Build TypeScript
npm run build

# Run tests
npm test
```

### Bước 2: Configuration

```typescript
// config/context-manager.ts
export const contextConfig = {
  development: {
    maxTokens: 50000,
    warningThreshold: 0.7,
    criticalThreshold: 0.85,
    compressionEnabled: true,
    cachingEnabled: true,
  },

  staging: {
    maxTokens: 150000,
    warningThreshold: 0.75,
    criticalThreshold: 0.9,
    compressionEnabled: true,
    cachingEnabled: true,
  },

  production: {
    maxTokens: 180000,
    warningThreshold: 0.8,
    criticalThreshold: 0.95,
    compressionEnabled: true,
    cachingEnabled: true,
  },
}
```

### Bước 3: Integration với Existing Code

```typescript
// existing-code-review.ts
// Before: Large context
async function reviewCode_old(code) {
  const prompt = `
    Review this code:
    ${code}
    ${allDocumentation}
    ${projectHistory}
    ${teamGuidelines}
  `

  return await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt }],
  })
}

// After: Optimized context
import { ContextManagerFactory } from './tools/context-manager/ContextManager'
import { MonitoringFactory } from './tools/context-monitor/ContextMonitor'

async function reviewCode_new(code) {
  const contextManager = ContextManagerFactory.createForCodeReview()
  const { monitor } = MonitoringFactory.createWithAlerting(contextManager)

  // Add content with priorities
  contextManager.addContent(teamGuidelines, 'system', 1.0)
  contextManager.addContent(code, 'code', 0.9)

  // Add only relevant documentation
  const relevantDocs = getRelevantDocs(code)
  relevantDocs.forEach((doc) => {
    contextManager.addContent(doc, 'documentation', 0.7)
  })

  const startTime = Date.now()
  const context = contextManager.getContextString()
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [{ role: 'user', content: context }],
  })
  const responseTime = Date.now() - startTime

  // Monitor performance
  monitor.recordRequest(responseTime, 0.8)

  return response
}
```

---

## 📊 Monitoring và Maintenance

### Setup Monitoring Dashboard

```typescript
// monitoring/dashboard.ts
import { AdvancedContextMonitor } from './tools/context-monitor/ContextMonitor'

class ContextDashboard {
  constructor() {
    this.monitors = new Map()
    this.setupAlerting()
  }

  setupAlerting() {
    // Slack notifications
    this.slackWebhook = process.env.SLACK_WEBHOOK

    // Email notifications
    this.emailService = new EmailService()
  }

  addProject(projectName, contextManager) {
    const monitor = new AdvancedContextMonitor(contextManager)
    this.monitors.set(projectName, monitor)

    // Setup alerts for this project
    monitor.on('alert', (alert) => {
      this.handleAlert(projectName, alert)
    })
  }

  handleAlert(projectName, alert) {
    const message = `🚨 Context Alert for ${projectName}: ${alert.message}`

    // Send to Slack
    if (this.slackWebhook) {
      fetch(this.slackWebhook, {
        method: 'POST',
        body: JSON.stringify({ text: message }),
      })
    }

    // Send email for critical alerts
    if (alert.severity === 'critical') {
      this.emailService.send({
        to: 'dev-team@company.com',
        subject: `Critical Context Alert: ${projectName}`,
        body: message,
      })
    }
  }

  generateDailyReport() {
    const report = {
      date: new Date().toISOString().split('T')[0],
      projects: [],
    }

    for (const [projectName, monitor] of this.monitors) {
      const projectReport = monitor.generateReport(24)
      report.projects.push({
        name: projectName,
        ...projectReport,
      })
    }

    return report
  }
}
```

### Performance Optimization Checklist

```typescript
// optimization/checklist.ts
export const optimizationChecklist = {
  daily: [
    'Check context usage trends',
    'Review alert patterns',
    'Clean up old cache entries',
    'Verify compression ratios',
  ],

  weekly: [
    'Analyze performance reports',
    'Update importance scores',
    'Review chunking strategies',
    'Optimize caching policies',
  ],

  monthly: [
    'Evaluate overall system performance',
    'Update context management strategies',
    'Review and update thresholds',
    'Plan improvements based on usage patterns',
  ],
}
```

---

## 🚨 Troubleshooting Guide

### Problem 1: Context Usage Suddenly Spikes

```typescript
// diagnosis.ts
async function diagnoseContextSpike(projectName) {
  const monitor = getMonitor(projectName)
  const recentMetrics = monitor.getRecentMetrics(24) // Last 24 hours

  // Find the spike
  const spike = recentMetrics.find((m) => m.usagePercentage > 90)
  if (!spike) return null

  // Analyze what caused it
  const analysis = {
    timestamp: spike.timestamp,
    usage: spike.usagePercentage,
    chunks: spike.activeChunks,
    possibleCauses: [],
  }

  // Check for large chunks
  const largeChunks = spike.chunks.filter((c) => c.tokens > 10000)
  if (largeChunks.length > 0) {
    analysis.possibleCauses.push('Large chunks detected')
  }

  // Check for too many chunks
  if (spike.activeChunks > 100) {
    analysis.possibleCauses.push('Too many chunks')
  }

  // Check for compression issues
  if (spike.compressionRatio < 0.7) {
    analysis.possibleCauses.push('Poor compression')
  }

  return analysis
}
```

### Problem 2: Response Quality Degraded

```typescript
// quality-check.ts
async function diagnoseQualityIssue(projectName) {
  const monitor = getMonitor(projectName)
  const report = monitor.generateReport(24)

  if (report.qualityTrend === 'declining') {
    const issues = []

    // Check context relevance
    const recentContext = monitor.getRecentContext()
    const relevanceScore = calculateRelevanceScore(recentContext)
    if (relevanceScore < 0.7) {
      issues.push('Low context relevance')
    }

    // Check context completeness
    const completenessScore = calculateCompletenessScore(recentContext)
    if (completenessScore < 0.7) {
      issues.push('Incomplete context')
    }

    // Check for context confusion
    const confusionScore = calculateConfusionScore(recentContext)
    if (confusionScore > 0.3) {
      issues.push('Context confusion detected')
    }

    return {
      trend: 'declining',
      issues,
      recommendations: generateRecommendations(issues),
    }
  }

  return { trend: report.qualityTrend }
}
```

### Problem 3: Performance Slow

```typescript
// performance-check.ts
async function diagnosePerformanceIssue(projectName) {
  const monitor = getMonitor(projectName)
  const dashboard = monitor.getDashboardData()

  if (dashboard.stats.avgResponseTime > 5000) {
    const causes = []

    // Check context size
    if (dashboard.current.totalTokens > 150000) {
      causes.push('Context too large')
    }

    // Check compression overhead
    if (dashboard.current.compressionRatio < 0.8) {
      causes.push('Compression overhead')
    }

    // Check cache hit rate
    const cacheHitRate = calculateCacheHitRate(monitor)
    if (cacheHitRate < 0.5) {
      causes.push('Low cache hit rate')
    }

    return {
      issue: 'slow_response',
      avgResponseTime: dashboard.stats.avgResponseTime,
      causes,
      fixes: generatePerformanceFixes(causes),
    }
  }

  return { status: 'normal' }
}
```

---

## 🎯 Action Plan cho Từng Role

### Cho Developer

**Ngày 1: Setup**

```bash
# 1. Install tools
npm install context-management-tools

# 2. Add to project
import { ContextManagerFactory } from './tools/context-manager/ContextManager';

# 3. Basic implementation
const contextManager = ContextManagerFactory.createForCodeReview();
```

**Tuần 1: Integration**

- Replace existing AI calls with context-managed versions
- Set up basic monitoring
- Test with small projects

**Tuần 2: Optimization**

- Fine-tune importance scores
- Implement caching
- Set up alerts

### Cho Team Lead

**Tuần 1: Assessment**

- Audit current AI usage patterns
- Identify high-risk projects
- Set up team monitoring dashboard

**Tuần 2: Implementation**

- Roll out tools to team
- Establish guidelines
- Set up team-wide monitoring

**Tuần 3: Optimization**

- Review team performance
- Adjust strategies
- Document best practices

### Cho Manager

**Tháng 1: Evaluation**

- Review current AI costs and productivity
- Assess impact of context limits
- Plan implementation strategy

**Tháng 2: Implementation**

- Allocate resources for tool adoption
- Set up monitoring and reporting
- Establish KPIs

**Tháng 3: Optimization**

- Review ROI
- Scale successful practices
- Plan next improvements

---

## 📈 KPIs và Metrics

### Technical KPIs

- **Context Usage Percentage**: Target < 80%
- **Response Time**: Target < 5 seconds
- **Quality Score**: Target > 0.8
- **Error Rate**: Target < 10%

### Business KPIs

- **Developer Productivity**: Target +40%
- **API Cost Reduction**: Target -30%
- **Time-to-Market**: Target -25%
- **Code Quality**: Target +30%

### Monitoring Frequency

- **Real-time**: Context usage, response time
- **Daily**: Quality scores, error rates
- **Weekly**: Performance trends, cost analysis
- **Monthly**: ROI assessment, strategy review

---

## 🚀 Next Steps

1. **Immediate (Hôm nay)**
   - Install context management tools
   - Set up basic monitoring
   - Test với project hiện tại

2. **Short-term (Tuần này)**
   - Integrate vào existing workflows
   - Set up alerts và notifications
   - Train team members

3. **Medium-term (Tháng này)**
   - Optimize strategies dựa trên usage data
   - Scale đến toàn bộ projects
   - Establish best practices

4. **Long-term (Quý này)**
   - Evaluate ROI và impact
   - Plan advanced optimizations
   - Consider custom solutions

---

_Need help? Check the troubleshooting guide or contact the AI team._
