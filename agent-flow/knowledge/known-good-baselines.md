# Known-Good Baselines

> Reusable template for target projects. Record real verification baselines in the target project after installation, not in the starter.

## Purpose

- Avoid re-verifying the same invariant across changes.
- Detect regressions early when a known-good command fails without explanation.
- Give future AI sessions a concrete confidence anchor.

## Scaffold Health Baseline Template

Use this table after installing agent-flow into a target project or after modifying the scaffold itself.

| Check | Script | Expected Result | Verified |
|---|---|---|---|
| Manifest integrity | `manifest-check` | Required sections, gate registry, and risk rules are valid | ☐ |
| Scaffold structure | `scaffold-health` | Required dirs and files exist | ☐ |
| Template freshness | `template-check` | Templates match the current scaffold expectations | ☐ |
| Change lifecycle | `new-change` smoke test | Creates change dir with expected artifacts | ☐ |
| Closure chain | `check-change -Closure` | Required gates pass or have explicit skip evidence | ☐ |

## Project Baseline Table

| Date | Change | Backend Compile | Backend Tests | Frontend Checks | Module | Notes |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | change-id | command/result | command/result | command/result | module/path | release notes or drift notes |

## Conventions for Target Projects

| Check Type | Example Command | Frequency |
|---|---|---|
| Full build | `mvn clean compile` or `npm run build` | Every change |
| Unit tests | `mvn test` or `npm test` | Every change |
| Integration tests | `mvn verify -P integration` | Heavy changes |
| Lint | `npm run lint` | Every change |
| Type check | `npm run typecheck` | Every change |
| Security scan | `npm audit` or project equivalent | Weekly or Heavy |

## Baseline Update Triggers

- Major dependency version bump.
- Toolchain change.
- First full scaffold-health pass after installation.
- A verified change redefines what "working" means.

## Starter Rule

Do not commit target-project baseline results into `agent-flow-starter`. Keep this file generic so installed projects can own their own evidence.
