---
description: ECC TDD — Red-Green-Refactor TDD workflow for writing tested code
argument-hint: "[feature description]"
---
# ECC TDD Workflow

> Based on ECC's tdd-guide agent

Feature: ${1:-From current context}

## Red-Green-Refactor Cycle

### 🔴 RED — Write a failing test
- Think about the interface first
- Cover: happy path, edge cases, errors
- Run → test MUST fail

### 🟢 GREEN — Write minimal implementation
- Simplest code to pass the test
- Don't optimize yet
- Run → test MUST pass

### 🔵 REFACTOR — Improve code
- Eliminate duplication
- Improve naming
- Keep tests GREEN

## Coverage Targets
- **Unit**: 80%+ line coverage
- **Integration**: key paths
- **Edge cases**: empty, error, boundary
