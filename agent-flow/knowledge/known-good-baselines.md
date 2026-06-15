# Known-Good Baselines

> Records verification points that define "working" for future AI sessions.
> When a baseline is confirmed, subsequent changes can trust these commands produce green results.

## Purpose

- Avoid re-verifying the same invariant across changes.
- Detect regression early: if a baseline gate fails without explanation, something broke.
- Provide a confidence anchor for new AI sessions joining mid-project.

## Baselines

### Scaffold Health Baseline

Recorded: 2026-06-15

Used to verify the agent-flow scaffold itself is intact after installation, upgrade, or self-modification.

| Check | Script | Expected Result | Verified |
|---|---|---|---|
| manifest integrity | `manifest-check` | All gates present, no TODO errors | ☐ |
| scaffold structure | `scaffold-health` | All required dirs and files exist | ☐ |
| cross-platform parity | `scaffold-health` (both OS) | .ps1 and .sh script counts match | ☐ |
| change lifecycle | `new-change` smoketest | Creates change dir with templates | ☐ |
| template freshness | `template-check` | All templates have correct VERSION | ☐ |

### Known-Good Baseline Table

| Date | Change | Backend Compile | Backend Tests | Frontend Checks | Module | Notes |
|---|---|---|---|---|---|---|
| 2026-06-15 | (scaffold-self) | n/a (starter) | n/a (starter) | n/a | n/a | agent-flow-starter v0.2.0 scaffold baseline established |

## Conventions for Target Projects

When running agent-flow in a real project, replace the Scaffold Health Baseline with project-specific commands:

| Check Type | Example Command | Frequency |
|---|---|---|
| Full build | `mvn clean compile` or `npm run build` | Every change |
| Unit tests | `mvn test` or `npm test` | Every change |
| Integration tests | `mvn verify -P integration` | Heavy changes |
| Lint | `npm run lint` | Every change |
| Type check | `npm run typecheck` | Every change |
| Security scan | `npm audit` | Weekly or Heavy |

## Baseline Update Triggers

- Major dependency version bump (Spring Boot, Node, etc.)
- Toolchain change (JDK version, npm registry, etc.)
- After first full scaffold-health pass post-installation
- After a verified change that redefined "working"

## Baseline Template

To add a new baseline entry, copy and fill:

```markdown
| {date} | {change-id} | ✅/❌/n/a | ✅/❌/n/a | ✅/❌/n/a | {module} | {release notes or drift notes} |
```
