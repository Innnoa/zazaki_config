## Script Error Handling Convention

### Exit Codes

| Code | Meaning |
|---|---|
| 0 | All checks passed |
| 1 | Check failure (non-blocking or fixable) |
| 2 | Configuration/infrastructure error (blocking) |

### Output Format

- All governance scripts output `PASS: <description>` or `FAIL: <description>` with a trailing newline.
- `FAIL` output must include the specific file path and problem description.
- `WARN` is reserved for informational diagnostics that do NOT block (e.g., intentional circular references).

### Diagnosis Steps

When a governance script fails:
1. Read the FAIL line to identify the affected file(s)
2. Run the script in isolation (not via regression-test.sh) to see full output
3. If the error is a broken cross-reference, use `grep` to locate the referencing file
4. If the error is a missing file, check whether it was intentionally deleted or moved
5. After fixing, re-run the specific script, then the full regression suite
