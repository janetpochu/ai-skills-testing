# Instructions for Claude: Testing the Playwright CLI Skill

This document explains how Claude (an AI assistant) should use the test suite to validate and improve the Playwright CLI skill.

## When to Use This Test Suite

Use this test suite when:
- A user asks you to "test the playwright skill"
- A user asks you to "validate the skill documentation"
- A user asks you to "check if the skill works"
- A user reports the skill isn't working correctly
- You need to verify changes to SKILL.md

## How to Run the Tests

### Quick Validation (Recommended First)
```bash
cd /path/to/playwright-cli-skill/tests
bash run-tests.sh --quick
```

This runs 4 essential tests in ~30 seconds to verify basic functionality.

### Full Test Suite
```bash
cd /path/to/playwright-cli-skill/tests
bash run-tests.sh
```

This runs all 10 tests in ~2-3 minutes for comprehensive validation.

### Interpreting Results

**Success Criteria:**
- ≥80% pass rate = Skill is working well ✓
- 50-79% pass rate = Needs improvement ⚠
- <50% pass rate = Significant issues ✗

**When Tests Fail:**
1. Read the error logs in the test-results directory
2. Identify which part of SKILL.md lacks guidance
3. Update SKILL.md with clearer instructions
4. Re-run tests to validate improvements

## Test Coverage

The test suite validates these critical areas:

1. **Basic Navigation** - Can open pages and take snapshots
2. **Timing** - Handles slow-loading content correctly
3. **Error Handling** - Deals with 404s, 500s, timeouts
4. **Multi-Tab** - Manages multiple browser tabs
5. **Debugging** - Uses console and network tools
6. **Screenshots** - Captures both viewport and full-page
7. **JavaScript** - Executes and evaluates JS in page
8. **Sessions** - Maintains state across interactions

## Manual Testing (For Complex Scenarios)

Some tests require manual verification:

### Test: Complex Form
```bash
# Follow TEST-SUITE.md Test 1
# This tests iframe handling and form validation
```

### Test: Authentication Flow
```bash
# Follow TEST-SUITE.md Test 3
# This tests login and session persistence
```

### Test: File Upload
```bash
# Follow TEST-SUITE.md Test 6
# This tests file upload workflow
```

## Workflow for Skill Improvement

1. **Run Tests**
   ```bash
   bash run-tests.sh
   ```

2. **Analyze Failures**
   ```bash
   # Check logs
   cd test-results-YYYYMMDD-HHMMSS/
   cat Test-Name.log
   ```

3. **Identify Gap**
   - Missing timing guidance?
   - Unclear error handling?
   - Incomplete workflow example?

4. **Update SKILL.md**
   - Add missing instructions
   - Clarify confusing sections
   - Provide more examples

5. **Re-test**
   ```bash
   bash run-tests.sh
   ```

6. **Repeat** until ≥80% pass rate

## Example: Fixing a Failed Test

**Scenario:** Test "Slow Loading Page" fails

**Diagnosis:**
```bash
cat test-results-*/Slow-Loading-Page.log
# Error: snapshot incomplete, missing content
```

**Root Cause:** SKILL.md doesn't specify long enough wait time for delayed content

**Fix:** Update SKILL.md
```markdown
## Timing & Waits

### For Delayed Content
# Add this example:
playwright-cli open https://httpbin.org/delay/3
sleep 4  # Wait for 3 second delay + 1 second buffer
playwright-cli snapshot
```

**Verify:**
```bash
bash run-tests.sh  # Re-run all tests
# Or
bash run-tests.sh --quick  # Just run quick validation
```

## Reporting Results

After running tests, provide a summary:

```markdown
## Test Results

**Date:** [DATE]
**Pass Rate:** XX%
**Status:** PASS/NEEDS IMPROVEMENT/FAIL

### Passed Tests (X/10):
- Basic Navigation ✓
- Timing ✓
- ...

### Failed Tests (X/10):
- Error Handling ✗ (reason: unclear recovery steps)
- ...

### Recommendations:
1. Add more error handling examples to SKILL.md
2. Clarify timing guidance for SPAs
3. ...
```

## Quick Reference: Test Commands

```bash
# Quick validation
bash run-tests.sh --quick

# Full suite
bash run-tests.sh

# Check results
cd test-results-*/
ls *.log
cat Test-Name.log

# Clean up old results
rm -rf test-results-*/
```

## Best Practices for Claude

1. **Always run quick tests first** - Saves time
2. **Read the logs** - Don't just report pass/fail numbers
3. **Identify patterns** - If multiple tests fail similarly, it's likely one issue
4. **Update incrementally** - Fix one issue, test, then move to next
5. **Document changes** - Note what you changed in SKILL.md and why
6. **Verify manually** - Some complex scenarios need human verification

## Expected Outcomes

**Ideal Result:**
```
Test Suite Complete
===================================
Passed: 10/10
Failed: 0/10
Pass Rate: 100%

✓ SUCCESS: Skill meets quality criteria (≥80% pass rate)
```

**Acceptable Result:**
```
Passed: 8/10
Failed: 2/10
Pass Rate: 80%

✓ SUCCESS: Skill meets quality criteria (≥80% pass rate)
```

**Needs Work:**
```
Passed: 6/10
Failed: 4/10
Pass Rate: 60%

⚠ WARNING: Skill needs improvement (50-79% pass rate)
```

## Integration with Skill Development

This test suite is designed to work with the skill-creator skill for:
- Automated validation during skill development
- Regression testing after changes
- Quality assurance before deployment
- Continuous improvement feedback loop

## Next Steps After Testing

1. **All tests pass?** → Skill is ready for use
2. **Some tests fail?** → Follow improvement workflow above
3. **Most tests fail?** → Review SKILL.md structure and examples
4. **Tests error out?** → Check Playwright CLI installation

## Questions to Ask When Tests Fail

1. Does SKILL.md cover this scenario?
2. Is the guidance clear enough?
3. Are the examples realistic?
4. Is error handling explained?
5. Are timing recommendations specific?
6. Are troubleshooting steps helpful?

## Remember

The goal is not just to pass tests, but to ensure the SKILL.md provides such clear guidance that an AI agent (like Claude) can successfully complete browser automation tasks independently, without human intervention.

Good luck testing! 🧪
