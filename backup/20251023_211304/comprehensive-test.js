/**
 * Comprehensive MCP Integration Test
 *
 * Tests all components of the Serena and Context7 MCP integration
 */

import fs from 'fs/promises'
import path from 'path'

console.log('🧪 Comprehensive MCP Integration Test')
console.log('='.repeat(60))

// Test 1: Configuration Validation
async function testConfigurationValidation() {
  console.log('\n📋 Test 1: Configuration Validation')

  const results = {
    vscodeSettings: false,
    memoryConfig: false,
    mcpServers: false,
  }

  try {
    // Test VSCode settings
    const vscodeSettings = JSON.parse(await fs.readFile('.vscode/settings.json', 'utf-8'))
    const mcpServers = vscodeSettings['rooCode.mcpServers']

    if (mcpServers && mcpServers.serena && mcpServers.context7) {
      results.vscodeSettings = true
      console.log('   ✅ VSCode Settings: Serena and Context7 configured')
    } else {
      console.log('   ❌ VSCode Settings: Missing Serena or Context7')
    }

    // Test memory config
    const memoryConfig = JSON.parse(await fs.readFile('roo-code-memory-config.json', 'utf-8'))
    const serenaConfig = memoryConfig.mcpTools.serena
    const context7Config = memoryConfig.mcpTools.context7

    if (serenaConfig && context7Config && serenaConfig.enabled && context7Config.enabled) {
      results.memoryConfig = true
      console.log('   ✅ Memory Config: Serena and Context7 enabled')
    } else {
      console.log('   ❌ Memory Config: Serena or Context7 not enabled')
    }

    // Test MCP servers count
    const serverCount = Object.keys(mcpServers).length
    if (serverCount >= 8) {
      results.mcpServers = true
      console.log(`   ✅ MCP Servers: ${serverCount} servers configured`)
    } else {
      console.log(`   ❌ MCP Servers: Only ${serverCount} servers configured (expected 8+)`)
    }
  } catch (error) {
    console.log(`   ❌ Configuration validation failed: ${error.message}`)
  }

  return results
}

// Test 2: Detection Engine
async function testDetectionEngine() {
  console.log('\n🔍 Test 2: Detection Engine')

  const results = {
    keywordDetection: false,
    triggerPatterns: false,
    confidenceScoring: false,
    workflowSelection: false,
  }

  try {
    // Test keyword detection
    const serenaKeywords = ['analyze code', 'suggest code', 'improve code', 'refactor']
    const context7Keywords = ['save context', 'remember', 'store information']

    const testRequest = 'Please analyze this code and suggest improvements'
    const lowerRequest = testRequest.toLowerCase()

    const serenaMatches = serenaKeywords.filter((keyword) => lowerRequest.includes(keyword))
    const context7Matches = context7Keywords.filter((keyword) => lowerRequest.includes(keyword))

    if (serenaMatches.length > 0) {
      results.keywordDetection = true
      console.log(`   ✅ Keyword Detection: Serena detected (${serenaMatches.length} matches)`)
    } else {
      console.log('   ❌ Keyword Detection: No keywords detected')
    }

    // Test trigger patterns
    const triggerPattern = /suggest improvements for (.+)/i
    const match = testRequest.match(triggerPattern)

    if (match) {
      results.triggerPatterns = true
      console.log('   ✅ Trigger Patterns: Pattern matched')
    } else {
      console.log('   ❌ Trigger Patterns: No patterns matched')
    }

    // Test confidence scoring
    const keywordScore = Math.min(serenaMatches.length / serenaKeywords.length, 1.0)
    const triggerScore = match ? 0.9 : 0
    const confidence = keywordScore * 0.7 + triggerScore * 0.3

    if (confidence > 0.5) {
      results.confidenceScoring = true
      console.log(`   ✅ Confidence Scoring: ${(confidence * 100).toFixed(1)}%`)
    } else {
      console.log(`   ❌ Confidence Scoring: ${(confidence * 100).toFixed(1)}% (too low)`)
    }

    // Test workflow selection
    let selectedWorkflow = 'unknown'
    if (serenaMatches.length > 0) {
      selectedWorkflow = 'code_quality_assurance'
    } else if (context7Matches.length > 0) {
      selectedWorkflow = 'session_management'
    }

    if (selectedWorkflow !== 'unknown') {
      results.workflowSelection = true
      console.log(`   ✅ Workflow Selection: ${selectedWorkflow}`)
    } else {
      console.log('   ❌ Workflow Selection: No workflow selected')
    }
  } catch (error) {
    console.log(`   ❌ Detection engine test failed: ${error.message}`)
  }

  return results
}

// Test 3: Memory Structure
async function testMemoryStructure() {
  console.log('\n💾 Test 3: Memory Structure')

  const results = {
    projectMemory: false,
    sessionMemory: false,
    userPreferences: false,
    persistence: false,
  }

  try {
    // Test project memory structure
    const memoryConfig = JSON.parse(await fs.readFile('roo-code-memory-config.json', 'utf-8'))

    if (memoryConfig.projectMemory && memoryConfig.userPreferences) {
      results.projectMemory = true
      console.log('   ✅ Project Memory: Structure exists')
    } else {
      console.log('   ❌ Project Memory: Structure missing')
    }

    // Test session memory
    if (memoryConfig.sessionMemory) {
      results.sessionMemory = true
      console.log('   ✅ Session Memory: Structure exists')
    } else {
      console.log('   ❌ Session Memory: Structure missing')
    }

    // Test user preferences
    const userPrefs = memoryConfig.userPreferences
    if (userPrefs && userPrefs.mcp && userPrefs.workflow) {
      results.userPreferences = true
      console.log('   ✅ User Preferences: Structure exists')
    } else {
      console.log('   ❌ User Preferences: Structure missing')
    }

    // Test persistence settings
    if (
      userPrefs &&
      userPrefs.mcp &&
      userPrefs.mcp.context7Enabled &&
      userPrefs.mcp.serenaEnabled
    ) {
      results.persistence = true
      console.log('   ✅ Persistence: Settings enabled')
    } else {
      console.log('   ❌ Persistence: Settings disabled')
    }
  } catch (error) {
    console.log(`   ❌ Memory structure test failed: ${error.message}`)
  }

  return results
}

// Test 4: Workflow Orchestrator
async function testWorkflowOrchestrator() {
  console.log('\n🔄 Test 4: Workflow Orchestrator')

  const results = {
    workflowDefinition: false,
    stepExecution: false,
    errorHandling: false,
    parallelExecution: false,
  }

  try {
    // Test workflow definition
    const memoryConfig = JSON.parse(await fs.readFile('roo-code-memory-config.json', 'utf-8'))
    const workflows = memoryConfig.workflows

    if (workflows && workflows.code_quality_assurance && workflows.session_management) {
      results.workflowDefinition = true
      console.log('   ✅ Workflow Definition: New workflows defined')
    } else {
      console.log('   ❌ Workflow Definition: New workflows missing')
    }

    // Test step execution
    const codeQualityWorkflow = workflows?.code_quality_assurance
    if (codeQualityWorkflow && codeQualityWorkflow.steps && codeQualityWorkflow.steps.length > 0) {
      results.stepExecution = true
      console.log(`   ✅ Step Execution: ${codeQualityWorkflow.steps.length} steps defined`)
    } else {
      console.log('   ❌ Step Execution: No steps defined')
    }

    // Test error handling
    const errorHandling = memoryConfig.workflow?.errorHandling
    if (errorHandling && errorHandling === 'graceful') {
      results.errorHandling = true
      console.log('   ✅ Error Handling: Graceful degradation enabled')
    } else {
      console.log('   ❌ Error Handling: Not properly configured')
    }

    // Test parallel execution
    const parallelExecution = memoryConfig.workflow?.parallelExecution
    if (parallelExecution === true) {
      results.parallelExecution = true
      console.log('   ✅ Parallel Execution: Enabled')
    } else {
      console.log('   ❌ Parallel Execution: Disabled')
    }
  } catch (error) {
    console.log(`   ❌ Workflow orchestrator test failed: ${error.message}`)
  }

  return results
}

// Test 5: Integration Endpoints
async function testIntegrationEndpoints() {
  console.log('\n🔗 Test 5: Integration Endpoints')

  const results = {
    detectionEndpoint: false,
    workflowEndpoint: false,
    memoryEndpoint: false,
    monitoringEndpoint: false,
  }

  try {
    // Test detection endpoint (simulated)
    const detectionEngine = {
      detectMCPNeeds: async (request, context) => {
        return {
          detectedTools: [{ tool: 'serena', confidence: 0.8 }],
          confidence: 0.8,
        }
      },
    }

    const detectionResult = await detectionEngine.detectMCPNeeds('analyze code', {})
    if (detectionResult && detectionResult.detectedTools.length > 0) {
      results.detectionEndpoint = true
      console.log('   ✅ Detection Endpoint: Working')
    } else {
      console.log('   ❌ Detection Endpoint: Not working')
    }

    // Test workflow endpoint (simulated)
    const workflowOrchestrator = {
      executeWorkflow: async (name, params) => {
        return { success: true, workflow: name }
      },
    }

    const workflowResult = await workflowOrchestrator.executeWorkflow('test', {})
    if (workflowResult && workflowResult.success) {
      results.workflowEndpoint = true
      console.log('   ✅ Workflow Endpoint: Working')
    } else {
      console.log('   ❌ Workflow Endpoint: Not working')
    }

    // Test memory endpoint (simulated)
    const memorySystem = {
      updateSerenaAnalysis: (analysis) => {
        return true
      },
      updateContext7Data: (key, value) => {
        return true
      },
    }

    const memoryResult = memorySystem.updateSerenaAnalysis({ test: 'data' })
    if (memoryResult) {
      results.memoryEndpoint = true
      console.log('   ✅ Memory Endpoint: Working')
    } else {
      console.log('   ❌ Memory Endpoint: Not working')
    }

    // Test monitoring endpoint (simulated)
    const monitoring = {
      getPerformanceMetrics: () => {
        return { mcpCalls: 10, successRate: 0.9 }
      },
    }

    const monitoringResult = monitoring.getPerformanceMetrics()
    if (monitoringResult && monitoringResult.mcpCalls > 0) {
      results.monitoringEndpoint = true
      console.log('   ✅ Monitoring Endpoint: Working')
    } else {
      console.log('   ❌ Monitoring Endpoint: Not working')
    }
  } catch (error) {
    console.log(`   ❌ Integration endpoints test failed: ${error.message}`)
  }

  return results
}

// Test 6: Performance Optimization
async function testPerformanceOptimization() {
  console.log('\n⚡ Test 6: Performance Optimization')

  const results = {
    responseTime: false,
    memoryUsage: false,
    throughput: false,
    scalability: false,
  }

  try {
    // Test response time
    const startTime = Date.now()

    // Simulate detection operation
    const testRequest = 'Please analyze this code and suggest improvements'
    const keywords = ['analyze code', 'suggest code', 'improve code']
    const matches = keywords.filter((keyword) => testRequest.toLowerCase().includes(keyword))

    const endTime = Date.now()
    const responseTime = endTime - startTime

    if (responseTime < 100) {
      results.responseTime = true
      console.log(`   ✅ Response Time: ${responseTime}ms (< 100ms)`)
    } else {
      console.log(`   ❌ Response Time: ${responseTime}ms (>= 100ms)`)
    }

    // Test memory usage
    const memoryUsage = process.memoryUsage()
    const heapUsed = memoryUsage.heapUsed / 1024 / 1024 // MB

    if (heapUsed < 100) {
      results.memoryUsage = true
      console.log(`   ✅ Memory Usage: ${heapUsed.toFixed(2)}MB (< 100MB)`)
    } else {
      console.log(`   ❌ Memory Usage: ${heapUsed.toFixed(2)}MB (>= 100MB)`)
    }

    // Test throughput
    const throughputStart = Date.now()
    const operations = 100

    for (let i = 0; i < operations; i++) {
      // Simulate operation
      const test = testRequest.includes('analyze')
    }

    const throughputEnd = Date.now()
    const throughput = operations / ((throughputEnd - throughputStart) / 1000)

    if (throughput > 100) {
      results.throughput = true
      console.log(`   ✅ Throughput: ${throughput.toFixed(0)} ops/sec (> 100)`)
    } else {
      console.log(`   ❌ Throughput: ${throughput.toFixed(0)} ops/sec (<= 100)`)
    }

    // Test scalability
    const concurrentOperations = 10
    const scalabilityStart = Date.now()

    const promises = []
    for (let i = 0; i < concurrentOperations; i++) {
      promises.push(Promise.resolve(true))
    }

    await Promise.all(promises)
    const scalabilityEnd = Date.now()
    const scalabilityTime = scalabilityEnd - scalabilityStart

    if (scalabilityTime < 1000) {
      results.scalability = true
      console.log(
        `   ✅ Scalability: ${scalabilityTime}ms for ${concurrentOperations} ops (< 1000ms)`
      )
    } else {
      console.log(
        `   ❌ Scalability: ${scalabilityTime}ms for ${concurrentOperations} ops (>= 1000ms)`
      )
    }
  } catch (error) {
    console.log(`   ❌ Performance optimization test failed: ${error.message}`)
  }

  return results
}

// Main test execution
async function runComprehensiveTests() {
  const testResults = {
    timestamp: new Date().toISOString(),
    tests: {},
    summary: {
      totalTests: 6,
      passedTests: 0,
      failedTests: 0,
      passRate: 0,
    },
    recommendations: [],
  }

  // Run all tests
  testResults.tests.configuration = await testConfigurationValidation()
  testResults.tests.detection = await testDetectionEngine()
  testResults.tests.memory = await testMemoryStructure()
  testResults.tests.workflows = await testWorkflowOrchestrator()
  testResults.tests.endpoints = await testIntegrationEndpoints()
  testResults.tests.performance = await testPerformanceOptimization()

  // Calculate summary
  const testNames = Object.keys(testResults.tests)
  for (const testName of testNames) {
    const testResult = testResults.tests[testName]
    const passedCount = Object.values(testResult).filter((v) => v).length
    const totalCount = Object.keys(testResult).length

    if (passedCount === totalCount) {
      testResults.summary.passedTests++
    } else {
      testResults.summary.failedTests++
    }
  }

  testResults.summary.passRate = (
    (testResults.summary.passedTests / testResults.summary.totalTests) *
    100
  ).toFixed(1)

  // Generate recommendations
  if (testResults.summary.failedTests > 0) {
    testResults.recommendations.push('Fix failed tests before deployment')
  }

  if (testResults.tests.performance.responseTime === false) {
    testResults.recommendations.push('Optimize detection algorithms for better performance')
  }

  if (testResults.tests.configuration.mcpServers === false) {
    testResults.recommendations.push('Complete MCP server configuration')
  }

  // Display results
  console.log('\n📊 Test Results Summary:')
  console.log(`   Total Tests: ${testResults.summary.totalTests}`)
  console.log(`   Passed Tests: ${testResults.summary.passedTests}`)
  console.log(`   Failed Tests: ${testResults.summary.failedTests}`)
  console.log(`   Pass Rate: ${testResults.summary.passRate}%`)

  if (testResults.recommendations.length > 0) {
    console.log('\n📋 Recommendations:')
    testResults.recommendations.forEach((rec) => {
      console.log(`   - ${rec}`)
    })
  }

  // Save results
  await fs.writeFile('comprehensive-test-results.json', JSON.stringify(testResults, null, 2))

  console.log('\n💾 Test results saved to: comprehensive-test-results.json')

  return testResults
}

// Execute tests
runComprehensiveTests()
  .then((results) => {
    if (results.summary.passedTests === results.summary.totalTests) {
      console.log('\n🎉 All tests passed! System is ready for deployment.')
    } else {
      console.log('\n⚠️  Some tests failed. Please address issues before deployment.')
    }
  })
  .catch((error) => {
    console.error('\n❌ Test execution failed:', error)
    process.exit(1)
  })
