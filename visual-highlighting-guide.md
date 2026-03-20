# Visual Testing with Element Highlighting

Enhance screenshot clarity by highlighting elements before capture - making test reports more beautiful and informative.

---

## Concept

```
Before (Standard):                 After (Highlighted):
┌─────────────────────┐           ┌─────────────────────┐
│  Form                │           │  Form                │
│  [Input]             │           │  ┏━━━━━━━━━━━┓      │ ← Red border
│  [Input]             │           │  ┃ [Input]   ┃      │   glowing effect
│  [Button]            │           │  ┗━━━━━━━━━━━┛      │   draws attention
│                      │           │  [Input]             │
└─────────────────────┘           │  [Button]            │
                                  └─────────────────────┘
```

---

## Implementation

### 1. Visual Test Helpers

**File: `__tests__/utils/visual-helpers.ts`**

```typescript
import { Page, Locator } from '@playwright/test';

/**
 * Highlight styles for different assertion types
 */
const HIGHLIGHT_STYLES = {
  success: {
    border: '3px solid #10b981',      // Green
    boxShadow: '0 0 20px rgba(16, 185, 129, 0.6)',
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
  },
  error: {
    border: '3px solid #ef4444',      // Red
    boxShadow: '0 0 20px rgba(239, 68, 68, 0.6)',
    backgroundColor: 'rgba(239, 68, 68, 0.1)',
  },
  warning: {
    border: '3px solid #f59e0b',      // Orange
    boxShadow: '0 0 20px rgba(245, 158, 11, 0.6)',
    backgroundColor: 'rgba(245, 158, 11, 0.1)',
  },
  info: {
    border: '3px solid #3b82f6',      // Blue
    boxShadow: '0 0 20px rgba(59, 130, 246, 0.6)',
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
  },
  focus: {
    border: '3px solid #8b5cf6',      // Purple
    boxShadow: '0 0 20px rgba(139, 92, 246, 0.6)',
    backgroundColor: 'rgba(139, 92, 246, 0.1)',
  },
};

/**
 * Highlight a single element before screenshot
 */
export async function highlightElement(
  locator: Locator,
  type: 'success' | 'error' | 'warning' | 'info' | 'focus' = 'focus'
): Promise<void> {
  const style = HIGHLIGHT_STYLES[type];
  
  await locator.evaluate((element, styles) => {
    // Store original styles
    element.setAttribute('data-original-border', element.style.border || '');
    element.setAttribute('data-original-box-shadow', element.style.boxShadow || '');
    element.setAttribute('data-original-bg', element.style.backgroundColor || '');
    
    // Apply highlight
    element.style.border = styles.border;
    element.style.boxShadow = styles.boxShadow;
    element.style.backgroundColor = styles.backgroundColor;
    element.style.transition = 'all 0.3s ease';
    
    // Scroll into view smoothly
    element.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }, style);
  
  // Wait for transition and scroll
  await locator.page().waitForTimeout(350);
}

/**
 * Highlight multiple elements with different colors
 */
export async function highlightElements(
  elements: Array<{
    locator: Locator;
    type?: 'success' | 'error' | 'warning' | 'info' | 'focus';
  }>
): Promise<void> {
  for (const { locator, type = 'focus' } of elements) {
    await highlightElement(locator, type);
  }
}

/**
 * Remove highlight from element
 */
export async function removeHighlight(locator: Locator): Promise<void> {
  await locator.evaluate((element) => {
    const originalBorder = element.getAttribute('data-original-border') || '';
    const originalShadow = element.getAttribute('data-original-box-shadow') || '';
    const originalBg = element.getAttribute('data-original-bg') || '';
    
    element.style.border = originalBorder;
    element.style.boxShadow = originalShadow;
    element.style.backgroundColor = originalBg;
    
    element.removeAttribute('data-original-border');
    element.removeAttribute('data-original-box-shadow');
    element.removeAttribute('data-original-bg');
  });
}

/**
 * Remove highlights from multiple elements
 */
export async function removeHighlights(locators: Locator[]): Promise<void> {
  for (const locator of locators) {
    await removeHighlight(locator);
  }
}

/**
 * Add annotation label to element
 */
export async function addAnnotation(
  locator: Locator,
  text: string,
  position: 'top' | 'bottom' | 'left' | 'right' = 'top'
): Promise<void> {
  await locator.evaluate((element, { text, position }) => {
    const annotation = document.createElement('div');
    annotation.className = 'playwright-annotation';
    annotation.textContent = text;
    annotation.style.position = 'absolute';
    annotation.style.backgroundColor = '#1f2937';
    annotation.style.color = '#ffffff';
    annotation.style.padding = '4px 8px';
    annotation.style.borderRadius = '4px';
    annotation.style.fontSize = '12px';
    annotation.style.fontWeight = 'bold';
    annotation.style.zIndex = '10000';
    annotation.style.whiteSpace = 'nowrap';
    annotation.style.boxShadow = '0 2px 8px rgba(0,0,0,0.3)';
    
    // Position the annotation
    const rect = element.getBoundingClientRect();
    switch (position) {
      case 'top':
        annotation.style.bottom = '100%';
        annotation.style.left = '50%';
        annotation.style.transform = 'translateX(-50%) translateY(-8px)';
        break;
      case 'bottom':
        annotation.style.top = '100%';
        annotation.style.left = '50%';
        annotation.style.transform = 'translateX(-50%) translateY(8px)';
        break;
      case 'left':
        annotation.style.right = '100%';
        annotation.style.top = '50%';
        annotation.style.transform = 'translateY(-50%) translateX(-8px)';
        break;
      case 'right':
        annotation.style.left = '100%';
        annotation.style.top = '50%';
        annotation.style.transform = 'translateY(-50%) translateX(8px)';
        break;
    }
    
    // Make element position relative if not already positioned
    const position = window.getComputedStyle(element).position;
    if (position === 'static') {
      element.style.position = 'relative';
    }
    
    element.appendChild(annotation);
  }, { text, position });
}

/**
 * Remove all annotations
 */
export async function removeAnnotations(page: Page): Promise<void> {
  await page.evaluate(() => {
    const annotations = document.querySelectorAll('.playwright-annotation');
    annotations.forEach(el => el.remove());
  });
}

/**
 * Take screenshot with highlighted element
 */
export async function screenshotWithHighlight(
  locator: Locator,
  filename: string,
  options: {
    type?: 'success' | 'error' | 'warning' | 'info' | 'focus';
    annotation?: string;
    annotationPosition?: 'top' | 'bottom' | 'left' | 'right';
  } = {}
): Promise<void> {
  const { type = 'focus', annotation, annotationPosition = 'top' } = options;
  
  // Highlight element
  await highlightElement(locator, type);
  
  // Add annotation if provided
  if (annotation) {
    await addAnnotation(locator, annotation, annotationPosition);
  }
  
  // Take screenshot of the component
  await locator.screenshot({ path: filename });
  
  // Cleanup
  if (annotation) {
    await removeAnnotations(locator.page());
  }
  await removeHighlight(locator);
}

/**
 * Highlight and assert with screenshot
 */
export async function highlightAndAssert(
  locator: Locator,
  screenshotName: string,
  options: {
    type?: 'success' | 'error' | 'warning' | 'info' | 'focus';
    annotation?: string;
    annotationPosition?: 'top' | 'bottom' | 'left' | 'right';
  } = {}
): Promise<void> {
  const { type = 'focus', annotation, annotationPosition = 'top' } = options;
  
  // Highlight
  await highlightElement(locator, type);
  
  // Add annotation if provided
  if (annotation) {
    await addAnnotation(locator, annotation, annotationPosition);
  }
  
  // Wait a bit for visual effect
  await locator.page().waitForTimeout(200);
  
  // Take screenshot (assertion happens in test)
  // Cleanup done after screenshot in test
}
```

---

### 2. Enhanced Page Object Pattern

**File: `__tests__/e2e/pages/landing-page.ts`**

```typescript
import { Page, Locator } from '@playwright/test';

export class LandingPage {
  readonly page: Page;

  // Component locators for screenshots
  readonly accountsContainer: Locator;
  readonly integratedAccount: Locator;
  readonly creditCardAccount: Locator;
  readonly successMessage: Locator;
  readonly errorAlert: Locator;

  constructor(page: Page) {
    this.page = page;
    
    this.accountsContainer = page.locator('.accounts-container');
    this.integratedAccount = page.locator('[data-account-type="integrated"]');
    this.creditCardAccount = page.locator('[data-account-type="credit-card"]');
    this.successMessage = page.locator('.success-message');
    this.errorAlert = page.locator('.error-alert');
  }

  async goto(): Promise<void> {
    await this.page.goto('/landing');
    await this.page.waitForLoadState('domcontentloaded');
  }

  async waitForAccounts(): Promise<void> {
    await this.accountsContainer.waitFor({ state: 'visible' });
  }
}
```

---

### 3. Visual Tests with Highlighting

**File: `__tests__/e2e/landing.spec.ts`**

```typescript
import { test, expect } from '@playwright/test';
import { LandingPage } from './pages/landing-page';
import { setupMocks } from '../utils/test-helpers';
import { 
  highlightElement, 
  highlightElements,
  removeHighlight,
  removeHighlights,
  addAnnotation,
  removeAnnotations,
} from '../utils/visual-helpers';

test.describe('Landing Page - Visual Tests', () => {

  test('should display accounts with highlights @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();
    await landingPage.waitForAccounts();

    // Highlight the account that we're asserting
    await highlightElement(landingPage.integratedAccount, 'success');
    await addAnnotation(landingPage.integratedAccount, '✓ Integrated Account', 'top');
    
    // Take screenshot with highlight
    await expect(landingPage.accountsContainer).toHaveScreenshot('accounts-highlighted.png');
    
    // Cleanup
    await removeAnnotations(page);
    await removeHighlight(landingPage.integratedAccount);
  });

  test('should highlight multiple elements @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();
    await landingPage.waitForAccounts();

    // Highlight multiple elements with different colors
    await highlightElements([
      { locator: landingPage.integratedAccount, type: 'success' },
      { locator: landingPage.creditCardAccount, type: 'info' },
    ]);
    
    // Add annotations
    await addAnnotation(landingPage.integratedAccount, '✓ Primary Account', 'top');
    await addAnnotation(landingPage.creditCardAccount, 'ℹ Credit Card', 'bottom');
    
    // Screenshot
    await expect(landingPage.accountsContainer).toHaveScreenshot('multiple-accounts-highlighted.png');
    
    // Cleanup
    await removeAnnotations(page);
    await removeHighlights([landingPage.integratedAccount, landingPage.creditCardAccount]);
  });

  test('should highlight success message @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();

    // Simulate success action
    // ... perform action that shows success message

    // Highlight success message in green
    await highlightElement(landingPage.successMessage, 'success');
    await addAnnotation(landingPage.successMessage, '✓ Operation Successful', 'top');
    
    await expect(landingPage.successMessage).toHaveScreenshot('success-message-highlighted.png');
    
    await removeAnnotations(page);
    await removeHighlight(landingPage.successMessage);
  });

  test('should highlight error alert @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();

    // Simulate error
    // ... perform action that shows error

    // Highlight error in red
    await highlightElement(landingPage.errorAlert, 'error');
    await addAnnotation(landingPage.errorAlert, '✗ Error Occurred', 'top');
    
    await expect(landingPage.errorAlert).toHaveScreenshot('error-alert-highlighted.png');
    
    await removeAnnotations(page);
    await removeHighlight(landingPage.errorAlert);
  });

});
```

---

### 4. Simplified Helper Pattern

For cleaner test code, create convenience functions:

**File: `__tests__/utils/visual-helpers.ts` (addition)**

```typescript
/**
 * All-in-one: highlight, annotate, screenshot, cleanup
 */
export async function captureWithHighlight(
  locator: Locator,
  screenshotName: string,
  options: {
    type?: 'success' | 'error' | 'warning' | 'info' | 'focus';
    label?: string;
    labelPosition?: 'top' | 'bottom' | 'left' | 'right';
  } = {}
): Promise<void> {
  const { type = 'focus', label, labelPosition = 'top' } = options;
  
  // Highlight
  await highlightElement(locator, type);
  
  // Add label if provided
  if (label) {
    await addAnnotation(locator, label, labelPosition);
  }
  
  // Wait for visual effect
  await locator.page().waitForTimeout(200);
  
  // Screenshot
  await locator.screenshot({ path: `screenshots/${screenshotName}` });
  
  // Cleanup
  if (label) {
    await removeAnnotations(locator.page());
  }
  await removeHighlight(locator);
}

/**
 * Highlight multiple and capture parent
 */
export async function captureMultipleHighlights(
  parentLocator: Locator,
  screenshotName: string,
  highlights: Array<{
    locator: Locator;
    type?: 'success' | 'error' | 'warning' | 'info' | 'focus';
    label?: string;
    labelPosition?: 'top' | 'bottom' | 'left' | 'right';
  }>
): Promise<void> {
  // Highlight all elements
  for (const { locator, type = 'focus', label, labelPosition = 'top' } of highlights) {
    await highlightElement(locator, type);
    if (label) {
      await addAnnotation(locator, label, labelPosition);
    }
  }
  
  // Wait for visual effects
  await parentLocator.page().waitForTimeout(300);
  
  // Screenshot parent
  await parentLocator.screenshot({ path: `screenshots/${screenshotName}` });
  
  // Cleanup
  await removeAnnotations(parentLocator.page());
  for (const { locator } of highlights) {
    await removeHighlight(locator);
  }
}
```

---

### 5. Simplified Test Examples

```typescript
import { test, expect } from '@playwright/test';
import { LandingPage } from './pages/landing-page';
import { setupMocks } from '../utils/test-helpers';
import { captureWithHighlight, captureMultipleHighlights } from '../utils/visual-helpers';

test.describe('Landing Page - Simplified Visual Tests', () => {

  test('highlight single element @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();
    await landingPage.waitForAccounts();

    // One-liner: highlight + label + screenshot + cleanup
    await captureWithHighlight(
      landingPage.integratedAccount,
      'integrated-account.png',
      { 
        type: 'success', 
        label: '✓ Integrated Account',
        labelPosition: 'top'
      }
    );
  });

  test('highlight multiple elements @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();
    await landingPage.waitForAccounts();

    // Highlight multiple, screenshot parent container
    await captureMultipleHighlights(
      landingPage.accountsContainer,
      'all-accounts.png',
      [
        { 
          locator: landingPage.integratedAccount, 
          type: 'success', 
          label: '✓ Primary',
          labelPosition: 'top'
        },
        { 
          locator: landingPage.creditCardAccount, 
          type: 'info', 
          label: 'ℹ Credit Card',
          labelPosition: 'bottom'
        },
      ]
    );
  });

  test('form validation errors @visual', async ({ page }) => {
    await setupMocks(page, 'landing', '506pedaut8098');
    
    const landingPage = new LandingPage(page);
    await landingPage.goto();

    // Submit empty form to trigger errors
    // ... submit action

    // Highlight error with red border
    await captureWithHighlight(
      landingPage.errorAlert,
      'form-error.png',
      { 
        type: 'error', 
        label: '✗ Validation Error',
        labelPosition: 'top'
      }
    );
  });

});
```

---

## Advanced Features

### 1. Mouse Cursor Simulation

Add a fake cursor to show where user would click:

```typescript
export async function addCursor(
  page: Page,
  locator: Locator
): Promise<void> {
  const box = await locator.boundingBox();
  if (!box) return;

  await page.evaluate(({ x, y }) => {
    const cursor = document.createElement('div');
    cursor.id = 'playwright-cursor';
    cursor.innerHTML = `
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
        <path d="M3 3L10.07 19.97L12.58 12.58L19.97 10.07L3 3Z" 
              fill="#1f2937" stroke="#ffffff" stroke-width="2"/>
      </svg>
    `;
    cursor.style.position = 'fixed';
    cursor.style.left = `${x}px`;
    cursor.style.top = `${y}px`;
    cursor.style.zIndex = '10001';
    cursor.style.pointerEvents = 'none';
    document.body.appendChild(cursor);
  }, { x: box.x + box.width / 2, y: box.y + box.height / 2 });
}

export async function removeCursor(page: Page): Promise<void> {
  await page.evaluate(() => {
    document.getElementById('playwright-cursor')?.remove();
  });
}
```

**Usage:**
```typescript
await addCursor(page, landingPage.submitButton);
await captureWithHighlight(
  landingPage.submitButton,
  'button-with-cursor.png',
  { type: 'focus', label: 'Click Here' }
);
await removeCursor(page);
```

### 2. Arrow Annotations

Point to specific elements with arrows:

```typescript
export async function addArrow(
  page: Page,
  from: { x: number; y: number },
  to: { x: number; y: number },
  label?: string
): Promise<void> {
  await page.evaluate(({ from, to, label }) => {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.style.position = 'fixed';
    svg.style.top = '0';
    svg.style.left = '0';
    svg.style.width = '100%';
    svg.style.height = '100%';
    svg.style.pointerEvents = 'none';
    svg.style.zIndex = '10000';
    svg.classList.add('playwright-arrow');

    // Arrow line
    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    line.setAttribute('x1', from.x.toString());
    line.setAttribute('y1', from.y.toString());
    line.setAttribute('x2', to.x.toString());
    line.setAttribute('y2', to.y.toString());
    line.setAttribute('stroke', '#ef4444');
    line.setAttribute('stroke-width', '3');
    line.setAttribute('marker-end', 'url(#arrowhead)');

    // Arrowhead marker
    const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
    const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
    marker.setAttribute('id', 'arrowhead');
    marker.setAttribute('markerWidth', '10');
    marker.setAttribute('markerHeight', '10');
    marker.setAttribute('refX', '5');
    marker.setAttribute('refY', '5');
    marker.setAttribute('orient', 'auto');
    
    const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
    polygon.setAttribute('points', '0 0, 10 5, 0 10');
    polygon.setAttribute('fill', '#ef4444');
    
    marker.appendChild(polygon);
    defs.appendChild(marker);
    svg.appendChild(defs);
    svg.appendChild(line);

    // Label
    if (label) {
      const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      text.setAttribute('x', from.x.toString());
      text.setAttribute('y', (from.y - 10).toString());
      text.setAttribute('fill', '#1f2937');
      text.setAttribute('font-size', '14');
      text.setAttribute('font-weight', 'bold');
      text.textContent = label;
      svg.appendChild(text);
    }

    document.body.appendChild(svg);
  }, { from, to, label });
}

export async function removeArrows(page: Page): Promise<void> {
  await page.evaluate(() => {
    document.querySelectorAll('.playwright-arrow').forEach(el => el.remove());
  });
}
```

---

## Visual Report Examples

### Example 1: Success Flow
```typescript
test('complete checkout flow @visual', async ({ page }) => {
  const checkoutPage = new CheckoutPage(page);
  await checkoutPage.goto();

  // Step 1: Fill form (success highlight)
  await captureWithHighlight(
    checkoutPage.shippingForm,
    '01-shipping-form.png',
    { type: 'success', label: '✓ Step 1: Shipping Info' }
  );

  // Step 2: Payment (info highlight)
  await captureWithHighlight(
    checkoutPage.paymentForm,
    '02-payment-form.png',
    { type: 'info', label: 'Step 2: Payment' }
  );

  // Step 3: Review (focus highlight)
  await captureWithHighlight(
    checkoutPage.reviewSection,
    '03-review.png',
    { type: 'focus', label: 'Step 3: Review Order' }
  );
});
```

### Example 2: Error Highlighting
```typescript
test('form validation @visual', async ({ page }) => {
  const formPage = new FormPage(page);
  await formPage.goto();
  await formPage.submitEmpty();

  // Highlight all errors in red
  await captureMultipleHighlights(
    formPage.formContainer,
    'validation-errors.png',
    [
      { locator: formPage.emailError, type: 'error', label: '✗ Required' },
      { locator: formPage.passwordError, type: 'error', label: '✗ Too Short' },
      { locator: formPage.phoneError, type: 'error', label: '✗ Invalid Format' },
    ]
  );
});
```

---

## Summary

### What You Get

✅ **Beautiful screenshots** with highlighted elements  
✅ **Color-coded highlights** (success=green, error=red, etc.)  
✅ **Text annotations** pointing out what's being tested  
✅ **Multiple highlight support** for complex scenarios  
✅ **Auto cleanup** after screenshots  
✅ **Optional cursor** and arrow indicators  

### Highlight Colors

| Type | Color | Use Case |
|------|-------|----------|
| `success` | 🟢 Green | Successful operations, validated fields |
| `error` | 🔴 Red | Errors, validation failures |
| `warning` | 🟠 Orange | Warnings, cautions |
| `info` | 🔵 Blue | Informational, secondary elements |
| `focus` | 🟣 Purple | Primary focus, main assertion |

### Quick Usage

```typescript
// Simple
await captureWithHighlight(element, 'screenshot.png', {
  type: 'success',
  label: '✓ This element'
});

// Multiple
await captureMultipleHighlights(container, 'screenshot.png', [
  { locator: el1, type: 'success', label: 'Good' },
  { locator: el2, type: 'error', label: 'Bad' },
]);
```

This makes your test reports visually stunning and immediately clear! 🎨✨
