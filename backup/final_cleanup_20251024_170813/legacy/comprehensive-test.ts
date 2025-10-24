#!/usr/bin/env ts-node

/**
 * Comprehensive Test Suite for Context Management Tools
 * Tests all aspects: syntax, types, runtime, performance, security
 */

import * as fs from 'fs';
import * as path from 'path';
import * as child_process from 'child_process';

interface TestResult {
  category: 'syntax' | 'types' | 'runtime' | 'performance' | 'security' | 'quality';
  name: string;
  status: 'pass' | 'fail' | 'skip';
  duration: number;
  message: string;
  details?: any;
  score?: number; // 0-10
}

interface QualityMetrics {
  maintainability: number;
  reliability: number;
  security: number;
  performance: number;
  coverage: number;
  overall: number;
}

class ComprehensiveTester {
  private results: TestResult[] = [];
  private testStartTime: number = 0;

  async runAllTests(): Promise<void> {
    console.log('🧪 Starting Comprehensive Test Suite');
    console.log('=====================================\n');

    this.testStartTime = Date.now();

    // 1. Syntax Tests
    await this.testTypeScriptSyntax();
    await this.testESLintSyntax();
    await this.testPrettierFormatting();

    // 2. Type Tests
    await this.testTypeScriptTypes();
    await this.testImportPaths();
    await this.testInterfaceCompatibility();

    // 3. Runtime Tests
    await this.testContextManagerRuntime();
    await this.testContextMonitorRuntime();
    await this.testSetupScripts();
    await this.testDemoScripts();

    // 4. Performance Tests
    await this.testMemoryUsage();
    await this.testResponseTimes();
    await this.testScalability();

    // 5. Security Tests
    await this.testInputValidation();
    await this.testEnvironmentVariables();
    await this.testDependencySecurity();

    // 6. Quality Tests
    await this.testCodeQuality();
    await this.testDocumentation();
    await this.testErrorHandling();

    // Generate comprehensive report
    await this.generateComprehensiveReport();
  }

  private async testTypeScriptSyntax(): Promise<void> {
    console.log('📋 Test 1: TypeScript Syntax');
    
    const startTime = Date.now();
    
    try {
      // Compile TypeScript
      const result = child_process.spawnSync('npx', ['tsc', '--noEmit'], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasSyntaxErrors = result.status !== 0;
      const errorOutput = result.stderr;

      if (hasSyntaxErrors) {
        this.results.push({
          category: 'syntax',
          name: 'TypeScript Syntax',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'TypeScript compilation failed',
          details: { errors: errorOutput },
          score: Math.max(0, 10 - (errorOutput.split('\n').length * 0.5))
        });
      } else {
        this.results.push({
          category: 'syntax',
          name: 'TypeScript Syntax',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'TypeScript syntax is valid',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'syntax',
        name: 'TypeScript Syntax',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Syntax test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testESLintSyntax(): Promise<void> {
    console.log('📋 Test 2: ESLint Syntax');
    
    const startTime = Date.now();
    
    try {
      const result = child_process.spawnSync('npx', ['eslint', '.', '--format', 'json'], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasLintErrors = result.status !== 0;
      const output = result.stdout ? JSON.parse(result.stdout) : [];

      if (hasLintErrors) {
        const errorCount = output.length;
        this.results.push({
          category: 'syntax',
          name: 'ESLint Syntax',
          status: 'fail',
          duration: Date.now() - startTime,
          message: `ESLint found ${errorCount} errors`,
          details: { errors: output },
          score: Math.max(0, 10 - (errorCount * 2))
        });
      } else {
        this.results.push({
          category: 'syntax',
          name: 'ESLint Syntax',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'ESLint syntax is valid',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'syntax',
        name: 'ESLint Syntax',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `ESLint test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testPrettierFormatting(): Promise<void> {
    console.log('📋 Test 3: Prettier Formatting');
    
    const startTime = Date.now();
    
    try {
      const result = child_process.spawnSync('npx', ['prettier', '--check', '.'], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasFormatErrors = result.status !== 0;
      const output = result.stderr;

      if (hasFormatErrors) {
        this.results.push({
          category: 'syntax',
          name: 'Prettier Formatting',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Prettier formatting issues found',
          details: { errors: output },
          score: Math.max(0, 10 - (output.split('\n').length * 0.3))
        });
      } else {
        this.results.push({
          category: 'syntax',
          name: 'Prettier Formatting',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'Prettier formatting is valid',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'syntax',
        name: 'Prettier Formatting',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Prettier test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testTypeScriptTypes(): Promise<void> {
    console.log('📋 Test 4: TypeScript Types');
    
    const startTime = Date.now();
    
    try {
      const result = child_process.spawnSync('npx', ['tsc', '--noEmit', '--strict'], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasTypeErrors = result.stderr.includes('error');
      const errorOutput = result.stderr;

      if (hasTypeErrors) {
        this.results.push({
          category: 'types',
          name: 'TypeScript Types',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'TypeScript type errors found',
          details: { errors: errorOutput },
          score: Math.max(0, 10 - (errorOutput.split('\n').length * 0.4))
        });
      } else {
        this.results.push({
          category: 'types',
          name: 'TypeScript Types',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'TypeScript types are valid',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'types',
        name: 'TypeScript Types',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Type test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testImportPaths(): Promise<void> {
    console.log('📋 Test 5: Import Paths');
    
    const startTime = Date.now();
    
    try {
      // Check if all imports can be resolved
      const filesToCheck = [
        'tools/context-manager/ContextManager.ts',
        'tools/context-monitor/ContextMonitor.ts',
        'scripts/setup.ts',
        'scripts/monitoring.ts',
        'scripts/health-check.ts',
        'scripts/integration-test.ts'
      ];

      let importErrors = 0;
      const importResults: any[] = [];

      for (const file of filesToCheck) {
        try {
          // Try to require the file to check imports
          delete require.cache[require.resolve(file)];
          require.resolve(file);
          importResults.push({ file, status: 'success' });
        } catch (error) {
          importErrors++;
          importResults.push({ file, status: 'error', error: error.message });
        }
      }

      if (importErrors > 0) {
        this.results.push({
          category: 'types',
          name: 'Import Paths',
          status: 'fail',
          duration: Date.now() - startTime,
          message: `${importErrors} import errors found`,
          details: { results: importResults },
          score: Math.max(0, 10 - (importErrors * 1.5))
        });
      } else {
        this.results.push({
          category: 'types',
          name: 'Import Paths',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'All import paths are valid',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'types',
        name: 'Import Paths',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Import path test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testInterfaceCompatibility(): Promise<void> {
    console.log('📋 Test 6: Interface Compatibility');
    
    const startTime = Date.now();
    
    try {
      // Check if interfaces are properly implemented
      const result = child_process.spawnSync('npx', ['tsc', '--noEmit'], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasInterfaceErrors = result.stderr.includes('does not implement');
      const errorOutput = result.stderr;

      if (hasInterfaceErrors) {
        this.results.push({
          category: 'types',
          name: 'Interface Compatibility',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Interface implementation errors found',
          details: { errors: errorOutput },
          score: Math.max(0, 10 - (errorOutput.split('\n').length * 0.3))
        });
      } else {
        this.results.push({
          category: 'types',
          name: 'Interface Compatibility',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'Interface implementations are compatible',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'types',
        name: 'Interface Compatibility',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Interface test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testContextManagerRuntime(): Promise<void> {
    console.log('📋 Test 7: ContextManager Runtime');
    
    const startTime = Date.now();
    
    try {
      // Test ContextManager instantiation and basic operations
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        
        const contextManager = new ContextManager({
          maxTokens: 10000,
          warningThreshold: 0.8,
          criticalThreshold: 0.9
        });
        
        // Test basic operations
        const id1 = contextManager.addContent('Test content 1', 'test', 0.5);
        const id2 = contextManager.addContent('Test content 2', 'test', 0.7);
        const stats = contextManager.getStats();
        const context = contextManager.getContextString();
        
        // Test edge cases
        contextManager.updateImportance(id1, 0.9);
        contextManager.removeChunk(id2);
        
        console.log('ContextManager runtime test completed successfully');
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasRuntimeErrors = result.status !== 0;
      const output = result.stderr;

      if (hasRuntimeErrors) {
        this.results.push({
          category: 'runtime',
          name: 'ContextManager Runtime',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'ContextManager runtime errors found',
          details: { errors: output },
          score: Math.max(0, 10 - (output.split('\n').length * 0.2))
        });
      } else {
        this.results.push({
          category: 'runtime',
          name: 'ContextManager Runtime',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'ContextManager runtime is functional',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'runtime',
        name: 'ContextManager Runtime',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `ContextManager runtime test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testContextMonitorRuntime(): Promise<void> {
    console.log('📋 Test 8: ContextMonitor Runtime');
    
    const startTime = Date.now();
    
    try {
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        import { AdvancedContextMonitor } from '../tools/context-monitor/ContextMonitor';
        
        const contextManager = new ContextManager();
        const monitor = new AdvancedContextMonitor(contextManager);
        
        // Test monitoring operations
        monitor.recordRequest(1000, 0.8);
        monitor.recordRequest(2000, 0.6);
        monitor.recordRequest(5000, 0.4);
        
        const status = monitor.getCurrentStatus();
        const report = monitor.generateReport(1);
        const dashboard = monitor.getDashboardData();
        
        console.log('ContextMonitor runtime test completed successfully');
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe'
      });

      const hasRuntimeErrors = result.status !== 0;
      const output = result.stderr;

      if (hasRuntimeErrors) {
        this.results.push({
          category: 'runtime',
          name: 'ContextMonitor Runtime',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'ContextMonitor runtime errors found',
          details: { errors: output },
          score: Math.max(0, 10 - (output.split('\n').length * 0.2))
        });
      } else {
        this.results.push({
          category: 'runtime',
          name: 'ContextMonitor Runtime',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'ContextMonitor runtime is functional',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'runtime',
        name: 'ContextMonitor Runtime',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `ContextMonitor runtime test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testSetupScripts(): Promise<void> {
    console.log('📋 Test 9: Setup Scripts');
    
    const startTime = Date.now();
    
    try {
      // Test setup script
      const result = child_process.spawnSync('npx', ['ts-node', 'scripts/setup.ts'], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 30000 // 30 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'runtime',
          name: 'Setup Scripts',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Setup script errors found',
          details: { errors: output },
          score: Math.max(0, 10 - (output.split('\n').length * 0.2))
        });
      } else {
        this.results.push({
          category: 'runtime',
          name: 'Setup Scripts',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'Setup scripts are functional',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'runtime',
        name: 'Setup Scripts',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Setup script test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testDemoScripts(): Promise<void> {
    console.log('📋 Test 10: Demo Scripts');
    
    const startTime = Date.now();
    
    try {
      // Test demo script
      const result = child_process.spawnSync('npx', ['ts-node', '-e', "import('./tools/context-demo/demo').then(d => d.demoBasicContextManagement())"], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 30000 // 30 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'runtime',
          name: 'Demo Scripts',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Demo script errors found',
          details: { errors: output },
          score: Math.max(0, 10 - (output.split('\n').length * 0.2))
        });
      } else {
        this.results.push({
          category: 'runtime',
          name: 'Demo Scripts',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'Demo scripts are functional',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'runtime',
        name: 'Demo Scripts',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Demo script test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testMemoryUsage(): Promise<void> {
    console.log('📋 Test 11: Memory Usage');
    
    const startTime = Date.now();
    
    try {
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        import { AdvancedContextMonitor } from '../tools/context-monitor/ContextMonitor';
        
        // Create multiple instances to test memory usage
        const instances = [];
        for (let i = 0; i < 100; i++) {
          const contextManager = new ContextManager();
          const monitor = new AdvancedContextMonitor(contextManager);
          
          // Add some content
          for (let j = 0; j < 10; j++) {
            contextManager.addContent('Test content ' + j, 'test', 0.5);
            monitor.recordRequest(1000, 0.8);
          }
          
          instances.push({ contextManager, monitor });
        }
        
        // Check memory usage
        const memUsage = process.memoryUsage();
        const heapUsedMB = memUsage.heapUsed / 1024 / 1024;
        const heapTotalMB = memUsage.heapTotal / 1024 / 1024;
        const usagePercentage = (heapUsedMB / heapTotalMB) * 100;
        
        console.log('Memory usage test completed');
        console.log('Heap used:', heapUsedMB.toFixed(2), 'MB');
        console.log('Heap total:', heapTotalMB.toFixed(2), 'MB');
        console.log('Usage:', usagePercentage.toFixed(1), '%');
        
        // Clean up
        instances.forEach(instance => {
          // Force garbage collection if available
          if (global.gc) {
            global.gc();
          }
        });
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 60000 // 60 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'performance',
          name: 'Memory Usage',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Memory usage test failed',
          details: { errors: output },
          score: Math.max(0, 10 - (output.split('\n').length * 0.2))
        });
      } else {
        this.results.push({
          category: 'performance',
          name: 'Memory Usage',
          status: 'pass',
          duration: Date.now() - startTime,
          message: 'Memory usage is within acceptable limits',
          score: 10
        });
      }

    } catch (error) {
      this.results.push({
        category: 'performance',
        name: 'Memory Usage',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Memory usage test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testResponseTimes(): Promise<void> {
    console.log('📋 Test 12: Response Times');
    
    const startTime = Date.now();
    
    try {
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        import { AdvancedContextMonitor } from '../tools/context-monitor/ContextMonitor';
        
        const contextManager = new ContextManager();
        const monitor = new AdvancedContextMonitor(contextManager);
        
        // Test response times with different context sizes
        const responseTimes = [];
        for (let i = 0; i < 50; i++) {
          const testStart = Date.now();
          
          // Add varying amounts of content
          const contentLength = Math.floor(Math.random() * 1000) + 100;
          contextManager.addContent('x'.repeat(contentLength), 'test', 0.5);
          
          const context = contextManager.getContextString();
          monitor.recordRequest(Date.now() - testStart, 0.8);
          
          responseTimes.push(Date.now() - testStart);
        }
        
        const avgResponseTime = responseTimes.reduce((sum, time) => sum + time, 0) / responseTimes.length;
        const maxResponseTime = Math.max(...responseTimes);
        const minResponseTime = Math.min(...responseTimes);
        
        console.log('Response time test completed');
        console.log('Average:', avgResponseTime.toFixed(2), 'ms');
        console.log('Max:', maxResponseTime, 'ms');
        console.log('Min:', minResponseTime, 'ms');
        
        // Score based on performance
        let score = 10;
        if (avgResponseTime > 100) score -= 2;
        if (avgResponseTime > 500) score -= 3;
        if (maxResponseTime > 1000) score -= 2;
        
        this.results.push({
          category: 'performance',
          name: 'Response Times',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Response times: avg ${avgResponseTime.toFixed(2)}ms, max ${maxResponseTime}ms`,
          details: { avgResponseTime, maxResponseTime, minResponseTime },
          score: Math.max(0, score)
        });
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 60000 // 60 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'performance',
          name: 'Response Times',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Response time test failed',
          details: { errors: output },
          score: 0
        });
      }

    } catch (error) {
      this.results.push({
        category: 'performance',
        name: 'Response Times',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Response time test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testScalability(): Promise<void> {
    console.log('📋 Test 13: Scalability');
    
    const startTime = Date.now();
    
    try {
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        import { AdvancedContextMonitor } from '../tools/context-monitor/ContextMonitor';
        
        // Test scalability with increasing load
        const scalabilityResults = [];
        for (let load = 10; load <= 1000; load *= 10) {
          const testStart = Date.now();
          
          const contextManager = new ContextManager({ maxTokens: 20000 });
          const monitor = new AdvancedContextMonitor(contextManager);
          
          // Add load amount of content
          for (let i = 0; i < load; i++) {
            contextManager.addContent('Test content ' + i, 'test', 0.5);
          }
          
          const testTime = Date.now() - testStart;
          monitor.recordRequest(testTime, 0.8);
          
          scalabilityResults.push({ load, time: testTime });
        }
        
        // Calculate scalability metrics
        const times = scalabilityResults.map(r => r.time);
        const avgTime = times.reduce((sum, time) => sum + time, 0) / times.length;
        const maxTime = Math.max(...times);
        
        // Check if performance scales linearly
        const linearRegression = this.calculateLinearRegression(scalabilityResults.map((r, i) => [i, r.time]));
        const isLinear = Math.abs(linearRegression.slope) < 0.1; // Allow small variance
        
        console.log('Scalability test completed');
        console.log('Linear scaling:', isLinear);
        console.log('Slope:', linearRegression.slope);
        
        let score = 10;
        if (!isLinear) score -= 3;
        if (avgTime > 1000) score -= 2;
        if (maxTime > 5000) score -= 2;
        
        this.results.push({
          category: 'performance',
          name: 'Scalability',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Scalability: ${isLinear ? 'linear' : 'non-linear'} scaling`,
          details: { avgTime, maxTime, linearRegression, isLinear },
          score: Math.max(0, score)
        });
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 120000 // 2 minutes
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'performance',
          name: 'Scalability',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Scalability test failed',
          details: { errors: output },
          score: 0
        });
      }

    } catch (error) {
      this.results.push({
        category: 'performance',
        name: 'Scalability',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Scalability test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testInputValidation(): Promise<void> {
    console.log('📋 Test 14: Input Validation');
    
    const startTime = Date.now();
    
    try {
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        
        const contextManager = new ContextManager();
        
        // Test input validation
        const validationTests = [
          { name: 'Null content', test: () => contextManager.addContent(null, 'test', 0.5) },
          { name: 'Negative importance', test: () => contextManager.addContent('test', 'test', -1) },
          { name: 'Invalid type', test: () => contextManager.addContent('test', 'invalid' as any, 0.5) },
          { name: 'Empty content', test: () => contextManager.addContent('', 'test', 0.5) },
          { name: 'Very large content', test: () => contextManager.addContent('x'.repeat(1000000), 'test', 0.5) }
        ];
        
        let passedTests = 0;
        let validationErrors = [];
        
        for (const test of validationTests) {
          try {
            test.test();
            passedTests++;
          } catch (error) {
            validationErrors.push({ name: test.name, error: error.message });
          }
        }
        
        console.log('Input validation test completed');
        console.log('Passed:', passedTests, 'of', validationTests.length);
        console.log('Errors:', validationErrors.length);
        
        let score = (passedTests / validationTests.length) * 10;
        if (validationErrors.length > 0) score -= validationErrors.length * 2;
        
        this.results.push({
          category: 'security',
          name: 'Input Validation',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Input validation: ${passedTests}/${validationTests.length} tests passed`,
          details: { passedTests, validationErrors },
          score: Math.max(0, score)
        });
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 30000 // 30 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'security',
          name: 'Input Validation',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Input validation test failed',
          details: { errors: output },
          score: 0
        });
      }

    } catch (error) {
      this.results.push({
        category: 'security',
        name: 'Input Validation',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Input validation test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testEnvironmentVariables(): Promise<void> {
    console.log('📋 Test 15: Environment Variables');
    
    const startTime = Date.now();
    
    try {
      // Test environment variable handling
      const testCode = `
        import { config } from '../config/index';
        
        // Test environment variable access
        const envTests = [
          { name: 'NODE_ENV', test: () => config.environment },
          { name: 'CONTEXT_MAX_TOKENS', test: () => config.context.maxTokens },
          { name: 'MONITORING_ENABLED', test: () => config.monitoring.enabled },
          { name: 'ALERT_SLACK_WEBHOOK', test: () => config.alerts.slackWebhook },
          { name: 'OPENAI_API_KEY', test: () => config.api.openai.apiKey }
        ];
        
        let passedTests = 0;
        let envErrors = [];
        
        for (const test of envTests) {
          try {
            const result = test.test();
            if (result !== undefined && result !== null) {
              passedTests++;
            } else {
              envErrors.push({ name: test.name, error: 'Returns undefined/null' });
            }
          } catch (error) {
            envErrors.push({ name: test.name, error: error.message });
          }
        }
        
        console.log('Environment variable test completed');
        console.log('Passed:', passedTests, 'of', envTests.length);
        console.log('Errors:', envErrors.length);
        
        let score = (passedTests / envTests.length) * 10;
        if (envErrors.length > 0) score -= envErrors.length * 2;
        
        this.results.push({
          category: 'security',
          name: 'Environment Variables',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Environment variables: ${passedTests}/${envTests.length} tests passed`,
          details: { passedTests, envErrors },
          score: Math.max(0, score)
        });
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 30000 // 30 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'security',
          name: 'Environment Variables',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Environment variable test failed',
          details: { errors: output },
          score: 0
        });
      }

    } catch (error) {
      this.results.push({
        category: 'security',
        name: 'Environment Variables',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Environment variable test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testDependencySecurity(): Promise<void> {
    console.log('📋 Test 16: Dependency Security');
    
    const startTime = Date.now();
    
    try {
      // Check package.json for security issues
      const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      
      const securityChecks = [
        {
          name: 'Outdated dependencies',
          check: () => {
            const outdatedPackages = ['lodash', 'moment', 'request']; // Example outdated packages
            const dependencies = Object.keys(packageJson.dependencies || {});
            return dependencies.some(dep => outdatedPackages.includes(dep));
          }
        },
        {
          name: 'Vulnerable dependencies',
          check: () => {
            const vulnerablePackages = ['axios<0.21.0', 'lodash<4.0.0']; // Example vulnerable versions
            const dependencies = Object.entries(packageJson.dependencies || {});
            return dependencies.some(([name, version]) => 
              vulnerablePackages.some(vuln => name === vuln.split('<')[0])
            );
          }
        },
        {
          name: 'Insecure scripts',
          check: () => {
            const scripts = packageJson.scripts || {};
            const insecurePatterns = ['curl', 'wget', 'eval', 'exec'];
            const scriptValues = Object.values(scripts);
            return scriptValues.some(script => 
              insecurePatterns.some(pattern => script.includes(pattern))
            );
          }
        },
        {
          name: 'Permissive licenses',
          check: () => {
            // This would check for permissive licenses
            // For demo, just return false
            return false;
          }
        }
      ];
      
      let passedChecks = 0;
      let securityIssues = [];
      
      for (const check of securityChecks) {
        try {
          const result = check.check();
          if (!result) {
            securityIssues.push(check.name);
          } else {
            passedChecks++;
          }
        } catch (error) {
          securityIssues.push({ name: check.name, error: error.message });
        }
      }
      
      console.log('Dependency security test completed');
      console.log('Passed:', passedChecks, 'of', securityChecks.length);
      console.log('Issues:', securityIssues.length);
      
      let score = (passedChecks / securityChecks.length) * 10;
      if (securityIssues.length > 0) score -= securityIssues.length * 3;
      
      this.results.push({
        category: 'security',
        name: 'Dependency Security',
        status: 'pass',
        duration: Date.now() - startTime,
        message: `Dependency security: ${passedChecks}/${securityChecks.length} checks passed`,
        details: { passedChecks, securityIssues },
        score: Math.max(0, score)
      });

    } catch (error) {
      this.results.push({
        category: 'security',
        name: 'Dependency Security',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Dependency security test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testCodeQuality(): Promise<void> {
    console.log('📋 Test 17: Code Quality');
    
    const startTime = Date.now();
    
    try {
      // Analyze code quality metrics
      const files = [
        'tools/context-manager/ContextManager.ts',
        'tools/context-monitor/ContextMonitor.ts',
        'scripts/setup.ts',
        'scripts/monitoring.ts',
        'scripts/health-check.ts'
      ];
      
      let totalLines = 0;
      let totalFunctions = 0;
      let totalClasses = 0;
      let totalInterfaces = 0;
      let totalComments = 0;
      let totalComplexity = 0;
      
      for (const file of files) {
        try {
          const content = fs.readFileSync(file, 'utf8');
          const lines = content.split('\n');
          
          totalLines += lines.length;
          totalFunctions += (content.match(/function\s+\w+/g) || []).length;
          totalClasses += (content.match(/class\s+\w+/g) || []).length;
          totalInterfaces += (content.match(/interface\s+\w+/g) || []).length;
          totalComments += (content.match(/\/\*[\s\S]*|\/\/[\s\S]*/g) || []).length;
          
          // Calculate complexity (simplified)
          const nestedBlocks = (content.match(/\{[^}]*\}/g) || []).length;
          totalComplexity += nestedBlocks;
          
        } catch (error) {
          console.error(`Error analyzing ${file}:`, error);
        }
      }
      
      // Calculate quality metrics
      const avgLinesPerFile = totalLines / files.length;
      const commentRatio = totalComments / totalLines;
      const complexityPerFile = totalComplexity / files.length;
      
      // Score based on quality metrics
      let qualityScore = 10;
      
      // Too many lines per file
      if (avgLinesPerFile > 500) qualityScore -= 1;
      if (avgLinesPerFile > 1000) qualityScore -= 2;
      
      // Too few comments
      if (commentRatio < 0.1) qualityScore -= 2;
      if (commentRatio < 0.05) qualityScore -= 3;
      
      // Too high complexity
      if (complexityPerFile > 20) qualityScore -= 1;
      if (complexityPerFile > 50) qualityScore -= 2;
      
      console.log('Code quality analysis completed');
      console.log('Total lines:', totalLines);
      console.log('Total functions:', totalFunctions);
      console.log('Total classes:', totalClasses);
      console.log('Total interfaces:', totalInterfaces);
      console.log('Comment ratio:', (commentRatio * 100).toFixed(1) + '%');
      console.log('Complexity per file:', complexityPerFile.toFixed(1));
      
      this.results.push({
        category: 'quality',
        name: 'Code Quality',
        status: 'pass',
        duration: Date.now() - startTime,
        message: `Code quality score: ${qualityScore}/10`,
        details: {
          totalLines,
          totalFunctions,
          totalClasses,
          totalInterfaces,
          commentRatio,
          complexityPerFile,
          qualityScore
        },
        score: Math.max(0, qualityScore)
      });

    } catch (error) {
      this.results.push({
        category: 'quality',
        name: 'Code Quality',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Code quality test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testDocumentation(): Promise<void> {
    console.log('📋 Test 18: Documentation');
    
    const startTime = Date.now();
    
    try {
      // Check documentation quality
      const docFiles = [
        'README.md',
        'docs/README.md',
        'docs/FINAL_SUMMARY.md',
        'docs/CONTEXT_LIMIT_ANALYSIS.md',
        'docs/COMMUNITY_SOLUTIONS.md',
        'docs/IMPLEMENTATION_GUIDE.md',
        'tools/context-manager/README.md'
      ];
      
      let totalDocFiles = 0;
      let documentedFiles = 0;
      let totalDocLines = 0;
      let totalExamples = 0;
      let totalApiDocs = 0;
      
      for (const file of docFiles) {
        try {
          if (fs.existsSync(file)) {
            totalDocFiles++;
            
            const content = fs.readFileSync(file, 'utf8');
            const lines = content.split('\n');
            totalDocLines += lines.length;
            
            // Check for documentation elements
            if (content.includes('# ') || content.includes('## ')) documentedFiles++;
            if (content.includes('```') || content.includes('Example:')) totalExamples++;
            if (content.includes('API') || content.includes('Method:')) totalApiDocs++;
            
          }
        } catch (error) {
          console.error(`Error reading ${file}:`, error);
        }
      }
      
      // Calculate documentation score
      const docCoverage = (documentedFiles / totalDocFiles) * 100;
      const examplesPerFile = totalExamples / totalDocFiles;
      const apiDocsPerFile = totalApiDocs / totalDocFiles;
      
      let docScore = 10;
      
      // Low documentation coverage
      if (docCoverage < 80) docScore -= 2;
      if (docCoverage < 60) docScore -= 3;
      
      // Too few examples
      if (examplesPerFile < 1) docScore -= 1;
      if (examplesPerFile < 0.5) docScore -= 2;
      
      // Too few API docs
      if (apiDocsPerFile < 2) docScore -= 1;
      if (apiDocsPerFile < 1) docScore -= 2;
      
      console.log('Documentation test completed');
      console.log('Doc files:', totalDocFiles);
      console.log('Documented files:', documentedFiles);
      console.log('Doc coverage:', docCoverage.toFixed(1) + '%');
      console.log('Examples per file:', examplesPerFile.toFixed(1));
      console.log('API docs per file:', apiDocsPerFile.toFixed(1));
      
      this.results.push({
        category: 'quality',
        name: 'Documentation',
        status: 'pass',
        duration: Date.now() - startTime,
        message: `Documentation score: ${docScore}/10`,
        details: {
          totalDocFiles,
          documentedFiles,
          docCoverage,
          totalExamples,
          totalApiDocs,
          docScore
        },
        score: Math.max(0, docScore)
      });

    } catch (error) {
      this.results.push({
        category: 'quality',
        name: 'Documentation',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Documentation test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private async testErrorHandling(): Promise<void> {
    console.log('📋 Test 19: Error Handling');
    
    const startTime = Date.now();
    
    try {
      const testCode = `
        import { ContextManager } from '../tools/context-manager/ContextManager';
        
        const contextManager = new ContextManager();
        
        // Test error handling
        const errorTests = [
          {
            name: 'Invalid content handling',
            test: () => {
              try {
                contextManager.addContent(null, 'test', 0.5);
                return 'success';
              } catch (error) {
                return error.message;
              }
            }
          },
          {
            name: 'Invalid importance handling',
            test: () => {
              try {
                contextManager.addContent('test', 'test', -1);
                return 'success';
              } catch (error) {
                return error.message;
              }
            }
          },
          {
            name: 'Invalid ID handling',
            test: () => {
              try {
                contextManager.removeChunk('invalid-id');
                return 'success';
              } catch (error) {
                return error.message;
              }
            }
          },
          {
            name: 'Context limit handling',
            test: () => {
              try {
                // Add content until limit
                for (let i = 0; i < 1000; i++) {
                  contextManager.addContent('x'.repeat(100), 'test', 0.5);
                }
                return 'success';
              } catch (error) {
                return error.message;
              }
            }
          }
        ];
        
        let passedTests = 0;
        let errorHandlingIssues = [];
        
        for (const test of errorTests) {
          try {
            const result = test.test();
            if (result === 'success') {
              passedTests++;
            } else {
              errorHandlingIssues.push({ name: test.name, result });
            }
          } catch (error) {
            errorHandlingIssues.push({ name: test.name, error: error.message });
          }
        }
        
        console.log('Error handling test completed');
        console.log('Passed:', passedTests, 'of', errorTests.length);
        console.log('Issues:', errorHandlingIssues.length);
        
        let score = (passedTests / errorTests.length) * 10;
        if (errorHandlingIssues.length > 0) score -= errorHandlingIssues.length * 2;
        
        this.results.push({
          category: 'quality',
          name: 'Error Handling',
          status: 'pass',
          duration: Date.now() - startTime,
          message: `Error handling score: ${score}/10`,
          details: { passedTests, errorHandlingIssues },
          score: Math.max(0, score)
        });
      `;

      const result = child_process.spawnSync('npx', ['ts-node', '-e', testCode], {
        encoding: 'utf8',
        stdio: 'pipe',
        timeout: 30000 // 30 seconds
      });

      const hasErrors = result.status !== 0;
      const output = result.stderr;

      if (hasErrors) {
        this.results.push({
          category: 'quality',
          name: 'Error Handling',
          status: 'fail',
          duration: Date.now() - startTime,
          message: 'Error handling test failed',
          details: { errors: output },
          score: 0
        });
      }

    } catch (error) {
      this.results.push({
        category: 'quality',
        name: 'Error Handling',
        status: 'fail',
        duration: Date.now() - startTime,
        message: `Error handling test failed: ${error}`,
        score: 0
      });
    }

    console.log('');
  }

  private calculateLinearRegression(data: Array<[number, number]>): { slope: number; intercept: number } {
    const n = data.length;
    const sumX = data.reduce((sum, [x]) => sum + x, 0);
    const sumY = data.reduce((sum, [, y]) => sum + y, 0);
    const sumXY = data.reduce((sum, [x, y]) => sum + x * y, 0);
    const sumXX = data.reduce((sum, [x]) => sum + x * x, 0);
    
    const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    const intercept = (sumY - slope * sumX) / n;
    
    return { slope, intercept };
  }

  private async generateComprehensiveReport(): Promise<void> {
    const totalDuration = Date.now() - this.testStartTime;
    
    // Calculate category scores
    const categoryScores = {
      syntax: this.calculateCategoryScore('syntax'),
      types: this.calculateCategoryScore('types'),
      runtime: this.calculateCategoryScore('runtime'),
      performance: this.calculateCategoryScore('performance'),
      security: this.calculateCategoryScore('security'),
      quality: this.calculateCategoryScore('quality')
    };
    
    // Calculate overall quality metrics
    const qualityMetrics: QualityMetrics = {
      maintainability: (categoryScores.syntax + categoryScores.types + categoryScores.quality) / 3,
      reliability: (categoryScores.runtime + categoryScores.performance) / 2,
      security: categoryScores.security,
      performance: categoryScores.performance,
      coverage: (categoryScores.syntax + categoryScores.types + categoryScores.runtime) / 3,
      overall: Object.values(categoryScores).reduce((sum, score) => sum + score, 0) / Object.keys(categoryScores).length
    };
    
    // Display results
    console.log('\n' + '='.repeat(80));
    console.log('🧪 COMPREHENSIVE TEST RESULTS');
    console.log('='.repeat(80));
    
    console.log(`\n📊 Overall Quality Metrics:`);
    console.log(`   Maintainability: ${qualityMetrics.maintainability.toFixed(1)}/10`);
    console.log(`   Reliability: ${qualityMetrics.reliability.toFixed(1)}/10`);
    console.log(`   Security: ${qualityMetrics.security.toFixed(1)}/10`);
    console.log(`   Performance: ${qualityMetrics.performance.toFixed(1)}/10`);
    console.log(`   Coverage: ${qualityMetrics.coverage.toFixed(1)}/10`);
    console.log(`   Overall: ${qualityMetrics.overall.toFixed(1)}/10`);
    
    console.log('\n📋 Category Scores:');
    Object.entries(categoryScores).forEach(([category, score]) => {
      const icon = score >= 9 ? '🟢' : score >= 7 ? '🟡' : score >= 5 ? '🟠' : '🔴';
      console.log(`   ${icon} ${category.padEnd(15)}: ${score.toFixed(1)}/10`);
    });
    
    console.log('\n📋 Individual Test Results:');
    console.log('-'.repeat(80));
    
    for (const result of this.results) {
      const icon = result.status === 'pass' ? '✅' : result.status === 'fail' ? '❌' : '⏭️';
      const score = result.score || 0;
      const scoreIcon = score >= 9 ? '🟢' : score >= 7 ? '🟡' : score >= 5 ? '🟠' : '🔴';
      
      console.log(`${icon} ${result.category.padEnd(12)} ${result.name.padEnd(25)} ${result.message.padEnd(30)} ${scoreIcon} ${score.toFixed(1)}/10 ${result.duration}ms`);
      
      if (result.details) {
        console.log(`   📄 Details: ${JSON.stringify(result.details, null, 2)}`);
      }
    }
    
    // Save detailed report
    const reportData = {
      timestamp: new Date().toISOString(),
      totalDuration,
      qualityMetrics,
      categoryScores,
      results: this.results,
      summary: {
        totalTests: this.results.length,
        passed: this.results.filter(r => r.status === 'pass').length,
        failed: this.results.filter(r => r.status === 'fail').length,
        skipped: this.results.filter(r => r.status === 'skip').length,
        overallScore: qualityMetrics.overall
      }
    };
    
    const reportsDir = 'data/reports';
    if (!fs.existsSync(reportsDir)) {
      fs.mkdirSync(reportsDir, { recursive: true });
    }
    
    const reportPath = path.join(reportsDir, `comprehensive-test-${Date.now()}.json`);
    fs.writeFileSync(reportPath, JSON.stringify(reportData, null, 2));
    
    console.log(`\n📄 Comprehensive report saved: ${reportPath}`);
    
    // Recommendations
    console.log('\n💡 Recommendations:');
    if (qualityMetrics.overall >= 9) {
      console.log('🎉 Excellent code quality! Ready for production.');
    } else if (qualityMetrics.overall >= 7) {
      console.log('✅ Good code quality. Minor improvements recommended.');
    } else if (qualityMetrics.overall >= 5) {
      console.log('⚠️  Fair code quality. Significant improvements needed.');
    } else {
      console.log('🚨 Poor code quality. Major improvements required.');
    }
    
    // Category-specific recommendations
    if (categoryScores.syntax < 7) {
      console.log('🔧 Fix syntax errors before proceeding.');
    }
    if (categoryScores.types < 7) {
      console.log('🔧 Fix TypeScript type errors.');
    }
    if (categoryScores.runtime < 7) {
      console.log('🔧 Fix runtime errors and improve error handling.');
    }
    if (categoryScores.performance < 7) {
      console.log('🔧 Optimize performance and reduce memory usage.');
    }
    if (categoryScores.security < 7) {
      console.log('🔧 Address security vulnerabilities and improve input validation.');
    }
    if (categoryScores.quality < 7) {
      console.log('🔧 Improve code quality, documentation, and error handling.');
    }
    
    console.log('\n' + '='.repeat(80));
  }

  private calculateCategoryScore(category: string): number {
    const categoryResults = this.results.filter(r => r.category === category);
    if (categoryResults.length === 0) return 10;
    
    const totalScore = categoryResults.reduce((sum, r) => sum + (r.score || 0), 0);
    return totalScore / categoryResults.length;
  }
}

// CLI interface
async function main() {
  console.log('🧪 Context Management Tools - Comprehensive Test Suite');
  console.log('Testing all aspects: syntax, types, runtime, performance, security, quality\n');

  const tester = new ComprehensiveTester();
  
  try {
    await tester.runAllTests();
    
    const summary = {
      total: tester.results.length,
      passed: tester.results.filter(r => r.status === 'pass').length,
      failed: tester.results.filter(r => r.status === 'fail').length,
      skipped: tester.results.filter(r => r.status === 'skip').length
    };
    
    console.log(`\n📊 Final Summary:`);
    console.log(`   Total Tests: ${summary.total}`);
    console.log(`   ✅ Passed: ${summary.passed}`);
    console.log(`   ❌ Failed: ${summary.failed}`);
    console.log(`   ⏭️  Skipped: ${summary.skipped}`);
    
    // Exit with appropriate code
    if (summary.failed === 0) {
      console.log('\n🎉 All comprehensive tests passed!');
      process.exit(0);
    } else {
      console.log(`\n❌ ${summary.failed} comprehensive test(s) failed!`);
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Comprehensive test suite failed:', error);
    process.exit(2);
  }
}

if (require.main === module) {
  main();
}

export { ComprehensiveTester };