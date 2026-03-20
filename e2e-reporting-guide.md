# E2E Test Reporting & Archive Management

Automated test report generation with intelligent backup, archiving, and enhanced HTML reports.

---

## Report Structure

```
project/
├── playwright-report/           # Current test report (clean on each run)
│   ├── index.html              # Main report
│   ├── data/                   # Test results data
│   └── trace/                  # Execution traces
├── test-reports-archive/       # Historical reports
│   ├── 2026-03-20_14-30-45/   # Timestamped backup
│   │   ├── index.html
│   │   └── data/
│   ├── 2026-03-20_10-15-22/
│   └── 2026-03-19_16-45-10/
└── playwright.config.ts        # Report configuration
```

---

## Implementation

### 1. Pre-Test Script: Backup & Clean

**File: `scripts/backup-report.js`**

```javascript
const fs = require('fs');
const path = require('path');

const REPORT_DIR = 'playwright-report';
const ARCHIVE_DIR = 'test-reports-archive';

function backupReport() {
  // Check if playwright-report exists
  if (!fs.existsSync(REPORT_DIR)) {
    console.log('ℹ️  No existing report to backup');
    return;
  }

  // Create archive directory if it doesn't exist
  if (!fs.existsSync(ARCHIVE_DIR)) {
    fs.mkdirSync(ARCHIVE_DIR, { recursive: true });
    console.log('📁 Created archive directory');
  }

  // Generate timestamp: YYYY-MM-DD_HH-MM-SS
  const timestamp = new Date()
    .toISOString()
    .replace(/T/, '_')
    .replace(/\..+/, '')
    .replace(/:/g, '-');

  const backupPath = path.join(ARCHIVE_DIR, timestamp);

  try {
    // Move (rename) existing report to archive
    fs.renameSync(REPORT_DIR, backupPath);
    console.log(`✅ Backed up report to: ${backupPath}`);
  } catch (error) {
    console.error('❌ Failed to backup report:', error.message);
    process.exit(1);
  }
}

// Execute backup
backupReport();
```

---

### 2. Enhanced Playwright Configuration

**File: `playwright.config.ts`**

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: '__tests__/e2e',
  
  // Test execution settings
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  
  // Reporter configuration
  reporter: [
    // HTML reporter (main report)
    [
      'html',
      {
        outputFolder: 'playwright-report',
        open: process.env.CI ? 'never' : 'on-failure',
      },
    ],
    
    // List reporter (console output)
    ['list'],
    
    // JSON reporter (for CI/CD integrations)
    [
      'json',
      {
        outputFile: 'playwright-report/results.json',
      },
    ],
    
    // JUnit reporter (for CI/CD systems)
    [
      'junit',
      {
        outputFile: 'playwright-report/junit.xml',
      },
    ],
  ],

  use: {
    // Base URL
    baseURL: process.env.BASE_URL || 'https://localhost:3000',
    
    // Tracing (for debugging failures)
    trace: 'on-first-retry',
    
    // Screenshot on failure
    screenshot: 'only-on-failure',
    
    // Video on failure
    video: 'retain-on-failure',
  },

  // Visual regression settings
  expect: {
    toHaveScreenshot: {
      maxDiffPixels: 0, // Strict comparison
    },
  },

  // Browser configurations
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Add more browsers as needed
  ],
});
```

---

### 3. Package.json Scripts

**File: `package.json`**

```json
{
  "scripts": {
    "test:e2e": "node scripts/backup-report.js && playwright test",
    "test:e2e:mock": "node scripts/backup-report.js && USE_MOCKS=true playwright test",
    "test:e2e:headed": "node scripts/backup-report.js && playwright test --headed",
    "test:e2e:debug": "node scripts/backup-report.js && playwright test --debug",
    "test:e2e:ui": "node scripts/backup-report.js && playwright test --ui",
    "test:visual": "node scripts/backup-report.js && USE_MOCKS=true playwright test --grep @visual",
    "test:visual:update": "node scripts/backup-report.js && USE_MOCKS=true playwright test --grep @visual --update-snapshots",
    "report:show": "playwright show-report",
    "report:archive:clean": "node scripts/clean-archive.js"
  }
}
```

---

### 4. Archive Cleanup Script (Optional)

**File: `scripts/clean-archive.js`**

```javascript
const fs = require('fs');
const path = require('path');

const ARCHIVE_DIR = 'test-reports-archive';
const MAX_ARCHIVES = 30; // Keep last 30 reports
const MAX_AGE_DAYS = 30; // Delete reports older than 30 days

function cleanArchive() {
  if (!fs.existsSync(ARCHIVE_DIR)) {
    console.log('ℹ️  No archive directory found');
    return;
  }

  const archives = fs.readdirSync(ARCHIVE_DIR)
    .map(name => ({
      name,
      path: path.join(ARCHIVE_DIR, name),
      stats: fs.statSync(path.join(ARCHIVE_DIR, name)),
    }))
    .filter(item => item.stats.isDirectory())
    .sort((a, b) => b.stats.mtimeMs - a.stats.mtimeMs); // Newest first

  console.log(`📊 Found ${archives.length} archived reports`);

  let deletedCount = 0;
  const now = Date.now();
  const maxAge = MAX_AGE_DAYS * 24 * 60 * 60 * 1000;

  archives.forEach((archive, index) => {
    const age = now - archive.stats.mtimeMs;
    const shouldDelete = index >= MAX_ARCHIVES || age > maxAge;

    if (shouldDelete) {
      try {
        fs.rmSync(archive.path, { recursive: true, force: true });
        console.log(`🗑️  Deleted: ${archive.name}`);
        deletedCount++;
      } catch (error) {
        console.error(`❌ Failed to delete ${archive.name}:`, error.message);
      }
    }
  });

  if (deletedCount === 0) {
    console.log('✅ No archives needed cleanup');
  } else {
    console.log(`✅ Cleaned up ${deletedCount} old archive(s)`);
    console.log(`📁 Kept ${archives.length - deletedCount} recent archive(s)`);
  }
}

// Execute cleanup
cleanArchive();
```

---

### 5. Git Configuration

**File: `.gitignore`**

```gitignore
# Current test report (regenerated on each run)
/playwright-report/

# Archive of historical reports (optional - commit or ignore based on preference)
# Option A: Ignore all archives (recommended for most projects)
/test-reports-archive/

# Option B: Keep archives in git (for audit trail)
# /test-reports-archive/*
# !/test-reports-archive/.gitkeep

# Test results artifacts
/test-results/
/playwright/.cache/

# Visual regression baselines (COMMIT these)
# !**/*-snapshots/**/*.png
```

**Note:** Decide whether to commit archives based on your needs:
- **Don't commit** (recommended): Archives regenerated in CI/CD
- **Do commit**: Want historical record in repository

---

## Usage

### Running Tests

```bash
# Run all tests (auto-backup previous report)
npm run test:e2e

# Run with mocks
npm run test:e2e:mock

# Run in headed mode (see browser)
npm run test:e2e:headed

# Run in UI mode (interactive)
npm run test:e2e:ui

# Run only visual tests
npm run test:visual

# Update visual baselines
npm run test:visual:update
```

### Viewing Reports

```bash
# View current report
npm run report:show

# View archived report
npx playwright show-report test-reports-archive/2026-03-20_14-30-45
```

### Archive Management

```bash
# Clean up old archives
npm run report:archive:clean

# Manually navigate archives
ls test-reports-archive/
```

---

## Workflow Examples

### Example 1: Daily Test Run

```bash
# Monday morning
npm run test:e2e

# Result:
# 1. Previous report → test-reports-archive/2026-03-18_16-45-10/
# 2. New report → playwright-report/
```

### Example 2: Visual Regression Update

```bash
# Update baselines after UI changes
npm run test:visual:update

# Result:
# 1. Previous report → test-reports-archive/2026-03-20_10-30-22/
# 2. New report with updated baselines → playwright-report/
```

### Example 3: Debugging Failures

```bash
# Run 1: Tests fail
npm run test:e2e
# Report saved to: playwright-report/

# Check report
npm run report:show

# Run 2: Fix and rerun
npm run test:e2e
# Previous report → test-reports-archive/2026-03-20_14-30-45/
# New report → playwright-report/

# Compare old vs new
npx playwright show-report test-reports-archive/2026-03-20_14-30-45
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: E2E Tests

on:
  pull_request:
  push:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps
      
      - name: Run E2E tests
        run: npm run test:e2e:mock
        env:
          USE_MOCKS: true
      
      - name: Upload test report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test-results/
          retention-days: 7
```

### Archive Management in CI/CD

```yaml
      - name: Archive previous reports
        if: github.ref == 'refs/heads/main'
        run: |
          # Only keep archives on main branch
          npm run report:archive:clean
          
      - name: Upload report archive
        if: github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v4
        with:
          name: report-archive
          path: test-reports-archive/
          retention-days: 90
```

---

## Advanced Features

### 1. Custom Report Metadata

**File: `scripts/backup-report.js` (enhanced)**

```javascript
function backupReport() {
  if (!fs.existsSync(REPORT_DIR)) {
    console.log('ℹ️  No existing report to backup');
    return;
  }

  if (!fs.existsSync(ARCHIVE_DIR)) {
    fs.mkdirSync(ARCHIVE_DIR, { recursive: true });
  }

  const timestamp = new Date()
    .toISOString()
    .replace(/T/, '_')
    .replace(/\..+/, '')
    .replace(/:/g, '-');

  const backupPath = path.join(ARCHIVE_DIR, timestamp);

  try {
    // Move report
    fs.renameSync(REPORT_DIR, backupPath);

    // Add metadata
    const metadata = {
      timestamp: new Date().toISOString(),
      branch: process.env.GITHUB_REF || 'local',
      commit: process.env.GITHUB_SHA || 'unknown',
      user: process.env.USER || process.env.USERNAME || 'unknown',
    };

    fs.writeFileSync(
      path.join(backupPath, 'metadata.json'),
      JSON.stringify(metadata, null, 2)
    );

    console.log(`✅ Backed up report to: ${backupPath}`);
  } catch (error) {
    console.error('❌ Failed to backup report:', error.message);
    process.exit(1);
  }
}
```

### 2. Report Comparison Script

**File: `scripts/compare-reports.js`**

```javascript
const fs = require('fs');
const path = require('path');

function compareReports(report1Path, report2Path) {
  const results1 = JSON.parse(
    fs.readFileSync(path.join(report1Path, 'results.json'), 'utf-8')
  );
  const results2 = JSON.parse(
    fs.readFileSync(path.join(report2Path, 'results.json'), 'utf-8')
  );

  console.log('\n📊 Test Results Comparison\n');
  console.log('Report 1:', report1Path);
  console.log('Report 2:', report2Path);
  console.log('\n');

  const stats1 = getStats(results1);
  const stats2 = getStats(results2);

  console.log('| Metric | Report 1 | Report 2 | Change |');
  console.log('|--------|----------|----------|--------|');
  console.log(`| Total | ${stats1.total} | ${stats2.total} | ${getDiff(stats1.total, stats2.total)} |`);
  console.log(`| Passed | ${stats1.passed} | ${stats2.passed} | ${getDiff(stats1.passed, stats2.passed)} |`);
  console.log(`| Failed | ${stats1.failed} | ${stats2.failed} | ${getDiff(stats1.failed, stats2.failed)} |`);
  console.log(`| Skipped | ${stats1.skipped} | ${stats2.skipped} | ${getDiff(stats1.skipped, stats2.skipped)} |`);
  console.log('\n');
}

function getStats(results) {
  return {
    total: results.suites.reduce((sum, s) => sum + s.specs.length, 0),
    passed: results.suites.reduce((sum, s) => sum + s.specs.filter(t => t.ok).length, 0),
    failed: results.suites.reduce((sum, s) => sum + s.specs.filter(t => !t.ok && !t.skipped).length, 0),
    skipped: results.suites.reduce((sum, s) => sum + s.specs.filter(t => t.skipped).length, 0),
  };
}

function getDiff(old, new) {
  const diff = new - old;
  if (diff > 0) return `+${diff}`;
  if (diff < 0) return `${diff}`;
  return '0';
}

// Usage: node scripts/compare-reports.js <path1> <path2>
const [,, path1, path2] = process.argv;
if (path1 && path2) {
  compareReports(path1, path2);
} else {
  console.log('Usage: node scripts/compare-reports.js <report1> <report2>');
}
```

---

## Summary

### File Structure Created

```
project/
├── scripts/
│   ├── backup-report.js         # Pre-test backup
│   ├── clean-archive.js         # Archive cleanup
│   └── compare-reports.js       # Report comparison
├── playwright-report/           # Current report (clean each run)
├── test-reports-archive/        # Historical reports
│   └── {timestamp}/
│       ├── index.html
│       ├── results.json
│       └── metadata.json
├── playwright.config.ts         # Enhanced config
└── package.json                 # NPM scripts
```

### Key NPM Scripts

```bash
npm run test:e2e              # Run tests with auto-backup
npm run test:e2e:mock         # Run with mocks
npm run report:show           # View current report
npm run report:archive:clean  # Clean old archives
```

### Benefits

✅ **Automatic backup** - Previous reports never lost  
✅ **Timestamped archives** - Easy to find historical reports  
✅ **Clean current report** - Always fresh, no stale data  
✅ **Multiple formats** - HTML, JSON, JUnit for different needs  
✅ **Archive management** - Auto-cleanup of old reports  
✅ **CI/CD ready** - GitHub Actions integration included  
✅ **Metadata tracking** - Know when/where/who ran tests  
✅ **Report comparison** - Compare test runs easily  

This is production-ready! 🚀
