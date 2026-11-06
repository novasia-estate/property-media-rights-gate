# Use in an editorial pipeline

1. The evidence owner authors and reviews the grant records outside this program.
2. The release job supplies the actual target channel, exact market label, as-of day and selected assets. Preserve the input snapshot with its human approval record.
3. Run OPA with this versioned policy directory. Consume `decision` for an audit, or explicitly assert `selected_checks_pass == true` with `--fail` for a selected-check gate.
4. Hold on invalid input, policy evaluation error or any asset hold. Failures are not exceptions to permissions.
5. A human reviews the actual evidence, crop and attribution before using the media.

The policies do not execute `http.send`, `time.now_ns`, filesystem, shell or external verification built-ins. There is no CI publishing credential or release automation included. A workflow can load a bundle built using `opa build policies` and evaluate the same decision path.

For the optional report, use `opa eval --format raw` and the exact decision path from README. The renderer reads that object rather than the normal nested OPA response. It creates a new output file and refuses to overwrite an existing one. IDs are HTML-escaped; source metadata values do not become markup. The report contains asset/grant IDs; review those before sharing.
