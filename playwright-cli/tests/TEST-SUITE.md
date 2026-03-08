# Playwright CLI Test Suite

This test suite validates that the improved SKILL.md provides sufficient guidance for an AI agent to successfully perform browser automation tasks.

## Prerequisites

```bash
# Verify Playwright CLI is available
npx playwright-cli --version

# Install browsers

# Verify browsers installed
npx playwright install --dry-run
```

---

## Test 1: Complex Form with Validation ✅

**Goal:** Test multi-field form with client-side validation and error handling.

**Target Site:** https://www.w3schools.com/html/tryit.asp?filename=tryhtml_form_submit

### Test Steps

```bash
# 1. Navigate to form
npx playwright-cli open "https://www.w3schools.com/html/tryit.asp?filename=tryhtml_form_submit"
sleep 3

# 2. Take initial snapshot
npx playwright-cli snapshot > test1_initial.txt
echo "✓ Initial snapshot captured"

# 3. Take screenshot of starting state
npx playwright-cli screenshot test1_start.png
echo "✓ Starting screenshot saved"

# 4. Switch to iframe (form is in iframe)
npx playwright-cli eval "await page.frame({name: 'iframeResult'}).waitForSelector('form')"
sleep 1

# 5. Get iframe snapshot
npx playwright-cli snapshot > test1_iframe.txt
echo "✓ Iframe snapshot captured"

# 6. Fill form fields (refs will come from snapshot)
# Note: You'll need to check test1_iframe.txt to get actual refs
# This is a template - replace eXX with actual refs from snapshot

# Example commands (adjust refs based on actual snapshot):
# npx playwright-cli fill e10 "John Doe"
# npx playwright-cli fill e11 "Smith"
# npx playwright-cli click e12  # Submit button
# sleep 2

# 7. Verify submission
npx playwright-cli snapshot > test1_result.txt
npx playwright-cli screenshot test1_result.png
echo "✓ Result captured"

# 8. Check console for errors
npx playwright-cli console > test1_console.txt
echo "✓ Console captured"

# Cleanup
npx playwright-cli close
```

### Success Criteria
- [ ] Initial snapshot shows iframe structure
- [ ] Can switch to iframe and get form elements
- [ ] Form fields can be filled
- [ ] Submission triggers navigation or shows result
- [ ] No JavaScript errors in console
- [ ] Screenshots show form state changes

### Expected Challenges
- Iframe handling (tests skill's iframe guidance)
- Finding correct element refs
- Waiting for form submission result

---

## Test 2: Slow-Loading Page ⏱️

**Goal:** Test timing/wait handling for pages with delayed content.

**Target Site:** https://httpbin.org/delay/3

### Test Steps

```bash
# 1. Navigate to slow endpoint
echo "Starting slow page test..."
npx playwright-cli open "https://httpbin.org/delay/3"

# 2. Immediate snapshot (should be incomplete)
npx playwright-cli snapshot > test2_immediate.txt
echo "✓ Immediate snapshot (likely incomplete)"

# 3. Wait for load
sleep 4

# 4. Post-wait snapshot (should be complete)
npx playwright-cli snapshot > test2_complete.txt
echo "✓ Complete snapshot after wait"

# 5. Take screenshot
npx playwright-cli screenshot test2_loaded.png
echo "✓ Screenshot saved"

# 6. Verify content loaded
npx playwright-cli eval "document.body.innerText" > test2_content.txt
echo "✓ Page content extracted"

# Cleanup
npx playwright-cli close
```

### Success Criteria
- [ ] Immediate snapshot shows loading state
- [ ] Post-wait snapshot shows complete content
- [ ] Content extraction shows JSON response
- [ ] No timeout errors

### Expected Challenges
- Determining appropriate wait time
- Distinguishing between loading and loaded states

---

## Test 3: Authentication Flow 🔐

**Goal:** Test multi-step workflow with session persistence.

**Target Site:** https://practicetestautomation.com/practice-test-login/

### Test Steps

```bash
# 1. Navigate to login page
npx playwright-cli open "https://practicetestautomation.com/practice-test-login/" --session=auth-test
sleep 2

# 2. Get login form
npx playwright-cli snapshot > test3_login.txt
npx playwright-cli screenshot test3_login.png
echo "✓ Login page captured"

# 3. Fill credentials (check test3_login.txt for refs)
# Valid credentials: username=student, password=Password123
# You'll need to adjust eXX refs based on actual snapshot

# Example (replace with actual refs):
# npx playwright-cli fill e5 "student"
# npx playwright-cli fill e6 "Password123"
# npx playwright-cli click e7  # Submit
# sleep 3

# 4. Verify logged in
npx playwright-cli snapshot > test3_logged_in.txt
npx playwright-cli screenshot test3_logged_in.png
echo "✓ Post-login state captured"

# 5. Check for success message
npx playwright-cli eval "document.body.innerText" > test3_page_text.txt
echo "✓ Page text extracted"

# 6. Navigate to another page (should maintain session)
npx playwright-cli open "https://practicetestautomation.com/logged-in-successfully/" --session=auth-test
sleep 2
npx playwright-cli snapshot > test3_session_check.txt
echo "✓ Session persistence checked"

# 7. Logout
npx playwright-cli snapshot > test3_logout_button.txt
# Find logout button ref and click it

# Cleanup
npx playwright-cli session-stop auth-test
```

### Success Criteria
- [ ] Login form fields identified correctly
- [ ] Credentials can be entered
- [ ] Successful login detected (URL change or success message)
- [ ] Session persists across navigation
- [ ] Logout button accessible after login

### Expected Challenges
- Detecting successful login
- Session persistence
- Finding logout button

---

## Test 4: Error Scenario Recovery 🔧

**Goal:** Test error handling and recovery guidance.

**Target Site:** https://httpstat.us/ (HTTP status code simulator)

### Test Steps

```bash
# 1. Test 404 error
npx playwright-cli open "https://httpstat.us/404"
sleep 2
npx playwright-cli snapshot > test4_404.txt
npx playwright-cli screenshot test4_404.png
echo "✓ 404 page captured"

# 2. Test 500 error
npx playwright-cli open "https://httpstat.us/500"
sleep 2
npx playwright-cli snapshot > test4_500.txt
npx playwright-cli screenshot test4_500.png
echo "✓ 500 page captured"

# 3. Test timeout (30 second delay - should timeout)
echo "Testing timeout (this will take ~30 seconds)..."
npx playwright-cli open "https://httpstat.us/200?sleep=30000" 2> test4_timeout_error.txt || echo "✓ Timeout error captured"

# 4. Test invalid URL
npx playwright-cli open "https://this-domain-definitely-does-not-exist-12345.com" 2> test4_invalid_url.txt || echo "✓ Invalid URL error captured"

# 5. Test stale element ref
npx playwright-cli open "https://example.com"
sleep 2
npx playwright-cli snapshot > test4_snapshot1.txt
# Get a ref from snapshot (e.g., e5)
# Then reload page to make ref stale
npx playwright-cli reload
sleep 2
# Try to click old ref - should fail
# npx playwright-cli click e5 2> test4_stale_ref.txt || echo "✓ Stale ref error captured"

# 6. Re-snapshot and retry with fresh ref
npx playwright-cli snapshot > test4_snapshot2.txt
# Now click with fresh ref should work

# Cleanup
npx playwright-cli close
```

### Success Criteria
- [ ] Error pages load and can be captured
- [ ] Timeout errors are captured
- [ ] Invalid URL errors are captured  
- [ ] Stale ref errors are handled
- [ ] Recovery by re-snapshotting works

### Expected Challenges
- Distinguishing error types
- Knowing when to retry vs. give up
- Understanding stale ref concept

---

## Test 5: Dynamic Content (JavaScript SPA) 🔄

**Goal:** Test handling of JavaScript-heavy single-page applications.

**Target Site:** https://jsonplaceholder.typicode.com/ (API examples page)

### Test Steps

```bash
# 1. Navigate to SPA
npx playwright-cli open "https://jsonplaceholder.typicode.com/"
sleep 3  # SPAs often need extra time

# 2. Initial snapshot
npx playwright-cli snapshot > test5_initial.txt
npx playwright-cli screenshot test5_start.png
echo "✓ Initial state captured"

# 3. Find and click navigation link
# (Check snapshot for refs - adjust as needed)
# npx playwright-cli click eXX  # Click "Resources" or similar
# sleep 2

# 4. Verify content changed
npx playwright-cli snapshot > test5_after_click.txt
npx playwright-cli screenshot test5_after_click.png
echo "✓ Post-click state captured"

# 5. Test dynamic loading with scroll
npx playwright-cli open "https://infinite-scroll-demo.com/" || npx playwright-cli open "https://getbootstrap.com/docs/5.0/getting-started/introduction/"
sleep 2

# 6. Scroll to bottom
npx playwright-cli eval "window.scrollTo(0, document.body.scrollHeight)"
sleep 2

# 7. Check if new content loaded
npx playwright-cli snapshot > test5_after_scroll.txt
npx playwright-cli screenshot --full-page test5_scrolled.png
echo "✓ Scroll test complete"

# Cleanup
npx playwright-cli close
```

### Success Criteria
- [ ] SPA loads completely
- [ ] Navigation within SPA works
- [ ] Snapshots capture state changes
- [ ] Scroll triggers content load
- [ ] No missed dynamic elements

### Expected Challenges
- Determining when SPA is "ready"
- Detecting dynamic content changes
- Handling client-side routing

---

## Test 6: File Upload 📎

**Goal:** Test file upload workflow with actual files.

**Target Site:** https://www.file.io/ (or similar file upload site)

### Preparation
```bash
# Create test file
echo "Test content for upload verification" > /home/AI/test-upload.txt
ls -lh /home/AI/test-upload.txt
echo "✓ Test file created"
```

### Test Steps

```bash
# 1. Navigate to upload site
npx playwright-cli open "https://the-internet.herokuapp.com/upload"
sleep 2

# 2. Find upload input
npx playwright-cli snapshot > test6_upload_form.txt
npx playwright-cli screenshot test6_form.png
echo "✓ Upload form captured"

# 3. Upload file (adjust ref based on snapshot)
# npx playwright-cli upload eXX /home/AI/test-upload.txt
# echo "✓ File selected"

# 4. Submit upload
# npx playwright-cli click eYY  # Submit button
# sleep 3

# 5. Verify upload success
npx playwright-cli snapshot > test6_result.txt
npx playwright-cli screenshot test6_result.png
echo "✓ Upload result captured"

# 6. Check for success message
npx playwright-cli eval "document.body.innerText" > test6_message.txt
cat test6_message.txt
echo "✓ Result message extracted"

# Cleanup
npx playwright-cli close
rm /home/AI/test-upload.txt
```

### Success Criteria
- [ ] Upload input identified in snapshot
- [ ] File selection command succeeds
- [ ] Submit button found and clicked
- [ ] Success message displayed
- [ ] File name appears in result

### Expected Challenges
- Finding file input element
- Using correct file path
- Verifying upload success

---

## Test 7: Multi-Tab Workflow 🗂️

**Goal:** Test tab management and switching.

### Test Steps

```bash
# 1. Open first tab
npx playwright-cli open "https://example.com"
sleep 2
npx playwright-cli snapshot > test7_tab1.txt
npx playwright-cli screenshot test7_tab1.png
echo "✓ Tab 1 captured"

# 2. Open new tab
npx playwright-cli tab-new "https://example.org"
sleep 2

# 3. List tabs
npx playwright-cli tab-list > test7_tabs.txt
cat test7_tabs.txt
echo "✓ Tab list captured"

# 4. Snapshot second tab
npx playwright-cli snapshot > test7_tab2.txt
npx playwright-cli screenshot test7_tab2.png
echo "✓ Tab 2 captured"

# 5. Switch back to first tab
npx playwright-cli tab-select 0
sleep 1

# 6. Verify on first tab
npx playwright-cli snapshot > test7_back_to_tab1.txt
npx playwright-cli eval "document.title" > test7_tab1_title.txt
echo "✓ Switched back to Tab 1"

# 7. Close second tab
npx playwright-cli tab-close 1

# 8. Verify single tab
npx playwright-cli tab-list > test7_final_tabs.txt
cat test7_final_tabs.txt
echo "✓ Tab closed"

# Cleanup
npx playwright-cli close
```

### Success Criteria
- [ ] Can open multiple tabs
- [ ] Tab list shows all tabs
- [ ] Can switch between tabs
- [ ] Snapshots are tab-specific
- [ ] Can close individual tabs

### Expected Challenges
- Tracking which tab is active
- Tab indexing (0-based)
- Ensuring commands go to correct tab

---

## Test 8: Console & Network Debugging 🐛

**Goal:** Test debugging capabilities.

### Test Steps

```bash
# 1. Navigate to page with console errors
npx playwright-cli open "https://the-internet.herokuapp.com/javascript_error"
sleep 2

# 2. Capture console output
npx playwright-cli console > test8_console.txt
cat test8_console.txt
echo "✓ Console errors captured"

# 3. Navigate to page with network activity
npx playwright-cli open "https://jsonplaceholder.typicode.com/posts"
sleep 3

# 4. Capture network requests
npx playwright-cli network > test8_network.txt
cat test8_network.txt
echo "✓ Network requests captured"

# 5. Take screenshot
npx playwright-cli screenshot test8_page.png

# 6. Execute custom JavaScript
npx playwright-cli eval "console.log('Custom log'); return document.title" > test8_eval.txt
cat test8_eval.txt
echo "✓ JavaScript execution tested"

# Cleanup
npx playwright-cli close
```

### Success Criteria
- [ ] Console errors are captured
- [ ] Network requests are visible
- [ ] JavaScript execution works
- [ ] Return values captured correctly

### Expected Challenges
- Interpreting console output
- Understanding network request details
- Knowing when to check console/network

---

## Automated Test Runner

Create a script to run all tests:

```bash
#!/bin/bash

echo "==================================="
echo "Playwright CLI Test Suite"
echo "==================================="
echo ""

# Create test results directory
mkdir -p test-results
cd test-results

# Test 1
echo "▶ Test 1: Complex Form"
echo "Status: MANUAL - Requires ref adjustment"
echo ""

# Test 2
echo "▶ Test 2: Slow Loading Page"
bash << 'EOF'
npx playwright-cli open "https://httpbin.org/delay/3"
npx playwright-cli snapshot > test2_immediate.txt
sleep 4
npx playwright-cli snapshot > test2_complete.txt
npx playwright-cli screenshot test2_loaded.png
npx playwright-cli close
echo "✓ Test 2 Complete"
EOF
echo ""

# Test 3
echo "▶ Test 3: Authentication Flow"
echo "Status: MANUAL - Requires login interaction"
echo ""

# Test 4
echo "▶ Test 4: Error Handling"
bash << 'EOF'
npx playwright-cli open "https://httpstat.us/404"
sleep 2
npx playwright-cli screenshot test4_404.png
npx playwright-cli close
echo "✓ Test 4 Complete"
EOF
echo ""

# Test 5
echo "▶ Test 5: Dynamic Content"
bash << 'EOF'
npx playwright-cli open "https://jsonplaceholder.typicode.com/"
sleep 3
npx playwright-cli snapshot > test5_initial.txt
npx playwright-cli screenshot test5_start.png
npx playwright-cli close
echo "✓ Test 5 Complete"
EOF
echo ""

# Test 6
echo "▶ Test 6: File Upload"
echo "Status: MANUAL - Requires file creation and ref adjustment"
echo ""

# Test 7
echo "▶ Test 7: Multi-Tab"
bash << 'EOF'
npx playwright-cli open "https://example.com"
sleep 2
npx playwright-cli tab-new "https://example.org"
sleep 2
npx playwright-cli tab-list > test7_tabs.txt
npx playwright-cli tab-select 0
npx playwright-cli close
echo "✓ Test 7 Complete"
EOF
echo ""

# Test 8
echo "▶ Test 8: Debugging"
bash << 'EOF'
npx playwright-cli open "https://jsonplaceholder.typicode.com/posts"
sleep 3
npx playwright-cli network > test8_network.txt
npx playwright-cli console > test8_console.txt
npx playwright-cli close
echo "✓ Test 8 Complete"
EOF
echo ""

echo "==================================="
echo "Test Suite Complete!"
echo "Results saved in test-results/"
echo "==================================="
```

---

## Evaluation Checklist

After running tests, verify the skill provides adequate guidance for:

### Timing & Waits
- [ ] Agent knows to wait after navigation
- [ ] Agent knows to wait after interactions
- [ ] Agent can determine appropriate wait times
- [ ] Agent can handle slow-loading content

### Error Handling
- [ ] Agent recognizes common errors
- [ ] Agent knows how to recover from errors
- [ ] Agent knows when to retry vs. give up
- [ ] Agent can debug using console/network

### Workflow Execution
- [ ] Agent can complete multi-step forms
- [ ] Agent can handle authentication flows
- [ ] Agent can work with dynamic content
- [ ] Agent can manage multiple tabs

### Element Interaction
- [ ] Agent understands snapshot output
- [ ] Agent uses correct refs from snapshots
- [ ] Agent re-snapshots when needed
- [ ] Agent handles stale refs correctly

### Advanced Features
- [ ] Agent can upload files
- [ ] Agent can use sessions for state
- [ ] Agent can debug with screenshots
- [ ] Agent can extract data with eval

---

## Success Metrics

### Pass Criteria
- **80%+ of tests** can be completed by following skill guidance
- **All critical errors** are addressed in skill documentation
- **Recovery patterns** work for common failures
- **Agent can independently debug** using skill's troubleshooting section

### Failure Indicators
- Agent gets stuck without knowing next step
- Agent doesn't know when to wait
- Agent can't recover from errors
- Agent uses stale refs repeatedly
- Agent can't interpret snapshot output

---

## Test Report Template

```markdown
# Test Run Report

**Date:** [DATE]
**Skill Version:** [VERSION]
**Tester:** [NAME]

## Summary
- Tests Run: X/8
- Tests Passed: X/8
- Tests Failed: X/8
- Pass Rate: XX%

## Individual Test Results

### Test 1: Complex Form
- Status: PASS/FAIL
- Issues: [List any issues]
- Notes: [Observations]

### Test 2: Slow Loading
- Status: PASS/FAIL
- Issues: [List any issues]
- Notes: [Observations]

[...continue for all tests...]

## Overall Assessment
- Can agent complete tasks independently? YES/NO
- Are error messages clear? YES/NO
- Is troubleshooting section helpful? YES/NO
- Are examples sufficient? YES/NO

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
...

## Skill Gaps Found
1. [Gap 1]
2. [Gap 2]
...
```

---

## Quick Validation Tests

For rapid validation, run these essential tests:

```bash
# Quick Test 1: Basic navigation
npx playwright-cli open "https://example.com" && sleep 2 && npx playwright-cli snapshot && npx playwright-cli close
echo "✓ Navigation works"

# Quick Test 2: Timing
npx playwright-cli open "https://httpbin.org/delay/2" && sleep 3 && npx playwright-cli snapshot && npx playwright-cli close
echo "✓ Timing works"

# Quick Test 3: Error handling
npx playwright-cli open "https://httpstat.us/404" 2>&1 | grep -q "404" && echo "✓ Error detection works"

# Quick Test 4: Screenshot
npx playwright-cli open "https://example.com" && sleep 2 && npx playwright-cli screenshot quick-test.png && npx playwright-cli close && ls quick-test.png
echo "✓ Screenshot works"

# Quick Test 5: Multi-tab
npx playwright-cli open "https://example.com" && npx playwright-cli tab-new "https://example.org" && npx playwright-cli tab-list && npx playwright-cli close
echo "✓ Multi-tab works"
```

All quick tests passing = skill is likely functional ✅
