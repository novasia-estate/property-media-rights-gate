# Input contract v1

Required top-level fields: `schema_version: 1`, `as_of` (YYYY-MM-DD), `channel`, `market`, `assets`, `grants`. IDs and labels use `[A-Za-z0-9][A-Za-z0-9_.-]{0,63}`. Matching is exact and case-sensitive; KH and kh differ. The software does not interpret a market label as a legal jurisdiction.

Every asset requires `id`, `cropped` boolean, `attribution_provided` boolean. IDs must be unique in the request. Every grant requires all fields shown in `examples/release.json`; grant IDs must also be unique. `evidence_ref` and `reviewer_ref` are opaque references into the owner's evidence system; do not use email addresses or contract text.

`valid_from` and `valid_until` are real Gregorian dates in 1900–2100, inclusive at both ends. Leap years follow the Gregorian century rule. No time zone or current date is inferred. The caller must supply a new as-of day when rerunning a release.

Allowed channels: web, portal, print, social. Market labels are owner-defined exact labels. Scope lists are nonempty, unique and capped at 20 entries. A `*` wildcard is invalid. `requires_attribution: true` requires nonblank `attribution` text, at most 500 characters. When false, attribution may be empty. Supplied attribution text is not compared with rendered media; the caller's `attribution_provided` flag is an assertion requiring human review.

Unknown input fields are ignored and never copied into the decision. Missing or incorrectly typed required fields, duplicate IDs/scopes, malformed dates or exceeded limits fail the whole request. No inferred default permissions exist.
