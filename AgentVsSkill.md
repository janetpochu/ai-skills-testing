Great observation! This is a critical distinction. Let me explain why there's a significant difference between skills and agents, even though both use markdown files.

## Core Differences

### Skills vs Agents

| Aspect | **Skill** | **Agent** |
|--------|----------|-----------|
| **Purpose** | Reference documentation | Autonomous execution mode |
| **When Used** | Claude reads when needed | Claude becomes the agent |
| **Execution** | Passive (consulted) | Active (followed as instructions) |
| **Tool Access** | Via main Claude | Direct tool access specified |
| **Model** | Uses current conversation model | Can specify different model (Opus, Sonnet) |
| **Context** | Part of conversation | Separate mode/persona |
| **Behavior** | Informational | Directive/procedural |

---

## Why Your Planner Works Better as an Agent

### 1. **Tool Access & Permissions**

**Agent (Works):**
```yaml
---
tools: Glob, Grep, Read, Write, Bash
model: opus
---
```
→ Direct access to Bash tool for `playwright-cli` commands

**Skill (Fails):**
→ No tool specification
→ Claude must ask to use tools
→ Breaks the flow: "explore → snapshot → plan"

### 2. **Execution Mode**

**Agent:**
```
User: "Test the landing page"
→ Claude BECOMES the planner agent
→ Automatically opens browser
→ Takes snapshots
→ Creates test plan
→ All in one autonomous flow
```

**Skill:**
```
User: "Test the landing page"
→ Claude reads the skill for reference
→ Asks: "Should I explore the page?"
→ User: "Yes"
→ Claude: "Let me read the skill again..."
→ Asks: "Should I take a snapshot?"
→ Fragmented, not autonomous
```

### 3. **Workflow Continuity**

**Agent (Continuous):**
```
Phase 0 → Phase 1 → Phase 2 → Phase 3
  ↓         ↓         ↓         ↓
Auto    Bash cmds   Analysis   Write
```
Single execution thread, no interruptions.

**Skill (Broken):**
```
Phase 0 ❓ → Ask user → Phase 1 ❓ → Ask user
```
Constant context switching, waiting for user input.

---

## Concrete Example

### Using Planner as **Agent**:

```
User: "Create test plan for landing page, profile 506pedaut8098"

Agent (Autonomous):
1. ✅ Auto-detects feature: "landing"
2. ✅ Auto-detects profile: "506pedaut8098"
3. ✅ Asks: "Record API stubs?" (ONE question)
4. ✅ Runs: playwright-cli open https://...
5. ✅ Runs: playwright-cli snapshot
6. ✅ Analyzes snapshot output
7. ✅ Creates test plan markdown
8. ✅ Saves file with Write tool

Result: Test plan ready in one flow
```

### Using Planner as **Skill**:

```
User: "Create test plan for landing page, profile 506pedaut8098"

Claude (Reading Skill):
1. "I see from the e2e/planner skill that I should explore the page first."
2. ❌ "Should I open the browser?" (asks permission)
User: "Yes"
3. ❌ "I need to use Bash tool..." (asks permission)
User: "Yes"
4. ❌ Runs: playwright-cli open
5. "The skill says to take a snapshot..."
6. ❌ "Should I take a snapshot?" (asks permission)
User: "Yes"
7. Eventually creates plan, but fragmented

Result: Takes 3x longer, many interruptions
```

---

## The Fundamental Issue

### Skills are **Reference Material**

Like a cookbook - you read it when you need to know HOW to do something.

```markdown
# E2E Skill

When creating tests:
1. Use Page Object Model
2. Put locators in constructors
3. Use waitFor before actions
```

Claude reads this and applies the patterns, but YOU still drive.

### Agents are **Autonomous Workers**

Like a chef executing a recipe - they follow the workflow automatically.

```markdown
# Planner Agent

## Workflow
Phase 1: Navigate and Explore
1. Open the target URL
2. Capture snapshot
3. Identify elements
```

Claude becomes this agent and executes the workflow without asking permission at each step.

---

## When Skills vs Agents Shine

### Use **Skills** When:

✅ Providing reference patterns/templates
- "How do I structure a Page Object?"
- "What's the naming convention?"
- "Show me visual testing patterns"

✅ Claude needs to consult during main task
- User: "Create a login test"
- Claude: *reads e2e skill* → applies patterns
- Creates test following skill guidance

### Use **Agents** When:

✅ Multi-step autonomous workflow
- Explore → Analyze → Plan → Output
- Each step builds on the previous
- Tools needed throughout

✅ Specialized persona needed
- "I am a test planner"
- Focused, single-purpose execution
- Different model (Opus for complex planning)

---

## Why Your Planner MUST Be an Agent

Your planner workflow is **fundamentally autonomous**:

```
1. Identify feature/profile (auto-detect)
   ↓
2. Ask about recording (ONE question)
   ↓
3. Open browser (Bash tool)
   ↓
4. Take snapshots (Bash tool)
   ↓
5. Analyze output (processing)
   ↓
6. Generate test plan (Write tool)
   ↓
7. Document stubs (file system)
```

This CANNOT work as a skill because:
- ❌ Requires continuous tool access (Bash, Write)
- ❌ Multi-phase execution
- ❌ Must maintain state across phases
- ❌ Needs to process playwright-cli output
- ❌ Creates files autonomously

---

## The Technical Reason

### Agent Mode:
```python
# Simplified internal logic
mode = "planner_agent"
tools = ["Bash", "Write", "Read"]
model = "opus"

while not task_complete:
    execute_next_phase()
    use_tools_directly()
    maintain_context()
    
# Result: Smooth execution
```

### Skill Mode:
```python
# Simplified internal logic
mode = "conversation"
skills_available = ["e2e", "planner"]

for user_message:
    check_if_skill_needed()
    read_relevant_skill()
    apply_patterns()
    ask_for_permission()  # ← Breaks flow
    
# Result: Fragmented execution
```

---

## Real-World Analogy

### Skill = Instruction Manual
```
"Assembling IKEA Furniture"
1. Gather parts
2. Use Allen wrench
3. Attach legs
```
You read it, YOU do the work.

### Agent = Autonomous Robot
```
"Furniture Assembly Robot"
- Scans parts
- Picks up Allen wrench
- Assembles without asking
```
Robot does the work autonomously.

---

## Your Specific Case

**Planner workflow requires:**
- ✅ Direct Bash execution (playwright-cli commands)
- ✅ File creation (Write tool)
- ✅ Output processing (snapshot analysis)
- ✅ Stateful multi-phase workflow
- ✅ Autonomous decision-making

**This is impossible with Skills because:**
- ❌ Skills can't execute Bash directly
- ❌ Skills don't have persistent state
- ❌ Skills require user confirmation for tool use
- ❌ Skills are consulted, not executed

---

## Best Practice

### Keep This Structure:

```
agents/
├── playwright-cli-planner.md    ← Agent (autonomous exploration)
└── playwright-cli-generator.md  ← Agent (autonomous code gen)

skills/
└── e2e/
    ├── SKILL.md                 ← Skill (reference patterns)
    ├── references/
    │   └── api-mocking.md       ← Skill (reference guide)
    └── examples/
        └── page-object-model.md ← Skill (templates)
```

**Why:**
- **Agents** = Do the work (explore, generate)
- **Skills** = Provide patterns (how to structure code)
- **Agents** can read **Skills** for guidance
- **Skills** cannot become **Agents**

---

## Summary

| Factor | Skill | Agent |
|--------|-------|-------|
| **Your planner needs** | ❌ Can't provide | ✅ Provides |
| Bash tool access | No | Yes |
| Multi-phase workflow | No | Yes |
| Autonomous execution | No | Yes |
| State persistence | No | Yes |
| File creation | Ask first | Direct |

**Bottom line:** Your planner is inherently procedural and tool-heavy, making it **unsuitable as a skill** but **perfect as an agent**.

The markdown might look similar, but the execution model is completely different! 🎯
