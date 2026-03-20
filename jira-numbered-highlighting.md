# Assertion-Based Highlighting with Jira Numbering

Automatically highlight and capture screenshots based on assertion results with Jira ticket naming convention.

---

## Naming Convention

```
{JIRA-NUMBER}-{TEST-CASE-ID}-{EXPECT-COUNT}

Examples:
- PFUN126-001-1  (First expect in test case 001)
- PFUN126-001-2  (Second expect in test case 001)
- PFUN126-002-1  (First expect in test case 002)
```

---

## Implementation

### 1. Enhanced Visual Helpers with Assertion Wrapper

**File: `__tests__/utils/visual-helpers.ts`** (Enhanced)

```typescript
import { Page, Locator, test, expect as baseExpect } from '@playwright/test';

// ... previous highlight functions ...

/**
 * Wrapper around expect() that highlights and captures on pass/fail
 */
export async function expectWithHighlight(
  locator: Locator,
  screenshotName: string,
  options: {
    label?: string;
    labelPosition?: 'top' | 'bottom' | 'left' | 'right';
  } = {}
) {
  const { label, labelPosition = 'top' } = options;
  
  return {
    /**
     * Assert visibility and highlight
     */
    async toBeVisible() {
      try {
        // Perform assertion
        await baseExpect(locator).toBeVisible();
        
        // Success - highlight in green
        await highlightElement(locator, 'success');
        if (label) {
          await addAnnotation(locator, `✓ ${label}`, labelPosition);
        } else {
          await addAnnotation(locator, '✓ Visible', labelPosition);
        }
        
        // Wait for effect
        await locator.page().waitForTimeout(200);
        
        // Capture and attach
        const screenshot = await locator.screenshot();
        await test.info().attach(`${screenshotName} - ✓ PASS`, {
          body: screenshot,
          contentType: 'image/png',
        });
        
        // Cleanup
        await removeAnnotations(locator.page());
        await removeHighlight(locator);
        
      } catch (error) {
        // Failure - highlight in red
        await highlightElement(locator, 'error');
        if (label) {
          await addAnnotation(locator, `✗ ${label}`, labelPosition);
        } else {
          await addAnnotation(locator, '✗ Not Visible', labelPosition);
        }
        
        // Wait for effect
        await locator.page().waitForTimeout(200);
        
        // Capture failure and attach
        const screenshot = await locator.screenshot().catch(() => 
          locator.page().screenshot()
        );
        await test.info().attach(`${screenshotName} - ✗ FAIL`, {
          body: screenshot,
          contentType: 'image/png',
        });
        
        // Cleanup
        await removeAnnotations(locator.page());
        await removeHighlight(locator);
        
        // Re-throw error so test fails
        throw error;
      }
    },

    /**
     * Assert not visible and highlight
     */
    async not() {
      return {
        async toBeVisible() {
          try {
            await baseExpect(locator).not.toBeVisible();
            
            const parent = locator.locator('..');
            await highlightElement(parent, 'success');
            await addAnnotation(parent, '✓ Not Visible (Correct)', labelPosition);
            
            await parent.page().waitForTimeout(200);
            
            const screenshot = await parent.screenshot();
            await test.info().attach(`${screenshotName} - ✓ PASS`, {
              body: screenshot,
              contentType: 'image/png',
            });
            
            await removeAnnotations(parent.page());
            await removeHighlight(parent);
            
          } catch (error) {
            await highlightElement(locator, 'error');
            await addAnnotation(locator, '✗ Should Not Be Visible', labelPosition);
            
            await locator.page().waitForTimeout(200);
            
            const screenshot = await locator.screenshot().catch(() =>
              locator.page().screenshot()
            );
            await test.info().attach(`${screenshotName} - ✗ FAIL`, {
              body: screenshot,
              contentType: 'image/png',
            });
            
            await removeAnnotations(locator.page());
            await removeHighlight(locator);
            
            throw error;
          }
        }
      };
    },

    /**
     * Assert text content and highlight
     */
    async toContainText(expected: string | RegExp) {
      try {
        await baseExpect(locator).toContainText(expected);
        
        await highlightElement(locator, 'success');
        await addAnnotation(locator, `✓ Contains: "${expected}"`, labelPosition);
        
        await locator.page().waitForTimeout(200);
        
        const screenshot = await locator.screenshot();
        await test.info().attach(`${screenshotName} - ✓ PASS`, {
          body: screenshot,
          contentType: 'image/png',
        });
        
        await removeAnnotations(locator.page());
        await removeHighlight(locator);
        
      } catch (error) {
        await highlightElement(locator, 'error');
        await addAnnotation(locator, `✗ Expected: "${expected}"`, labelPosition);
        
        await locator.page().waitForTimeout(200);
        
        const screenshot = await locator.screenshot();
        await test.info().attach(`${screenshotName} - ✗ FAIL`, {
          body: screenshot,
          contentType: 'image/png',
        });
        
        await removeAnnotations(locator.page());
        await removeHighlight(locator);
        
        throw error;
      }
    },
  };
}
```

---

## Test Pattern with Auto-Incrementing Counter

**File: `__tests__/e2e/landing.spec.ts`**

```typescript
import { test } from '@playwright/test';
import { LandingPage } from './pages/landing-page';
import { setupMocks } from '../utils/test-helpers';
import { expectWithHighlight } from '../utils/visual-helpers';

// Test case configuration
const JIRA = 'PFUN126';
const TEST_CASE_ID = '001';

// Auto-incrementing counter
let expectCount = 0;

function getScreenshotName(): string {
  expectCount++;
  return `${JIRA}-${TEST_CASE_ID}-${expectCount}`;
}

test.describe(`${JIRA}-${TEST_CASE_ID} - Banking Dashboard - Profile 506opeduat8119`, () => {

  test.beforeEach(async () => {
    expectCount = 0; // Reset counter for each test
  });

  test('should display all account types with annotations @visual', async ({ page }) => {
    // Setup
    await setupMocks(page, 'landing', '506opeduat8119');
    const landingPage = new LandingPage(page);
    await landingPage.goto();
    await landingPage.waitForAccounts();

    // Expect 1: Screenshot PFUN126-001-1
    // Pass → Green highlight with "✓ Integrated Account"
    // Fail → Red highlight with "✗ Integrated Account"
    await expectWithHighlight(
      landingPage.integratedAccount,
      getScreenshotName(),
      { label: 'Integrated Account' }
    ).toBeVisible();

    // Expect 2: Screenshot PFUN126-001-2
    await expectWithHighlight(
      landingPage.creditCardAccount,
      getScreenshotName(),
      { label: 'Credit Card' }
    ).toBeVisible();

    // Expect 3: Screenshot PFUN126-001-3
    await expectWithHighlight(
      landingPage.securitiesAccount,
      getScreenshotName(),
      { label: 'Securities Account' }
    ).toBeVisible();

    // Expect 4: Screenshot PFUN126-001-4
    await expectWithHighlight(
      landingPage.fxAccount,
      getScreenshotName(),
      { label: 'FX Trading' }
    ).toBeVisible();
  });

});
```

---

## Playwright Report Output

### When All Tests Pass

```
Test: PFUN126-001 - should display all account types with annotations @visual
✓ Passed (3.2s)

Attachments:
├── 📷 PFUN126-001-1 - ✓ PASS
│   └── [Screenshot with GREEN glow and "✓ Integrated Account" label]
│
├── 📷 PFUN126-001-2 - ✓ PASS
│   └── [Screenshot with GREEN glow and "✓ Credit Card" label]
│
├── 📷 PFUN126-001-3 - ✓ PASS
│   └── [Screenshot with GREEN glow and "✓ Securities Account" label]
│
└── 📷 PFUN126-001-4 - ✓ PASS
    └── [Screenshot with GREEN glow and "✓ FX Trading" label]
```

### When Test Fails

```
Test: PFUN126-001 - should display all account types with annotations @visual
✗ Failed (2.1s)

Attachments:
├── 📷 PFUN126-001-1 - ✓ PASS
│   └── [Screenshot with GREEN glow and "✓ Integrated Account"]
│
├── 📷 PFUN126-001-2 - ✗ FAIL
│   └── [Screenshot with RED glow and "✗ Credit Card"]
│       Error: Element not visible
│
└── 📊 Trace
```

---

## Summary

✅ **Auto-numbering**: PFUN126-001-1, PFUN126-001-2, etc.  
✅ **Green on pass**: Success highlights with ✓  
✅ **Red on fail**: Error highlights with ✗  
✅ **Auto-attached**: All in Playwright report  
✅ **Jira-ready**: Direct ticket traceability  

Perfect for your banking dashboard tests! 🎯✨
