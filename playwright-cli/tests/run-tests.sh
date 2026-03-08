#!/bin/bash

# Playwright CLI Test Runner
# Automated test suite for validating the Playwright CLI skill

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create results directory
RESULTS_DIR="test-results-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"
cd "$RESULTS_DIR"

echo -e "${BLUE}==================================="
echo "Playwright CLI Test Suite"
echo "===================================${NC}"
echo ""
echo "Results will be saved in: $RESULTS_DIR"
echo ""

# Check if Playwright CLI is installed
if ! command -v npx playwright-cli &> /dev/null; then
    echo -e "${RED}ERROR: npx playwright-cli not found${NC}"
    echo "Please install it first:"
    echo "  npm install -g @playwright/cli@latest"
    exit 1
fi

echo -e "${GREEN}✓ Playwright CLI found${NC}"
echo ""

# Test counters
PASSED=0
FAILED=0
TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_commands="$2"
    
    TOTAL=$((TOTAL + 1))
    echo -e "${BLUE}▶ Test $TOTAL: $test_name${NC}"
    
    if eval "$test_commands" > "${test_name// /-}.log" 2>&1; then
        echo -e "${GREEN}  ✓ PASSED${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}  ✗ FAILED${NC}"
        echo "  See ${test_name// /-}.log for details"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Quick Tests Mode
if [[ "$1" == "--quick" ]]; then
    echo "Running Quick Validation Tests..."
    echo ""
    
    run_test "Quick Navigation" "
        npx playwright-cli open https://example.com &&
        sleep 2 &&
        npx playwright-cli snapshot &&
        npx playwright-cli close
    "
    
    run_test "Quick Timing" "
        npx playwright-cli open https://httpbin.org/delay/2 &&
        sleep 3 &&
        npx playwright-cli snapshot &&
        npx playwright-cli close
    "
    
    run_test "Quick Screenshot" "
        npx playwright-cli open https://example.com &&
        sleep 2 &&
        npx playwright-cli screenshot quick-test.png &&
        npx playwright-cli close &&
        test -f quick-test.png
    "
    
    run_test "Quick Multi-Tab" "
        npx playwright-cli open https://example.com &&
        npx playwright-cli tab-new https://example.org &&
        npx playwright-cli tab-list &&
        npx playwright-cli close
    "
    
    echo ""
    echo -e "${BLUE}==================================="
    echo "Quick Test Results"
    echo -e "===================================${NC}"
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    echo -e "Failed: ${RED}$FAILED${NC}"
    echo "Total:  $TOTAL"
    
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All quick tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        exit 1
    fi
fi

# Full Test Suite
echo "Running Full Test Suite..."
echo ""

# Test 1: Basic Navigation
run_test "Basic Navigation" "
    npx playwright-cli open https://example.com &&
    sleep 2 &&
    npx playwright-cli snapshot > test1-snapshot.txt &&
    npx playwright-cli screenshot test1-screenshot.png &&
    npx playwright-cli close &&
    test -f test1-screenshot.png
"

# Test 2: Slow Loading Page
run_test "Slow Loading Page" "
    npx playwright-cli open https://httpbin.org/delay/3 &&
    npx playwright-cli snapshot > test2-immediate.txt &&
    sleep 4 &&
    npx playwright-cli snapshot > test2-complete.txt &&
    npx playwright-cli screenshot test2-loaded.png &&
    npx playwright-cli close &&
    test -f test2-loaded.png
"

# Test 3: Error Handling (404)
run_test "Error Handling 404" "
    npx playwright-cli open https://httpstat.us/404 &&
    sleep 2 &&
    npx playwright-cli snapshot > test3-404.txt &&
    npx playwright-cli screenshot test3-404.png &&
    npx playwright-cli close &&
    test -f test3-404.png
"

# Test 4: Error Handling (500)
run_test "Error Handling 500" "
    npx playwright-cli open https://httpstat.us/500 &&
    sleep 2 &&
    npx playwright-cli snapshot > test4-500.txt &&
    npx playwright-cli screenshot test4-500.png &&
    npx playwright-cli close &&
    test -f test4-500.png
"

# Test 5: Multi-Tab Management
run_test "Multi-Tab Management" "
    npx playwright-cli open https://example.com &&
    sleep 2 &&
    npx playwright-cli tab-new https://example.org &&
    sleep 2 &&
    npx playwright-cli tab-list > test5-tabs.txt &&
    npx playwright-cli tab-select 0 &&
    npx playwright-cli snapshot > test5-tab0.txt &&
    npx playwright-cli tab-select 1 &&
    npx playwright-cli snapshot > test5-tab1.txt &&
    npx playwright-cli close &&
    test -f test5-tabs.txt
"

# Test 6: Console Debugging
run_test "Console Debugging" "
    npx playwright-cli open https://example.com &&
    sleep 2 &&
    npx playwright-cli console > test6-console.txt &&
    npx playwright-cli close &&
    test -f test6-console.txt
"

# Test 7: Network Monitoring
run_test "Network Monitoring" "
    npx playwright-cli open https://jsonplaceholder.typicode.com/posts &&
    sleep 3 &&
    npx playwright-cli network > test7-network.txt &&
    npx playwright-cli close &&
    test -f test7-network.txt
"

# Test 8: Full Page Screenshot
run_test "Full Page Screenshot" "
    npx playwright-cli open https://example.com &&
    sleep 2 &&
    npx playwright-cli screenshot --full-page test8-fullpage.png &&
    npx playwright-cli close &&
    test -f test8-fullpage.png
"

# Test 9: JavaScript Evaluation
run_test "JavaScript Evaluation" "
    npx playwright-cli open https://example.com &&
    sleep 2 &&
    npx playwright-cli eval 'document.title' > test9-title.txt &&
    npx playwright-cli eval 'document.body.innerText' > test9-text.txt &&
    npx playwright-cli close &&
    test -f test9-title.txt &&
    test -f test9-text.txt
"

# Test 10: Session Persistence
run_test "Session Persistence" "
    npx playwright-cli open https://example.com --session=test-session &&
    sleep 2 &&
    npx playwright-cli snapshot > test10-session1.txt &&
    npx playwright-cli open https://example.org --session=test-session &&
    sleep 2 &&
    npx playwright-cli snapshot > test10-session2.txt &&
    npx playwright-cli session-list > test10-sessions.txt &&
    npx playwright-cli session-stop test-session &&
    test -f test10-sessions.txt
"

echo ""
echo -e "${BLUE}==================================="
echo "Test Suite Complete"
echo -e "===================================${NC}"
echo ""
echo -e "Passed: ${GREEN}$PASSED/$TOTAL${NC}"
echo -e "Failed: ${RED}$FAILED/$TOTAL${NC}"
echo ""

# Calculate pass rate
PASS_RATE=$((PASSED * 100 / TOTAL))
echo "Pass Rate: $PASS_RATE%"
echo ""

if [ $PASS_RATE -ge 80 ]; then
    echo -e "${GREEN}✓ SUCCESS: Skill meets quality criteria (≥80% pass rate)${NC}"
    echo ""
    echo "The Playwright CLI skill provides sufficient guidance for browser automation."
    exit 0
elif [ $PASS_RATE -ge 50 ]; then
    echo -e "${YELLOW}⚠ WARNING: Skill needs improvement (50-79% pass rate)${NC}"
    echo ""
    echo "Review failed tests and enhance SKILL.md documentation."
    exit 1
else
    echo -e "${RED}✗ FAILURE: Skill requires significant improvement (<50% pass rate)${NC}"
    echo ""
    echo "Critical gaps in documentation. Major revisions needed."
    exit 1
fi
