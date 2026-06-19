# Gate Fixture: blocked-check

## Purpose
Verify that blocked-check.ps1 correctly detects manifest.yaml blocked_if violations.

## Test Scenarios

### Scenario 1: hard_delete_without_approval — positive (should trigger)

Given a TASKS.md declareing a SQL file with DELETE FROM and no approval marker:

```yaml
write_files:
  - src/main/resources/db/migration/V1__cleanup.sql
```

And `V1__cleanup.sql` contains:
```sql
DELETE FROM users WHERE deleted_at IS NOT NULL;
```

Then `blocked-check` should output `BLOCKED: hard_delete_without_approval`.

### Scenario 2: clean change — negative (should pass)

Given a TASKS.md with only additive SQL:

```yaml
write_files:
  - src/main/resources/db/migration/V2__add_column.sql
```

And `V2__add_column.sql` contains:
```sql
ALTER TABLE users ADD COLUMN display_name VARCHAR(255);
```

Then `blocked-check` should pass (exit 0).

### Scenario 3: disable_security_filter — positive (should trigger)

Given a write_file containing `.permitAll()` without explicit approval:

Then `blocked-check` should trigger `disable_security_filter`.

### Scenario 4: bypass_auth_for_production — positive (should trigger)

Given a write_file with `@Anonymous` combined with "production":

Then `blocked-check` should trigger `bypass_auth_for_production`.
