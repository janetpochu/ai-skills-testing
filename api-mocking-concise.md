# API Mocking Reference

Record and mock API responses for deterministic E2E tests. Automatically captures `/api/*-proxy/v*` endpoints and organizes by feature and profile.

---

## Core Concept

```
RECORD MODE:  Explore page → Capture API calls → Save as stubs
MOCK MODE:    Load stubs → Run tests (no backend needed)
```

---

## File Structure

```
__mocks__/api/
├── {feature}/              # Feature name (e.g., landing, credit-card-overview)
│   └── {profile}/          # Profile ID (e.g., 506pedaut8098)
│       ├── {endpoint}.json # API response
│       └── metadata.json   # Auto-generated (URL mappings)
```

**Example:**
```
__mocks__/api/
├── landing/
│   ├── 506pedaut8098/
│   │   ├── accounts_summary.json
│   │   ├── quick_actions.json
│   │   └── metadata.json
│   └── 506opeduat8119/
│       ├── accounts_summary.json
│       ├── securities_portfolio.json
│       └── metadata.json
└── credit-card-overview/
    └── 506pedaut8098/
        ├── card_details.json
        └── metadata.json
```

---

## Implementation

### mockServer.ts

```typescript
import { Page, Route } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

const MOCKS_DIR = '__mocks__/api';

interface RecordConfig {
  feature: string;    // Feature name
  profile: string;    // Profile ID
}

interface StubMeta {
  url: string;
  method: string;
  status: number;
  timestamp: string;
}

// ============================================================================
// RECORD STUBS - Captures /api/*-proxy/v* endpoints
// ============================================================================

export async function recordStubs(page: Page, config: RecordConfig): Promise<void> {
  const outputDir = path.join(MOCKS_DIR, config.feature, config.profile);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const metadata: StubMeta[] = [];

  // Capture all /api/*-proxy/v* requests
  await page.route('**/api/*-proxy/v*/**', async (route: Route) => {
    const request = route.request();
    
    try {
      const response = await route.fetch();
      const body = await response.json().catch(() => response.text());
      
      // Extract endpoint name from URL
      const url = new URL(request.url());
      const parts = url.pathname.split('/');
      const proxyIdx = parts.findIndex(p => p.includes('proxy'));
      const endpoint = parts.slice(proxyIdx + 2).join('_').replace(/[^a-zA-Z0-9_]/g, '_');
      
      // Save response
      const filename = `${endpoint}.json`;
      fs.writeFileSync(
        path.join(outputDir, filename),
        JSON.stringify(body, null, 2)
      );
      
      // Track metadata
      metadata.push({
        url: request.url(),
        method: request.method(),
        status: response.status(),
        timestamp: new Date().toISOString(),
      });
      
      console.log(`📝 Recorded: ${config.feature}/${config.profile}/${filename}`);
      
      await route.fulfill({
        status: response.status(),
        headers: response.headers(),
        body: JSON.stringify(body),
      });
    } catch (error) {
      console.error(`❌ Failed to record: ${request.url()}`);
      await route.continue();
    }
  });

  // Save metadata on close
  page.on('close', () => {
    if (metadata.length > 0) {
      fs.writeFileSync(
        path.join(outputDir, 'metadata.json'),
        JSON.stringify(metadata, null, 2)
      );
    }
  });
}

// ============================================================================
// LOAD STUBS - Mocks all endpoints for feature/profile
// ============================================================================

export async function loadStubs(page: Page, config: RecordConfig): Promise<void> {
  const stubDir = path.join(MOCKS_DIR, config.feature, config.profile);
  const metaPath = path.join(stubDir, 'metadata.json');
  
  if (!fs.existsSync(metaPath)) {
    throw new Error(`No stubs found: ${config.feature}/${config.profile}`);
  }

  const metadata: StubMeta[] = JSON.parse(fs.readFileSync(metaPath, 'utf-8'));

  for (const meta of metadata) {
    const url = new URL(meta.url);
    const parts = url.pathname.split('/');
    const proxyIdx = parts.findIndex(p => p.includes('proxy'));
    const endpoint = parts.slice(proxyIdx + 2).join('_').replace(/[^a-zA-Z0-9_]/g, '_');
    const stubPath = path.join(stubDir, `${endpoint}.json`);

    if (fs.existsSync(stubPath)) {
      const data = JSON.parse(fs.readFileSync(stubPath, 'utf-8'));
      const pattern = `**/api/*-proxy/v*/${parts.slice(proxyIdx + 2).join('/')}`;
      
      await page.route(pattern, async (route: Route) => {
        await route.fulfill({
          status: meta.status,
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify(data),
        });
      });
    }
  }
  
  console.log(`✅ Loaded ${metadata.length} mocks: ${config.feature}/${config.profile}`);
}
```

---

## Global Mock Flag

### playwright.config.ts

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    // Global mock flag - set via environment variable
    // USE_MOCKS=true  → Use recorded stubs (fast, no backend)
    // USE_MOCKS=false → Real E2E (hits actual API)
    baseURL: process.env.BASE_URL || 'https://localhost:3000',
  },
  
  // Store mock flag in global scope
  globalSetup: require.resolve('./global-setup.ts'),
});
```

### global-setup.ts

```typescript
export default function globalSetup() {
  // Make USE_MOCKS available globally
  process.env.USE_MOCKS = process.env.USE_MOCKS || 'false';
  console.log(`🎯 Mock Mode: ${process.env.USE_MOCKS === 'true' ? 'ENABLED' : 'DISABLED'}`);
}
```

### test-helpers.ts

```typescript
import { Page } from '@playwright/test';
import { recordStubs, loadStubs } from './mockServer';

/**
 * Setup mocks based on global flag
 * - USE_MOCKS=true  → Load stubs
 * - USE_MOCKS=false → Record stubs (or do nothing)
 */
export async function setupMocks(
  page: Page,
  feature: string,
  profile: string,
  recordIfMissing = false
): Promise<void> {
  const useMocks = process.env.USE_MOCKS === 'true';

  if (useMocks) {
    // Mock mode - load stubs
    await loadStubs(page, { feature, profile });
  } else if (recordIfMissing) {
    // Real E2E mode - optionally record stubs
    await recordStubs(page, { feature, profile });
  }
}
```

---

## Usage in Tests

### Recording Stubs (One-Time Setup)

```typescript
import { test } from '@playwright/test';
import { recordStubs } from '../utils/mockServer';

test.describe('RECORD STUBS', () => {
  
  test('record landing page - profile 506pedaut8098', async ({ page }) => {
    // Start recording
    await recordStubs(page, {
      feature: 'landing',
      profile: '506pedaut8098',
    });
    
    // Navigate and explore
    await page.goto('/login');
    await page.fill('#username', 'user506pedaut8098');
    await page.click('#login');
    await page.goto('/landing');
    
    // All /api/*-proxy/v* calls saved to:
    // __mocks__/api/landing/506pedaut8098/*.json
  });
  
  test('record credit card - profile 506pedaut8098', async ({ page }) => {
    await recordStubs(page, {
      feature: 'credit-card-overview',
      profile: '506pedaut8098',
    });
    
    await page.goto('/credit-card/overview');
  });
  
});
```

### Using Mocks in Tests (Global Flag)

```typescript
import { test, expect } from '@playwright/test';
import { setupMocks } from '../utils/test-helpers';
import { LandingPage } from './pages/landing-page';

test.describe('Landing Page Tests', () => {
  
  test('shows accounts for profile 506pedaut8098', async ({ page }) => {
    // Auto-switches based on USE_MOCKS flag
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto('/landing');
    
    await expect(landingPage.integratedAccount).toBeVisible();
    await expect(landingPage.creditCardAccount).toBeVisible();
  });
  
  test('shows all accounts for profile 506opeduat8119', async ({ page }) => {
    await setupMocks(page, 'landing', '506opeduat8119');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto('/landing');
    
    await expect(landingPage.securitiesAccount).toBeVisible();
    await expect(landingPage.fxAccount).toBeVisible();
  });
  
});
```

---

## Running Tests

```bash
# Real E2E (hits actual backend)
npx playwright test

# Mock mode (uses recorded stubs)
USE_MOCKS=true npx playwright test

# Record stubs
npx playwright test --grep "RECORD STUBS"

# Record + Run tests with mocks
npx playwright test --grep "RECORD STUBS" && USE_MOCKS=true npx playwright test
```

---

## AI Instructions

When generating E2E tests:

1. **Auto-detect features** from page URL/context (e.g., `/landing` → feature: `landing`)
2. **Auto-detect profile** from test data or URL params
3. **Always call `setupMocks()`** at start of each test
4. **Pattern to capture**: `/api/*-proxy/v*` (any path containing `-proxy/v`)
5. **Filename format**: `{endpoint_path}.json` (replace `/` with `_`)
6. **Metadata required**: Always generate `metadata.json` with URL mappings

### Code Generation Template

```typescript
test('generated test', async ({ page }) => {
  // ALWAYS include setupMocks at the start
  await setupMocks(page, '{auto-detected-feature}', '{profile-id}');
  
  // Rest of test
  const {page-object} = new {PageObject}(page);
  await {page-object}.goto('{url}');
  
  // Assertions
  await expect({page-object}.{element}).toBeVisible();
});
```

### Recording Template

```typescript
test('record {feature} - {profile}', async ({ page }) => {
  await recordStubs(page, {
    feature: '{feature}',
    profile: '{profile}',
  });
  
  // Navigate through the flow
  await page.goto('{url}');
  // Interact with page to trigger API calls
});
```

---

## Best Practices

✅ **DO:**
- Use `setupMocks()` in every test
- Organize by feature → profile
- Commit stubs and metadata.json to git
- Use descriptive feature names (`landing`, `credit-card-overview`)
- Use actual profile IDs (`506pedaut8098`)

❌ **DON'T:**
- Hardcode mock vs real logic in tests
- Skip metadata.json (required for loading)
- Mix different features in same directory
- Use generic names (`test1`, `feature1`)

---

## Quick Reference

| Action | Command |
|--------|---------|
| Run with mocks | `USE_MOCKS=true npx playwright test` |
| Run real E2E | `npx playwright test` |
| Record stubs | Run tests with `recordStubs()` |
| Check stubs exist | Look for `__mocks__/api/{feature}/{profile}/metadata.json` |

| Function | Purpose |
|----------|---------|
| `recordStubs(page, {feature, profile})` | Capture API calls and save stubs |
| `loadStubs(page, {feature, profile})` | Mock API calls with saved stubs |
| `setupMocks(page, feature, profile)` | Auto-switch based on USE_MOCKS flag |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No stubs found | Run recording test first |
| Stubs not loading | Check `metadata.json` exists |
| Wrong data | Re-record stubs for that profile |
| Pattern not matching | Verify URL contains `/api/*-proxy/v*` |
