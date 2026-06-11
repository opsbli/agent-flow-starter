// ECC Bridge — brings ECC's hooks, security, and workflow commands to pi
// Converts ECC's Claude Code hooks, commands, and security rules to pi-native Mechanisms
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// ECC skill listing — plain string, no nested template literals
const ECC_HELP_TEXT = [
  "",
  "## ECC Bridge for pi",
  "",
  "### Available Commands",
  '  - /ecc-review [PR|url]  — Code review',
  '  - /ecc-plan [feature]   — Implementation plan',
  '  - /ecc-build [error]    — Fix build errors',
  '  - /ecc-tdd [feature]    — TDD workflow',
  '  - /ecc-security [path]  — Security audit',
  '  - /ecc-quality [path]   — Quality gate',
  '  - /ecc-refactor [path]  — Refactor code',
  '  - /ecc-docs [path]      — Update docs',
  '  - /ecc-route [task]     — Model routing advice',
  '',
  "### Skill Categories (use /skill:<name>)",
  '  - Testing: e2e-testing, tdd-workflow, verification-loop, eval-harness',
  '  - Security: security-review, security-scan, security-bounty-hunter',
  '  - Architecture: api-design, backend-patterns, frontend-patterns, coding-standards',
  '  - Research: deep-research, market-research, documentation-lookup',
  '  - Performance: benchmark-optimization-loop, latency-critical-systems',
  '  - Languages: rust-patterns, golang-patterns, python-patterns, react-patterns',
  '',
  '### Security Hooks Active',
  '  - Secret detection (bash commands)',
  '  - Dangerous command blocking',
  '  - Sensitive file read protection',
  '  - Console.log warnings',
  '',
].join("\n");

// Dangerous command patterns
const DANGEROUS_CMDS = [
  /rm\s+-rf\s+\/\s*$/m,
  /rm\s+-rf\s+~\/?\s*$/m,
  /mkfs/,
  /dd\s+if=.*of=\/dev/,
  />\s*\/dev\/(sd|nvme)/,
  /chmod\s+777\s+\//,
  /sudo\s+rm\s+-rf\s+--no-preserve-root/,
];

// Secret patterns
const SECRET_PATTERNS = [
  /sk-[a-zA-Z0-9]{20,}/,
  /ghp_[a-zA-Z0-9]{36,}/,
  /gho_[a-zA-Z0-9]{36,}/,
  /AKIA[0-9A-Z]{16}/,
  /-----BEGIN\s+(RSA |EC )?PRIVATE KEY-----/,
  /xox[baprs]-[a-zA-Z0-9]{10,}/,
];

// Dev server patterns
const DEV_SERVER_CMDS = [
  /npx?\s+(dev|serve|start)/i,
  /npm\s+run\s+(dev|serve|start)/i,
  /yarn\s+(dev|serve|start)/i,
  /pnpm\s+(dev|serve|start)/i,
  /bun\s+(dev|serve|start)/i,
  /python[23]?\s+-m\s+http\.server/,
  /ng\s+serve/,
  /vite(\s|$)/,
];

// Sensitive file patterns
const SENSITIVE_FILES = [
  /\.env$/,
  /\.env\.local$/,
  /\.env\.production$/,
  /\.key$/,
  /\.pem$/,
  /\.p12$/,
  /\.pfx$/,
  /credentials\.json$/,
  /id_rsa$/,
  /id_ed25519$/,
  /\.npmrc$/,
  /\.netrc$/,
];

export default function (pi: ExtensionAPI) {
  // ============================================================
  // 1. SECURITY HOOKS
  // ============================================================

  // Block dangerous bash commands and detect secrets
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;
    const cmd: string = event.input.command || "";

    // Dangerous commands
    for (const pat of DANGEROUS_CMDS) {
      if (pat.test(cmd)) {
        const ok = await ctx.ui.confirm(
          "Dangerous Command",
          "Blocked: " + cmd.substring(0, 100) + "\nAllow this?"
        );
        if (!ok) {
          return { block: true, reason: "Dangerous command blocked by ECC security" };
        }
      }
    }

    // Secrets in commands
    for (const pat of SECRET_PATTERNS) {
      if (pat.test(cmd)) {
        ctx.ui.notify("Possible secret detected in command - blocked", "warning");
        return { block: true, reason: "Secret detected in command. Use env vars or .env file instead." };
      }
    }

    // Dev server warning
    for (const pat of DEV_SERVER_CMDS) {
      if (pat.test(cmd)) {
        ctx.ui.notify("Dev server detected - consider running in tmux for background persistence", "info");
      }
    }
  });

  // Sensitive file read protection
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "read" && event.toolName !== "bash") return;
    const path: string = event.input.path || event.input.command || "";

    for (const pat of SENSITIVE_FILES) {
      if (pat.test(path)) {
        const ok = await ctx.ui.confirm(
          "Sensitive File",
          "Reading " + path + " - sensitive file detected. Allow?"
        );
        if (!ok) {
          return { block: true, reason: "Sensitive file read blocked by ECC security" };
        }
      }
    }
  });

  // Console.log warning after edit/write
  pi.on("tool_result", async (event, ctx) => {
    if (event.toolName !== "edit" && event.toolName !== "write") return;
    const content: string = typeof event.result === "string" ? event.result : JSON.stringify(event.result);
    if (content.includes("console.log") || content.includes("console.debug")) {
      ctx.ui.notify("Note: file contains console.log - consider removing before commit", "info");
    }
  });

  // ============================================================
  // 2. WORKFLOW COMMANDS
  // ============================================================

  pi.registerCommand("ecc-review", {
    description: "ECC code review - inspect staged/local changes or PR",
    argumentHint: "[pr-number | pr-url]",
    handler: async (args, ctx) => {
      const isPR = !!(args && (args.match(/^\d+$/) || args.includes("github.com") || args.includes("--pr")));
      const prompt = isPR
        ? "## Code Review Mode: PR Review\n\nPR: " + args + "\n\nReview this PR for quality, security, and maintainability. Focus on:\n1. Logic errors and bugs\n2. Security vulnerabilities (OWASP Top 10)\n3. Performance issues\n4. Error handling\n5. Code style and maintainability\n\nProvide specific file:line recommendations."
        : "## Code Review Mode: Local Review\n\nReview all uncommitted changes.\n\n1. Run: git diff --staged && git diff\n2. Read surrounding code context\n3. Check for: bugs, security issues, error handling gaps\n4. Report with SPECIFIC file:line recommendations\n\nFocus on CRITICAL issues first, then HIGH, then MEDIUM.";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-plan", {
    description: "ECC implementation plan - analyze and create step-by-step plan",
    argumentHint: "[feature description | path/*.prd.md]",
    handler: async (args, ctx) => {
      const prompt = "## Implementation Plan\n\nRequirements: " + (args || "(analyze current context)") +
        "\n\n## Process\n1. Restate requirements\n2. Identify risks and blockers\n3. Review existing codebase architecture\n4. Create step-by-step plan\n5. WAIT for user confirmation before coding\n\nOutput format:\n# Plan: [Title]\n## Requirements\n...\n## Implementation Steps\n### Phase 1: ...\n- [ ] Step";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-build", {
    description: "ECC build fix - analyze and resolve build failures",
    argumentHint: "[error text]",
    handler: async (args, ctx) => {
      const prompt = "## Build Error Resolution\n\n" + (args ? "Error: " + args : "Analyze recent build output for errors.") +
        "\n\n## Process\n1. Capture exact error message and location\n2. Read the failing code\n3. Determine root cause\n4. Apply minimal surgical fix\n5. Verify with rebuild";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-tdd", {
    description: "ECC TDD workflow - Red-Green-Refactor cycle",
    argumentHint: "[feature description]",
    handler: async (args, ctx) => {
      const prompt = "## TDD: Red-Green-Refactor\n\nFeature: " + (args || "(from current context)") +
        "\n\n### 1. RED - Write a failing test\n- Describe expected behavior\n- Test should fail initially\n- Cover: happy path, edge cases, error cases\n\n### 2. GREEN - Write minimal implementation\n- Make the test pass\n- Don't optimize yet\n\n### 3. REFACTOR - Improve code\n- Clean up, remove duplication\n- Keep tests green\n\nTarget: 80%+ coverage";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-security", {
    description: "ECC security audit - scan for vulnerabilities and secrets",
    argumentHint: "[path]",
    handler: async (args, ctx) => {
      const target = args || ".";
      const prompt = "## Security Audit\n\nTarget: " + target +
        "\n\n### CRITICAL\n- Hardcoded secrets (API keys, passwords, tokens)\n- SQL/NoSQL injection\n- Command injection\n- Authentication bypass\n\n### HIGH\n- XSS, CSRF, SSRF\n- Path traversal\n- Broken access control\n\n### MEDIUM\n- Missing input validation\n- Weak cryptography\n- Information disclosure\n\nRun: grep for secrets and dangerous patterns.";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-quality", {
    description: "ECC quality gate - run all quality checks",
    argumentHint: "[path]",
    handler: async (args, ctx) => {
      const target = args || ".";
      const prompt = "## Quality Gate\n\nTarget: " + target +
        "\n\nRun:\n1. TypeScript check: npx tsc --noEmit (if tsconfig.json exists)\n2. Lint: check for lint errors\n3. Tests: run test suite\n4. Build: verify build succeeds\n5. Security: check for hardcoded secrets\n6. Dependencies: npm audit\n\nGate PASS only when ALL checks pass.";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-refactor", {
    description: "ECC refactor - find dead code, reduce duplication, improve structure",
    argumentHint: "[path or description]",
    handler: async (args, ctx) => {
      const prompt = "## Code Refactoring\n\n" + (args ? "Focus: " + args : "Scan for improvement opportunities.") +
        "\n\n### Targets\n1. Dead code - unused functions, variables, imports\n2. Duplication - DRY violations\n3. Complexity - long functions, deep nesting\n4. Naming - unclear variable/function names\n5. Types - any usage, missing types\n6. Error handling - missing try/catch\n\nRules: one change at a time, keep style, don't change behavior, run tests after each change.";
      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-docs", {
    description: "ECC docs update - audit and update project documentation",
    argumentHint: "[path or component]",
    handler: async (args, ctx) => {
      const prompt = "## Documentation Update\n\n" + (args ? "Focus: " + args : "Audit project for documentation gaps.") +
        "\n\n### Checklist\n- README.md - is it up to date?\n- API docs - are endpoints documented?\n- Inline comments - accurate?\n- CHANGELOG - recent changes recorded?\n- docs/ directory";

      ctx.setInput(prompt);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc", {
    description: "ECC Bridge - show available ECC commands and status",
    handler: async (_args, ctx) => {
      ctx.ui.notify("ECC Bridge loaded - 197 skills + 8 commands", "info");
      ctx.setInput(ECC_HELP_TEXT);
      ctx.submit();
    },
  });

  pi.registerCommand("ecc-route", {
    description: "ECC model routing - recommend model for task complexity",
    argumentHint: "<task description>",
    handler: async (args, ctx) => {
      if (!args) {
        ctx.ui.notify("Usage: /ecc-route <task description>", "error");
        return;
      }
      const len = args.length;
      const complexity = len < 100 ? "simple" : len < 500 ? "medium" : "complex";
      const recs: Record<string, string> = {
        simple: "Claude Haiku / GPT-4o-mini - fast, cheap for quick tasks",
        medium: "Claude Sonnet / GPT-4o - balanced for most development",
        complex: "Claude Opus - deep reasoning for architecture and debugging",
      };
      ctx.ui.notify("Estimated complexity: " + complexity + "\n" + recs[complexity], "info");
      ctx.setInput("Task: " + len + " chars, complexity: " + complexity + "\nRecommended: " + recs[complexity]);
      ctx.submit();
    },
  });

  // ============================================================
  // 3. SESSION MANAGEMENT
  // ============================================================
  pi.on("session_start", async (event, ctx) => {
    if (event.reason === "startup") {
      ctx.ui.notify("ECC Bridge ready - 197 skills loaded", "info");
    }
  });

  // Removed: sessionManager.getStats() not available in current pi API
}
