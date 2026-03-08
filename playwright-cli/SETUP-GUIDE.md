# Setup Guide: Playwright CLI Skill with Testing

This guide shows you how to set up the Playwright CLI skill so that AI can both use it AND test it.

## 📦 Package Contents

```
playwright-cli-skill/
├── SKILL.md                    # Main skill (what AI reads to use Playwright)
├── README.md                   # Package overview
└── tests/
    ├── TEST-SUITE.md           # Comprehensive test scenarios
    ├── QUICK-START.md          # Getting started guide
    ├── TESTING-GUIDE.md        # How AI should run tests
    └── run-tests.sh            # Automated test runner
```

## 🎯 Two Ways to Use This Package

### Option 1: As a User Skill (for AI to use Playwright)
Upload `SKILL.md` as a custom skill so AI knows how to do browser automation.

### Option 2: As a Test Suite (for validating the skill)
Use the `tests/` directory to verify the skill documentation is complete.

---

## 📤 Option 1: Installing as a User Skill

### Step 1: Locate Your Skill File
You have `SKILL.md` in the package.

### Step 2: Upload to AI
When you want AI to use Playwright for browser automation:

1. In your conversation with AI, upload the `SKILL.md` file
2. Ask AI: "Please use this skill to help me with browser automation"
3. AI will read it and follow the patterns

**OR** if you're using the skills system:

1. Save `SKILL.md` to your user skills directory
2. AI will automatically detect and use it when relevant

### Example Usage
```
You: "Please navigate to example.com and take a screenshot"

AI: [Reads SKILL.md] → Knows to:
1. playwright-cli open https://example.com
2. sleep 2
3. playwright-cli snapshot
4. playwright-cli screenshot example.png
5. playwright-cli close
```

---

## 🧪 Option 2: Setting Up Testing (Validating the Skill)

### Prerequisites
```bash
# Install Node.js (if not installed)
node --version  # Should be 16+

# Install Playwright CLI
npm install -g @playwright/cli@latest

# Reuse the existing project browser set in project config

```

### Step 1: Extract the Package
```bash

# Navigate to it
cd playwright-cli-skill/
```

### Step 2: Run Quick Validation
```bash
cd tests/
bash run-tests.sh --quick
```

**Expected Output:**
```
===================================
Playwright CLI Test Suite
===================================

✓ Playwright CLI found

▶ Test 1: Quick Navigation
  ✓ PASSED
▶ Test 2: Quick Timing
  ✓ PASSED
▶ Test 3: Quick Screenshot
  ✓ PASSED
▶ Test 4: Quick Multi-Tab
  ✓ PASSED

===================================
Quick Test Results
===================================
Passed: 4
Failed: 0
Total:  4

✓ All quick tests passed!
```

### Step 3: Run Full Test Suite (Optional)
```bash
bash run-tests.sh
```

This runs 10 comprehensive tests and generates a detailed report.

---

## 🤖 How to Make AI Test the Skill

### Method 1: Upload and Ask
1. Upload the entire `playwright-cli-skill/` directory to AI
2. Ask: "Please run the test suite to validate the Playwright skill"

AI will:
1. Read `tests/TESTING-GUIDE.md`
2. Run `bash run-tests.sh --quick`
3. Analyze results
4. Report findings

### Method 2: Direct Instructions
```
You: I've uploaded the playwright-cli-skill directory. 
     Please validate the skill by:
     1. Running the quick tests
     2. Analyzing any failures
     3. Suggesting improvements to SKILL.md if needed

AI: [Reads TESTING-GUIDE.md and follows the workflow]
```

### Example Test Session
```
You: Test the playwright skill

AI: I'll run the test suite to validate the skill documentation.

[Runs: cd tests && bash run-tests.sh --quick]

Results:
✓ Passed: 4/4 tests
✓ Pass Rate: 100%
✓ All essential functionality works

The Playwright CLI skill documentation is complete and provides 
sufficient guidance for browser automation tasks.
```

---

## 📁 File Descriptions

### SKILL.md (19KB)
The main skill documentation. Contains:
- Installation instructions
- Command reference
- Timing & wait guidance
- Error handling patterns
- Complete workflow examples
- Troubleshooting guide
- Best practices

**This is what AI reads to learn how to use Playwright.**

### tests/TEST-SUITE.md (18KB)
Comprehensive test scenarios:
- 8 detailed test cases
- Manual testing instructions
- Success criteria
- Evaluation checklist
- Test report template

**This defines WHAT to test.**

### tests/TESTING-GUIDE.md (6KB)
Instructions for AI on:
- How to run tests
- How to interpret results
- How to fix failing tests
- When to update SKILL.md

**This tells AI HOW to test.**

### tests/run-tests.sh (7KB)
Automated test runner:
- Quick mode (4 tests, 30 seconds)
- Full mode (10 tests, 2-3 minutes)
- Colored output
- Pass/fail reporting
- Result archiving

**This RUNS the tests.**

### tests/QUICK-START.md (10KB)
Getting started guide:
- Installation steps
- First test walkthrough
- Common use cases
- Troubleshooting

**This helps users get started.**

---

## 🔄 Typical Workflow

### For End Users (Using Playwright)
```
1. Upload SKILL.md to AI
2. Ask AI to do browser automation
3. AI follows SKILL.md guidance
4. Success! ✓
```

### For Skill Developers (Testing/Improving)
```
1. Make changes to SKILL.md
2. Run tests: bash run-tests.sh
3. Check pass rate
4. If <80%: fix issues in SKILL.md
5. Re-run tests
6. Repeat until ≥80% pass rate
```

### For AI (Autonomous Testing)
```
1. Read tests/TESTING-GUIDE.md
2. Run: bash run-tests.sh --quick
3. Analyze results
4. If failures: read logs
5. Suggest improvements to SKILL.md
6. Human approves changes
7. Re-test to validate
```

---

## 📊 Success Metrics

### Skill Quality Indicators
- ✅ **100% pass rate** - Excellent, production-ready
- ✅ **≥80% pass rate** - Good, ready for use
- ⚠️ **50-79% pass rate** - Needs improvement
- ❌ **<50% pass rate** - Significant issues

### What Each Test Validates
1. **Basic Navigation** - Can AI open pages?
2. **Timing** - Does AI wait appropriately?
3. **Error Handling** - Can AI handle failures?
4. **Multi-Tab** - Can AI manage complexity?
5. **Debugging** - Can AI troubleshoot?
6. **Screenshots** - Can AI capture evidence?
7. **JavaScript** - Can AI interact with page?
8. **Sessions** - Can AI maintain state?

---

## 🐛 Troubleshooting

### "playwright-cli: command not found"
```bash
npm install -g @playwright/cli@latest

```

### "Tests fail with timeouts"
Edit `run-tests.sh` and increase sleep times:
```bash
# Change: sleep 2
# To:     sleep 3
```

### "Can't find test files"
Make sure you're in the right directory:
```bash
cd playwright-cli-skill/tests/
pwd  # Should end in /tests
```

### "Permission denied: run-tests.sh"
```bash
chmod +x run-tests.sh
```

---

## 💡 Tips for Best Results

### For Using the Skill
1. Always upload the latest `SKILL.md`
2. Be specific in your requests
3. Let AI follow the patterns
4. Trust the timing guidance

### For Testing the Skill
1. Start with quick tests
2. Run full suite before major changes
3. Read the logs when tests fail
4. Update SKILL.md based on failures
5. Re-test after changes

### For Improving the Skill
1. Run tests to identify gaps
2. Add missing guidance to SKILL.md
3. Create new tests for new scenarios
4. Validate improvements with tests
5. Document changes in README.md

---

## 🚀 Quick Start Checklist

- [ ] Install Node.js 16+
- [ ] Install Playwright CLI: `npm install -g @playwright/cli@latest`
- [ ] Install browser: able to open browser using existing project config
- [ ] Extract package: able to use SKILL.md and tests/
- [ ] Navigate to tests: `cd playwright-cli-skill/tests/`
- [ ] Run quick tests: `bash run-tests.sh --quick`
- [ ] Verify pass rate ≥80%
- [ ] Upload SKILL.md to AI
- [ ] Test with real automation task

---

## 📝 Next Steps

1. **Install Prerequisites** (see above)
2. **Run Quick Tests** to verify everything works
3. **Upload SKILL.md to AI** for browser automation
4. **Try Example Workflows** from QUICK-START.md
5. **Run Full Test Suite** for comprehensive validation
6. **Report Issues** or suggest improvements

---

## 🤝 Contributing

To improve this skill:

1. Identify gaps in SKILL.md
2. Add examples and guidance
3. Create new test cases
4. Run tests to validate
5. Share improvements

---

## 📄 License

This skill documentation is provided for use with AI.

---

## 📞 Support

**Questions about the skill?**
- Read SKILL.md for usage guidance
- Read QUICK-START.md for getting started
- Read TEST-SUITE.md for testing details

**Questions about testing?**
- Read TESTING-GUIDE.md for AI's workflow
- Run `bash run-tests.sh --quick` for quick check
- Check logs in test-results-*/ for details

---

## ✨ Summary

You now have:
✅ A complete Playwright CLI skill (SKILL.md)
✅ Comprehensive test suite (TEST-SUITE.md)
✅ Automated test runner (run-tests.sh)
✅ Testing guide for AI (TESTING-GUIDE.md)
✅ Quick start guide (QUICK-START.md)

**Use it for:** Browser automation with AI
**Test it with:** Automated test suite
**Improve it with:** Test-driven development workflow

Happy automating! 🎉
