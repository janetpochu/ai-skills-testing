---
name: playwright-cli
description: "Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages."
---

# Playwright CLI

A token-efficient CLI for browser automation. Use `Bash` tool to run these commands.

## Installation

```bash
# Install globally
npm install -g @playwright/cli@latest

# Verify installation
playwright-cli --version

# Install browser binaries (required on first use)
npx playwright install chromium

# If installation fails:
# - Check Node.js version: node --version (needs 16+)
# - May need: npm install -g playwright
```

## Core Workflow

```bash
# 1. Open a page and wait for load
playwright-cli open https://example.com
sleep 2  # Wait for dynamic content

# 2. Capture snapshot (accessibility tree with element refs)
playwright-cli snapshot

# 3. Interact using refs from snapshot
playwright-cli click e15
playwright-cli fill e20 "hello@example.com"

# 4. Re-snapshot to verify state changed
sleep 1
playwright-cli snapshot
```

**Key Principle:** Always snapshot before interacting - refs become stale when DOM updates.

## Command Reference

### Navigation & Core
| Command | Description |
|---------|-------------|
| `playwright-cli open <url>` | Open URL in browser (waits for 'load' event) |
| `playwright-cli open <url> --headed` | Open in visible browser (for debugging) |
| `playwright-cli close` | Close browser |
| `playwright-cli snapshot` | Capture accessibility tree with element refs |
| `playwright-cli screenshot [ref]` | Take screenshot (viewport or element) |
| `playwright-cli screenshot --full-page` | Full-page screenshot |
| `playwright-cli pdf` | Save page as PDF |

### Interactions
| Command | Description |
|---------|-------------|
| `playwright-cli click <ref>` | Click element |
| `playwright-cli fill <ref> "<text>"` | Fill input field |
| `playwright-cli type "<text>"` | Type text sequentially |
| `playwright-cli hover <ref>` | Hover over element |
| `playwright-cli select <ref> "<value>"` | Select dropdown option |
| `playwright-cli check <ref>` | Check checkbox |
| `playwright-cli uncheck <ref>` | Uncheck checkbox |
| `playwright-cli upload <ref> <file>` | Upload file (use full path) |
| `playwright-cli drag <startRef> <endRef>` | Drag and drop |

### Keyboard & Mouse
| Command | Description |
|---------|-------------|
| `playwright-cli press <key>` | Press key (e.g., `Enter`, `ArrowDown`, `Tab`) |
| `playwright-cli keydown <key>` | Key down |
| `playwright-cli keyup <key>` | Key up |
| `playwright-cli mousemove <x> <y>` | Move mouse to coordinates |
| `playwright-cli mousedown` | Mouse button down |
| `playwright-cli mouseup` | Mouse button up |

### Navigation
| Command | Description |
|---------|-------------|
| `playwright-cli go-back` | Go back in history |
| `playwright-cli go-forward` | Go forward in history |
| `playwright-cli reload` | Reload current page |

### Tabs
| Command | Description |
|---------|-------------|
| `playwright-cli tab-list` | List all open tabs |
| `playwright-cli tab-new [url]` | Open new tab |
| `playwright-cli tab-close [index]` | Close tab by index |
| `playwright-cli tab-select <index>` | Switch to tab |

### DevTools
| Command | Description |
|---------|-------------|
| `playwright-cli console` | View console messages (errors, logs) |
| `playwright-cli network` | View network requests |
| `playwright-cli eval "<js>"` | Execute JavaScript in page context |
| `playwright-cli run-code "<js>"` | Run Playwright API code |

### Dialogs
| Command | Description |
|---------|-------------|
| `playwright-cli dialog-accept` | Accept alert/confirm dialog |
| `playwright-cli dialog-dismiss` | Dismiss alert/confirm dialog |

### Tracing & Video
| Command | Description |
|---------|-------------|
| `playwright-cli tracing-start` | Start trace recording |
| `playwright-cli tracing-stop` | Stop and save trace |
| `playwright-cli video-start` | Start video recording |
| `playwright-cli video-stop` | Stop and save video |

### Sessions
| Command | Description |
|---------|-------------|
| `playwright-cli open <url> --session=<name>` | Use named session (persistent state) |
| `playwright-cli session-list` | List active sessions |
| `playwright-cli session-stop <name>` | Stop session |
| `playwright-cli session-delete <name>` | Delete session |

## Understanding Snapshots

When you run `playwright-cli snapshot`, you get an accessibility tree showing the page structure:

### Simple Example
```
- button "Create Strategy" [ref: e12]
- textbox "Search" [ref: e13]
- grid [ref: e14]
- button "Filters" [ref: e15]
```

### Real-World Example (Complex)
```
- main [ref: e1]
  - heading "Dashboard" level=1 [ref: e2]
  - navigation [ref: e3]
    - link "Home" [ref: e4]
    - link "Settings" [ref: e5]
    - link "Profile" [ref: e6]
  - region "Content Area" [ref: e7]
    - form [ref: e8]
      - textbox "Email" [required] [ref: e9]
      - textbox "Password" [required] type=password [ref: e10]
      - button "Submit" [disabled] [ref: e11]
      - button "Cancel" [ref: e12]
    - list [ref: e13]
      - listitem [ref: e14]
        - button "Edit" [ref: e15]
        - button "Delete" [ref: e16]
```

### Key Points
- **Indentation** shows DOM nesting (children are indented under parents)
- **Attributes** like `[disabled]`, `[required]`, `[checked]` affect what you can do
- **Refs are ephemeral** - they change when the DOM updates, always re-snapshot before interacting
- **Use specific refs** - target the exact element you need
- **Text content** appears in quotes (e.g., "Submit", "Email")

## Timing & Waits

Web pages load asynchronously. Always account for timing:

### After Navigation
```bash
playwright-cli open https://example.com
sleep 2  # Wait for dynamic content (JavaScript, AJAX)
playwright-cli snapshot
```

### After Interactions
```bash
playwright-cli click e10  # Submit button
sleep 2  # Wait for page transition or content update
playwright-cli snapshot  # Verify new state
```

### For Specific Elements
```bash
# Wait for element to appear using JavaScript
playwright-cli eval "await page.waitForSelector('.loading-spinner', { state: 'hidden' })"
playwright-cli snapshot
```

### General Guidelines
- **After open:** Wait 2-3 seconds for SPAs and dynamic sites
- **After click:** Wait 1-2 seconds if action triggers navigation or updates
- **After fill:** Usually no wait needed unless validation runs
- **After form submit:** Wait 2-3 seconds for response
- **For slow networks:** Increase waits to 3-5 seconds

## Error Handling

### Common Errors and Solutions

#### "Element not found" or "Reference not valid"
**Causes:**
- Element not loaded yet → Add `sleep 2` and re-snapshot
- Ref is stale (DOM changed) → Take fresh snapshot
- Element in different tab → Check `tab-list`
- Element requires scroll → Use `eval "await page.locator('selector').scrollIntoViewIfNeeded()"`

**Solution:**
```bash
playwright-cli snapshot  # Get fresh refs
playwright-cli click e15  # Use current ref
```

#### "Navigation timeout" or "Page load timeout"
**Causes:**
- Page is genuinely slow → Increase timeout in config
- URL is incorrect → Verify URL
- Network issues → Check connectivity
- Page has infinite loading → Site may be broken

**Solution:**
```bash
# Create config with longer timeout
echo '{"timeout": 60000}' > playwright-cli.json
playwright-cli open https://slow-site.com
```

#### "Element is not visible/clickable"
**Causes:**
- Element is obscured by overlay → Check snapshot for modals/popups
- Element is disabled → Look for `[disabled]` attribute in snapshot
- Element requires hover first → Hover then click
- Element is in collapsed section → Expand parent first

**Solution:**
```bash
playwright-cli snapshot  # Check for overlays
playwright-cli press Escape  # Close modal if present
playwright-cli click e10  # Retry
```

#### "Cannot upload file"
**Causes:**
- File path is wrong → Use absolute paths
- File doesn't exist → Verify with `ls`
- Wrong element type → Must be file input element

**Solution:**
```bash
# For user uploads
ls /mnt/user-data/uploads/  # Verify file exists
playwright-cli upload e5 /mnt/user-data/uploads/document.pdf

# For generated files
playwright-cli upload e5 /home/claude/report.xlsx
```

### Best Practice: Always Check State
```bash
# Before interaction
playwright-cli snapshot
# Look for success indicators, error messages, disabled states

# After interaction
sleep 1
playwright-cli snapshot
# Verify the DOM changed as expected
```

## Common Workflows

### Form Submission
```bash
# 1. Navigate and wait
playwright-cli open https://example.com/contact
sleep 2

# 2. Get current page state
playwright-cli snapshot
# Output shows: textbox "Name" [ref: e5], textbox "Email" [ref: e6], button "Submit" [ref: e7]

# 3. Fill form fields
playwright-cli fill e5 "John Doe"
playwright-cli fill e6 "john@example.com"

# 4. Submit and wait for response
playwright-cli click e7
sleep 3

# 5. Verify success
playwright-cli snapshot
# Look for success message or new page state
playwright-cli screenshot form-result.png
```

### Login Flow
```bash
# 1. Navigate
playwright-cli open https://app.example.com/login
sleep 2

# 2. Find login fields
playwright-cli snapshot
# Output: textbox "Email" [ref: e8], textbox "Password" [ref: e9], button "Login" [ref: e10]

# 3. Enter credentials
playwright-cli fill e8 "user@example.com"
playwright-cli fill e9 "SecurePassword123"

# 4. Submit
playwright-cli click e10
sleep 3

# 5. Verify logged in
playwright-cli snapshot
# Look for user menu, dashboard elements, or logout button
```

### Data Extraction
```bash
# 1. Navigate to page
playwright-cli open https://example.com/data
sleep 2

# 2. Get page structure
playwright-cli snapshot > page_structure.txt

# 3. Extract specific data with JavaScript
playwright-cli eval "document.querySelector('.price').textContent"

# 4. Or get all text content
playwright-cli eval "document.body.innerText" > extracted_data.txt

# 5. Take screenshot for reference
playwright-cli screenshot --full-page data-page.png
```

### Multi-Step Testing
```bash
# 1. Setup: Navigate and login
playwright-cli open https://app.example.com/login
sleep 2
playwright-cli snapshot
playwright-cli fill e5 "test@example.com"
playwright-cli fill e6 "password"
playwright-cli click e7
sleep 3

# 2. Verify login
playwright-cli snapshot
playwright-cli screenshot step1-logged-in.png

# 3. Navigate to feature
playwright-cli click e10  # Dashboard menu item
sleep 2

# 4. Use feature
playwright-cli snapshot
playwright-cli fill e15 "test data"
playwright-cli click e16  # Submit
sleep 2

# 5. Verify result
playwright-cli snapshot
playwright-cli console  # Check for errors
playwright-cli screenshot step2-feature-result.png

# 6. Cleanup
playwright-cli close
```

### Handling Dynamic Content
```bash
# 1. Navigate
playwright-cli open https://dynamic-site.com
sleep 2

# 2. Trigger dynamic load (e.g., infinite scroll)
playwright-cli eval "window.scrollTo(0, document.body.scrollHeight)"
sleep 2

# 3. Wait for specific element
playwright-cli eval "await page.waitForSelector('.new-content', { timeout: 5000 })"

# 4. Now snapshot will include new content
playwright-cli snapshot
```

### File Upload
```bash
# 1. Navigate to upload form
playwright-cli open https://example.com/upload
sleep 2

# 2. Find upload input
playwright-cli snapshot
# Output: textbox "Choose File" type=file [ref: e8]

# 3. Upload file (must exist in filesystem)
playwright-cli upload e8 /mnt/user-data/uploads/document.pdf

# 4. Submit form
playwright-cli click e9  # Upload button
sleep 3

# 5. Verify upload success
playwright-cli snapshot
playwright-cli screenshot upload-success.png
```

## Sessions

Use sessions to maintain browser state (cookies, localStorage, cache) across multiple interactions:

### Without Session (Fresh Browser Each Time)
```bash
playwright-cli open https://site.com
# ... do work ...
playwright-cli close
# Next time: completely fresh browser, no cookies
```

### With Session (Persistent State)
```bash
# First interaction - creates session
playwright-cli open https://site.com/login --session=myapp
playwright-cli snapshot
playwright-cli fill e5 "user@example.com"
playwright-cli fill e6 "password"
playwright-cli click e7
sleep 3

# Later - reuses same browser with cookies
playwright-cli snapshot --session=myapp  # Still logged in!
playwright-cli open https://site.com/dashboard --session=myapp

# When done
playwright-cli session-stop myapp
```

### When to Use Sessions
- **Multi-step workflows** where login state must persist
- **Testing authenticated features** without re-logging in each time
- **Shopping cart flows** where items must persist
- **Any scenario** requiring cookies or localStorage between commands

## Troubleshooting

### Element Not Visible in Snapshot

**Problem:** Expected element doesn't appear in snapshot output.

**Solutions:**
1. **Element in iframe:** 
   ```bash
   playwright-cli eval "await page.frame({url: /iframe-url/}).waitForSelector('.element')"
   ```

2. **Element requires scroll:**
   ```bash
   playwright-cli eval "await page.locator('.element').scrollIntoViewIfNeeded()"
   playwright-cli snapshot
   ```

3. **Element in different tab:**
   ```bash
   playwright-cli tab-list  # Find tab index
   playwright-cli tab-select 1  # Switch to tab
   playwright-cli snapshot
   ```

4. **Element loaded by JavaScript:**
   ```bash
   sleep 3  # Wait longer
   playwright-cli snapshot
   ```

### Click Not Working

**Problem:** Click command runs but nothing happens.

**Debugging Steps:**
```bash
# 1. Check if element is disabled
playwright-cli snapshot  # Look for [disabled] attribute

# 2. Check if element is obscured
playwright-cli screenshot  # Visual check for overlays

# 3. Try hover first (for menu items)
playwright-cli hover e10
sleep 0.5
playwright-cli click e10

# 4. Check console for JavaScript errors
playwright-cli console

# 5. Try JavaScript click as fallback
playwright-cli eval "document.querySelector('button').click()"
```

### Page Not Loading

**Problem:** Page hangs or loads indefinitely.

**Solutions:**
```bash
# 1. Check network requests
playwright-cli network  # Look for failed requests

# 2. Increase timeout
echo '{"timeout": 90000}' > playwright-cli.json

# 3. Try headless mode (more reliable)
playwright-cli open https://site.com  # Headless is default

# 4. Check URL is correct
playwright-cli eval "window.location.href"  # See actual URL
```

### Form Submission Fails

**Problem:** Form submits but doesn't work.

**Debugging:**
```bash
# 1. Check for validation errors
playwright-cli snapshot  # Look for error messages

# 2. Check required fields
playwright-cli snapshot  # Look for [required] attributes

# 3. Check console
playwright-cli console  # JavaScript validation errors

# 4. Verify field values
playwright-cli eval "document.querySelector('input[name=\"email\"]').value"

# 5. Check network
playwright-cli network  # See if POST request succeeded
```

### Debugging Commands Reference
```bash
playwright-cli console          # JavaScript errors
playwright-cli network          # Failed requests, slow responses
playwright-cli screenshot       # Visual state
playwright-cli screenshot --full-page  # Entire page
playwright-cli eval "window.location.href"  # Current URL
playwright-cli eval "document.title"  # Page title
playwright-cli tab-list         # All open tabs
```

## Best Practices

1. **Always snapshot before interacting** - Refs become stale when DOM updates
2. **Add delays after navigation** - Pages need time to load (2-3 seconds for SPAs)
3. **Re-snapshot to verify** - Confirm actions worked by checking new state
4. **Use descriptive session names** - Makes debugging easier (`--session=login-flow`)
5. **Take screenshots for debugging** - Visual confirmation when things go wrong
6. **Check console for errors** - JavaScript errors affect page behavior
7. **Use headless mode** - Faster, more reliable (default behavior)
8. **Verify file paths for uploads** - Always use absolute paths, verify with `ls`
9. **Handle timing explicitly** - Don't assume instant loads, use `sleep` appropriately
10. **Examine snapshot attributes** - `[disabled]`, `[required]`, `[checked]` tell you what's possible

## Common Patterns

### Safe Interaction Pattern
```bash
# Always: snapshot → interact → wait → verify
playwright-cli snapshot        # Get current refs
playwright-cli click e10       # Perform action
sleep 1                        # Wait for update
playwright-cli snapshot        # Verify it worked
```

### Navigation with Verification
```bash
playwright-cli open https://example.com
sleep 2                        # Wait for load
playwright-cli snapshot        # Confirm page loaded
playwright-cli screenshot      # Visual confirmation
```

### Form Filling with Validation
```bash
playwright-cli fill e5 "input@example.com"
playwright-cli snapshot        # Check for inline validation errors
# Look for error messages in snapshot before submitting
playwright-cli click e6        # Submit only if no errors
```

### Error Recovery Pattern
```bash
playwright-cli click e10
sleep 1
playwright-cli snapshot
# Check snapshot output for error messages or unexpected state
if [ error detected ]; then
    playwright-cli console     # Check JavaScript errors
    playwright-cli screenshot  # Visual debugging
    # Retry or take corrective action
fi
```

## Configuration

Create `playwright-cli.json` in your working directory for custom settings:

```json
{
  "browser": "chromium",
  "headless": true,
  "timeout": 30000,
  "viewport": {
    "width": 1280,
    "height": 720
  }
}
```

### Common Configurations

**For slow sites:**
```json
{
  "timeout": 60000,
  "navigationTimeout": 90000
}
```

**For debugging:**
```json
{
  "headless": false,
  "slowMo": 1000
}
```

**For mobile testing:**
```json
{
  "viewport": {
    "width": 375,
    "height": 667
  },
  "userAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)"
}
```

## Quick Reference

### Essential Commands
```bash
# Start
playwright-cli open <url>
sleep 2

# Interact
playwright-cli snapshot        # Always before clicking
playwright-cli click <ref>     # Use ref from snapshot
playwright-cli fill <ref> "text"

# Verify
sleep 1
playwright-cli snapshot        # Check new state
playwright-cli screenshot      # Visual proof

# Debug
playwright-cli console         # Errors
playwright-cli network         # Requests
playwright-cli screenshot --full-page

# Clean up
playwright-cli close
```

### Decision Tree

**Need to click something?**
1. `playwright-cli snapshot` → Find ref
2. `playwright-cli click <ref>`
3. `sleep 1` (if navigation expected)
4. `playwright-cli snapshot` → Verify

**Form not working?**
1. `playwright-cli snapshot` → Check for errors, disabled buttons
2. `playwright-cli console` → JavaScript errors
3. `playwright-cli network` → Failed requests

**Element not found?**
1. `sleep 2` → Wait for load
2. `playwright-cli snapshot` → Check again
3. `playwright-cli eval "await page.waitForSelector('.class')"` → Wait specifically
4. `playwright-cli screenshot` → Visual debug
