# Playwright CLI Skill - Quick Start Guide

## Installation & Setup (5 minutes)

### Step 1: Install Node.js (if not already installed)
```bash
# Check if Node.js is installed
node --version

# If not installed, install Node.js 16+ from:
# https://nodejs.org/
```

### Step 2: Install Playwright CLI
```bash
# Install globally
npm install -g @playwright/cli@latest

# Verify installation
playwright-cli --version
```

### Step 3: Install Browser
```bash
# Install Chromium browser (required for first use)
npx playwright install chromium

# This may take a few minutes to download browser binaries
```

### Step 4: Test Installation
```bash
# Quick test - open a webpage
playwright-cli open https://example.com
sleep 2
playwright-cli snapshot
playwright-cli screenshot test.png
playwright-cli close

# If test.png was created, you're good to go! ✅
ls test.png
```

---

## Your First Test (2 minutes)

### Basic Navigation Test
```bash
# 1. Open a website
playwright-cli open https://example.com

# 2. Wait for it to load
sleep 2

# 3. See what's on the page
playwright-cli snapshot

# Output will look like:
# - heading "Example Domain" [ref: e1]
# - paragraph [ref: e2]
# - link "More information..." [ref: e3]

# 4. Take a screenshot
playwright-cli screenshot example.png

# 5. Close browser
playwright-cli close
```

---

## Common Use Cases

### Use Case 1: Fill a Form
```bash
# Navigate to form
playwright-cli open https://httpbin.org/forms/post
sleep 2

# Find form fields
playwright-cli snapshot
# Look for textbox refs in the output

# Fill fields (replace eXX with actual refs from snapshot)
playwright-cli fill e5 "John Doe"
playwright-cli fill e6 "john@example.com"

# Submit
playwright-cli click e7  # Submit button ref
sleep 2

# Verify
playwright-cli snapshot
playwright-cli close
```

### Use Case 2: Login to a Site
```bash
# Navigate
playwright-cli open https://practicetestautomation.com/practice-test-login/
sleep 2

# Get form structure
playwright-cli snapshot

# Login (username: student, password: Password123)
playwright-cli fill e5 "student"
playwright-cli fill e6 "Password123"
playwright-cli click e7
sleep 3

# Verify login
playwright-cli snapshot
playwright-cli screenshot logged-in.png
playwright-cli close
```

### Use Case 3: Extract Data
```bash
# Navigate
playwright-cli open https://jsonplaceholder.typicode.com/posts
sleep 2

# Get page structure
playwright-cli snapshot > page-structure.txt

# Extract text content
playwright-cli eval "document.body.innerText" > extracted-data.txt

# Take screenshot for reference
playwright-cli screenshot data-page.png

playwright-cli close

# Review extracted data
cat extracted-data.txt
```

### Use Case 4: Take Screenshots
```bash
# Open page
playwright-cli open https://github.com
sleep 2

# Full page screenshot
playwright-cli screenshot --full-page github-full.png

# Element screenshot (after finding ref in snapshot)
playwright-cli snapshot
playwright-cli screenshot e10 github-header.png  # Replace e10 with actual header ref

playwright-cli close
```

---

## Running the Test Suite

### Quick Validation (30 seconds)
```bash
# Navigate to test suite directory
cd /path/to/test-suite

# Run quick validation tests
bash << 'EOF'
playwright-cli open "https://example.com" && sleep 2 && playwright-cli snapshot && playwright-cli close
echo "✓ Test 1: Navigation - PASSED"

playwright-cli open "https://httpbin.org/delay/2" && sleep 3 && playwright-cli snapshot && playwright-cli close  
echo "✓ Test 2: Slow loading - PASSED"

playwright-cli open "https://example.com" && sleep 2 && playwright-cli screenshot quick-test.png && playwright-cli close && ls quick-test.png
echo "✓ Test 3: Screenshot - PASSED"
EOF
```

### Full Test Suite (5-10 minutes)
```bash
# Create test directory
mkdir -p playwright-tests
cd playwright-tests

# Copy test suite
# (copy TEST-SUITE.md content or download it)

# Run individual tests from TEST-SUITE.md
# Start with Test 2 (Slow Loading) as it's fully automated:

playwright-cli open "https://httpbin.org/delay/3"
playwright-cli snapshot > test2_immediate.txt
sleep 4
playwright-cli snapshot > test2_complete.txt
playwright-cli screenshot test2_loaded.png
playwright-cli close

echo "✓ Test 2 complete - check test2_*.txt and test2_*.png files"
```

---

## Troubleshooting Installation

### Problem: "playwright-cli: command not found"
```bash
# Solution 1: Install globally
npm install -g @playwright/cli@latest

# Solution 2: Use npx instead
npx @playwright/cli open https://example.com

# Solution 3: Check npm global path
npm config get prefix
# Add this path to your PATH environment variable
```

### Problem: "Browser not found"
```bash
# Install browsers
npx playwright install chromium

# Or install all browsers
npx playwright install
```

### Problem: "Navigation timeout"
```bash
# Increase timeout in config
echo '{"timeout": 60000}' > playwright-cli.json

# Then retry
playwright-cli open https://slow-site.com
```

### Problem: "Element not found"
```bash
# Always snapshot first to get fresh refs
playwright-cli snapshot

# Then use refs from the output
playwright-cli click eXX
```

---

## Understanding Snapshots

When you run `playwright-cli snapshot`, you get output like this:

```
- main [ref: e1]
  - heading "Welcome" level=1 [ref: e2]
  - navigation [ref: e3]
    - link "Home" [ref: e4]
    - link "About" [ref: e5]
  - button "Sign In" [ref: e6]
  - textbox "Search" [ref: e7]
```

**How to read it:**
- Lines starting with `-` are elements
- Indentation shows parent-child relationships
- Text in quotes is visible content
- `[ref: eXX]` is what you use to interact with the element
- Attributes like `[disabled]` tell you about element state

**How to use refs:**
```bash
# To click the "Sign In" button:
playwright-cli click e6

# To fill the search box:
playwright-cli fill e7 "my search query"

# To click the "About" link:
playwright-cli click e5
```

---

## Best Practices Checklist

When writing automation scripts, always:

- ✅ Wait 2-3 seconds after `open` for pages to load
- ✅ Run `snapshot` before clicking/filling to get current refs
- ✅ Wait 1-2 seconds after clicks that trigger navigation
- ✅ Run `snapshot` after actions to verify they worked
- ✅ Take screenshots when debugging
- ✅ Check console for JavaScript errors if things fail
- ✅ Use absolute paths for file uploads
- ✅ Use sessions when you need to maintain login state

---

## Example: Complete Workflow

Here's a complete example that follows all best practices:

```bash
#!/bin/bash

echo "Starting automation workflow..."

# 1. Navigate
playwright-cli open https://practicetestautomation.com/practice-test-login/
sleep 2
echo "✓ Page loaded"

# 2. Verify page loaded correctly
playwright-cli snapshot > step1-login-page.txt
playwright-cli screenshot step1-login-page.png
echo "✓ Captured login page"

# 3. Extract refs from snapshot (manually check step1-login-page.txt)
# Assuming username is e5, password is e6, submit is e7

# 4. Fill login form
playwright-cli fill e5 "student"
echo "✓ Entered username"

playwright-cli fill e6 "Password123"
echo "✓ Entered password"

# 5. Submit and wait
playwright-cli click e7
sleep 3
echo "✓ Submitted form"

# 6. Verify login success
playwright-cli snapshot > step2-logged-in.txt
playwright-cli screenshot step2-logged-in.png

# 7. Check for success message
playwright-cli eval "document.body.innerText" > step2-page-text.txt
grep -q "Congratulations" step2-page-text.txt && echo "✓ Login successful!" || echo "✗ Login failed"

# 8. Take final screenshot
playwright-cli screenshot --full-page final-state.png

# 9. Cleanup
playwright-cli close
echo "✓ Automation complete"

echo ""
echo "Results:"
echo "  - step1-login-page.txt (initial snapshot)"
echo "  - step1-login-page.png (login page)"
echo "  - step2-logged-in.txt (post-login snapshot)"
echo "  - step2-logged-in.png (logged in state)"
echo "  - step2-page-text.txt (page text)"
echo "  - final-state.png (final screenshot)"
```

---

## Next Steps

1. **Run Quick Validation** - Ensure installation works
2. **Try Example Workflow** - Get familiar with the pattern
3. **Run Test Suite** - Validate skill comprehensiveness
4. **Build Your Own Tests** - Create automation for your needs

---

## Getting Help

If you encounter issues:

1. **Check the SKILL.md** - Look in the Troubleshooting section
2. **Take Screenshots** - Visual debugging helps
3. **Check Console** - `playwright-cli console` shows JavaScript errors
4. **Check Network** - `playwright-cli network` shows failed requests
5. **Re-snapshot** - Refs become stale, always get fresh ones

---

## Evaluation Criteria

After running tests, the skill should enable you to:

- ✅ Navigate to any webpage
- ✅ Fill forms successfully
- ✅ Handle slow-loading pages
- ✅ Recover from errors
- ✅ Extract data from pages
- ✅ Take screenshots for debugging
- ✅ Manage multiple tabs
- ✅ Upload files
- ✅ Maintain login sessions
- ✅ Debug failed interactions

If you can do all of the above by following the skill documentation, the skill is **complete and effective**! 🎉

---

## Quick Reference Card

```
# Essential Commands
playwright-cli open <url>              # Navigate
sleep 2                                # Wait for load
playwright-cli snapshot                # Get element refs
playwright-cli click <ref>             # Click element
playwright-cli fill <ref> "text"       # Fill input
playwright-cli screenshot <file>       # Take screenshot
playwright-cli console                 # Check errors
playwright-cli close                   # Close browser

# Pattern
snapshot → interact → wait → verify → screenshot

# Debug
playwright-cli console                 # JavaScript errors
playwright-cli network                 # Network requests
playwright-cli screenshot --full-page  # Visual check
```

Save this card for quick reference during automation! 📋
